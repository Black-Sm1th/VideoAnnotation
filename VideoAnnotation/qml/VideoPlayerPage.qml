import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import QtQuick.Dialogs 1.3
import "./components"

// 视频加载 + 单帧截取保存功能页面
Item {
    id: root

    // 当前已加载视频的本地路径（仅展示用）
    property string currentVideoPath: ""

    // 默认截图保存目录（启动时从 C++ 获取）
    property string snapshotDir: ""

    // 是否在等待截图回调（避免重复触发）
    property bool capturing: false

    Component.onCompleted: {
        snapshotDir = fileHelper.defaultSnapshotDir()
        fileHelper.ensureDir(snapshotDir)
    }

    // ========================================================================
    // 媒体相关核心对象
    // ========================================================================
    MediaPlayer {
        id: player
        autoPlay: false
        notifyInterval: 100

        onError: {
            if (error !== MediaPlayer.NoError) {
                messageBox.error(qsTr("播放错误：") + errorString)
            }
        }

        onStatusChanged: {
            if (status === MediaPlayer.Loaded || status === MediaPlayer.Buffered) {
                messageBox.success(qsTr("视频加载完成"))
            } else if (status === MediaPlayer.InvalidMedia) {
                messageBox.error(qsTr("无效的媒体文件"))
            }
        }
    }

    // ========================================================================
    // 文件对话框
    // ========================================================================
    FileDialog {
        id: openVideoDialog
        title: qsTr("选择视频文件")
        folder: shortcuts.movies
        selectExisting: true
        selectMultiple: false
        nameFilters: [
            qsTr("视频文件 (*.mp4 *.avi *.mov *.mkv *.wmv *.flv *.webm *.m4v *.ts)"),
            qsTr("所有文件 (*)")
        ]
        onAccepted: {
            player.stop()
            player.source = openVideoDialog.fileUrl
            currentVideoPath = fileHelper.urlToLocalFile(openVideoDialog.fileUrl)
            player.play()
        }
    }

    FileDialog {
        id: saveAsDialog
        title: qsTr("另存当前帧为图片")
        selectExisting: false
        selectMultiple: false
        nameFilters: [
            qsTr("PNG 图片 (*.png)"),
            qsTr("JPEG 图片 (*.jpg *.jpeg)"),
            qsTr("BMP 图片 (*.bmp)")
        ]
        onAccepted: {
            var localPath = fileHelper.urlToLocalFile(saveAsDialog.fileUrl)
            doCaptureToFile(localPath)
        }
    }

    FileDialog {
        id: chooseDirDialog
        title: qsTr("选择截图保存目录")
        selectFolder: true
        selectExisting: true
        onAccepted: {
            var local = fileHelper.urlToLocalFile(chooseDirDialog.fileUrl)
            if (local && fileHelper.ensureDir(local)) {
                snapshotDir = local
                messageBox.success(qsTr("已设置截图目录"))
            } else {
                messageBox.error(qsTr("目录不可用"))
            }
        }
    }

    // ========================================================================
    // 主布局
    // ========================================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ------------------ 顶部工具栏 ------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: "#FAFAFA"
            border.color: "#E0E0E0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                CustomButton {
                    text: qsTr("加载视频")
                    buttonWidth: 110
                    buttonHeight: 36
                    backgroundColor: "#3B82F6"
                    textColor: "#FFFFFF"
                    borderColor: "#2563EB"
                    onClicked: openVideoDialog.open()
                }

                CustomButton {
                    text: qsTr("截取当前帧")
                    buttonWidth: 130
                    buttonHeight: 36
                    backgroundColor: "#22C55E"
                    textColor: "#FFFFFF"
                    borderColor: "#16A34A"
                    enabled: player.hasVideo && !capturing
                    opacity: enabled ? 1.0 : 0.5
                    onClicked: captureFrameToDefaultDir()
                }

                CustomButton {
                    text: qsTr("另存为...")
                    buttonWidth: 100
                    buttonHeight: 36
                    enabled: player.hasVideo && !capturing
                    opacity: enabled ? 1.0 : 0.5
                    onClicked: {
                        saveAsDialog.folder = fileHelper.localFileToUrl(snapshotDir)
                        saveAsDialog.open()
                    }
                }

                CustomButton {
                    text: qsTr("设置截图目录")
                    buttonWidth: 130
                    buttonHeight: 36
                    onClicked: {
                        chooseDirDialog.folder = fileHelper.localFileToUrl(snapshotDir)
                        chooseDirDialog.open()
                    }
                }

                CustomButton {
                    text: qsTr("打开目录")
                    buttonWidth: 100
                    buttonHeight: 36
                    onClicked: fileHelper.openDir(snapshotDir)
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: snapshotDir === "" ? qsTr("未设置截图目录")
                                             : qsTr("保存至：") + snapshotDir
                    color: "#6B7280"
                    font.pixelSize: 12
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 360
                }
            }
        }

        // ------------------ 视频显示区 ------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#000000"

            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                source: player
                fillMode: VideoOutput.PreserveAspectFit
            }

            // 未加载视频时的占位提示
            Text {
                anchors.centerIn: parent
                visible: !player.hasVideo && player.source.toString() === ""
                text: qsTr("点击左上角\"加载视频\"开始")
                color: "#9CA3AF"
                font.pixelSize: 16
            }

            // 截图反馈：屏幕短暂闪白
            Rectangle {
                id: flashOverlay
                anchors.fill: parent
                color: "white"
                opacity: 0
                NumberAnimation on opacity {
                    id: flashAnim
                    from: 0.6
                    to: 0
                    duration: 280
                    running: false
                }
            }
        }

        // ------------------ 底部控制栏 ------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 96
            color: "#FAFAFA"
            border.color: "#E0E0E0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                // 进度条
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: formatTime(player.position)
                        color: "#374151"
                        font.pixelSize: 12
                        Layout.preferredWidth: 64
                        horizontalAlignment: Text.AlignRight
                    }

                    Slider {
                        id: progressSlider
                        Layout.fillWidth: true
                        from: 0
                        to: Math.max(1, player.duration)
                        enabled: player.seekable

                        // 用户在拖动时不要被 player 的 position 改变打断
                        property bool userInteracting: false

                        value: userInteracting ? value : player.position

                        onPressedChanged: {
                            if (pressed) {
                                userInteracting = true
                            } else {
                                player.seek(Math.round(value))
                                userInteracting = false
                            }
                        }
                    }

                    Text {
                        text: formatTime(player.duration)
                        color: "#374151"
                        font.pixelSize: 12
                        Layout.preferredWidth: 64
                    }
                }

                // 播放控制
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    CustomButton {
                        text: player.playbackState === MediaPlayer.PlayingState
                              ? qsTr("暂停") : qsTr("播放")
                        buttonWidth: 80
                        buttonHeight: 32
                        enabled: player.source.toString() !== ""
                        opacity: enabled ? 1.0 : 0.5
                        onClicked: togglePlay()
                    }

                    CustomButton {
                        text: qsTr("停止")
                        buttonWidth: 80
                        buttonHeight: 32
                        enabled: player.source.toString() !== ""
                        opacity: enabled ? 1.0 : 0.5
                        onClicked: player.stop()
                    }

                    CustomButton {
                        text: qsTr("-1帧")
                        buttonWidth: 70
                        buttonHeight: 32
                        enabled: player.seekable
                        opacity: enabled ? 1.0 : 0.5
                        onClicked: stepFrame(-40)
                    }

                    CustomButton {
                        text: qsTr("+1帧")
                        buttonWidth: 70
                        buttonHeight: 32
                        enabled: player.seekable
                        opacity: enabled ? 1.0 : 0.5
                        onClicked: stepFrame(40)
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: qsTr("音量")
                        color: "#374151"
                        font.pixelSize: 12
                    }

                    Slider {
                        id: volumeSlider
                        from: 0
                        to: 1
                        value: 0.8
                        Layout.preferredWidth: 140
                        onValueChanged: player.volume = value
                    }
                }
            }
        }
    }

    // ========================================================================
    // 消息提示组件
    // ========================================================================
    MessageBox { id: messageBox }

    // ========================================================================
    // 工具函数
    // ========================================================================

    function togglePlay() {
        if (player.playbackState === MediaPlayer.PlayingState) {
            player.pause()
        } else {
            player.play()
        }
    }

    // 简单的"逐帧"近似：按毫秒步进，帧率未知时按 ~25fps（40ms）跳
    function stepFrame(deltaMs) {
        if (!player.seekable) return
        player.pause()
        var target = Math.max(0, Math.min(player.duration, player.position + deltaMs))
        player.seek(target)
    }

    function formatTime(ms) {
        if (!ms || ms < 0) ms = 0
        var totalSec = Math.floor(ms / 1000)
        var h = Math.floor(totalSec / 3600)
        var m = Math.floor((totalSec % 3600) / 60)
        var s = totalSec % 60
        function pad(n) { return n < 10 ? "0" + n : "" + n }
        return (h > 0 ? pad(h) + ":" : "") + pad(m) + ":" + pad(s)
    }

    // 截取当前帧并保存到默认目录
    function captureFrameToDefaultDir() {
        if (capturing) return
        if (!fileHelper.ensureDir(snapshotDir)) {
            messageBox.error(qsTr("无法创建保存目录"))
            return
        }
        var path = fileHelper.suggestSnapshotPath(currentVideoPath, player.position)
        doCaptureToFile(path)
    }

    // 通用：截取 videoOutput 当前画面并保存到 localPath
    function doCaptureToFile(localPath) {
        if (capturing) return
        if (!localPath || localPath.length === 0) {
            messageBox.error(qsTr("保存路径无效"))
            return
        }

        capturing = true

        // grabToImage 是异步的，回调里得到 QQuickItemGrabResult
        var ok = videoOutput.grabToImage(function(result) {
            try {
                if (!result) {
                    messageBox.error(qsTr("截图失败：未获取到画面"))
                    return
                }
                if (result.saveToFile(localPath)) {
                    flashAnim.running = true
                    messageBox.success(qsTr("已保存：") + localPath)
                } else {
                    messageBox.error(qsTr("保存失败：") + localPath)
                }
            } finally {
                capturing = false
            }
        })

        if (!ok) {
            capturing = false
            messageBox.error(qsTr("无法发起截图请求"))
        }
    }
}
