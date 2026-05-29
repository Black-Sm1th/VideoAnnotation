import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15
import QtQml 2.15
import "./components"

Column {
    id: root

    // 注入的共享视频库（main.qml 中实例化的 VideoLibrary）
    property var library: null

    width: parent.width
    height: parent.height

    // 画笔标注工具（背景和器械工具），名称与颜色一一对应
    property var brushTools: [
        { name: "背景", color: "#000000" },
        { name: "抓取器", color: "#F53F3F" },
        { name: "双极 bipolar", color: "#FF5C26" },
        { name: "钩 hook", color: "#FF7D00" },
        { name: "剪刀 scissors", color: "#FFAB00" },
        { name: "夹子 clipper", color: "#FFE03C" },
        { name: "冲洗器 irrigator", color: "#C6E83C" },
        { name: "纱布 gauze", color: "#FFB3C6" }
    ]
    readonly property var brushToolNames: brushTools.map(function(t) { return t.name })
    readonly property var brushToolColors: brushTools.map(function(t) { return t.color })

    // 当前选中的画笔工具索引（下拉框与颜色选择器共用，双向同步）
    property int brushIndex: 0
    onBrushIndexChanged: {
        brushToolSelect.currentIndex = brushIndex
        brushColorSelect.currentIndex = brushIndex
    }

    // 视频播放器，由共享库的 currentSource 驱动
    MediaPlayer {
        id: player
        autoPlay: true
        notifyInterval: 100
        source: root.library ? root.library.currentSource : ""

        onDurationChanged: {
            if (root.library && root.library.currentIndex >= 0) {
                root.library.updateDuration(root.library.currentIndex, duration)
            }
        }
    }

    // 当切换到新视频时，自动从头开始播放
    Connections {
        target: root.library
        ignoreUnknownSignals: true
        function onCurrentSourceChanged() {
            if (!root.library) return
            player.stop()
            if (root.library.currentSource && root.library.currentSource.length > 0) {
                player.play()
            }
        }
    }

    Column {
        id: videoArea
        padding: 10
        height: parent.height - operateCol.height
        width: parent.width
        Rectangle {
            id: videoFrame
            width: parent.width - 20
            height: parent.height - 20
            color: "#232323"
            radius: 10
            clip: true

            // 是否已有有效视频源
            property bool hasVideoSource:
                root.library && root.library.currentSource && root.library.currentSource.length > 0

            readonly property int topBarHeight: 28
            readonly property int bottomBarHeight: 36

            // 顶部视频名称栏
            Rectangle {
                id: topNameBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: videoFrame.topBarHeight
                color: "#1A1A1A"
                radius: videoFrame.radius
                // 用一个矩形遮住底部圆角，让上方圆角，下方为直角
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: videoFrame.hasVideoSource && root.library
                          ? root.library.currentName : ""
                    font.pixelSize: 12
                    font.family: "Alibaba PuHuiTi 3.0"
                    color: "#FFFFFF"
                    elide: Text.ElideMiddle
                    width: parent.width - 24
                }
            }

            // 中间视频画面区域
            Item {
                id: videoCanvasArea
                anchors.top: topNameBar.bottom
                anchors.bottom: bottomControlBar.top
                anchors.left: parent.left
                anchors.right: parent.right

                VideoOutput {
                    id: videoOutput
                    anchors.fill: parent
                    anchors.margins: 4
                    source: player
                    fillMode: VideoOutput.PreserveAspectFit
                    visible: videoFrame.hasVideoSource
                }

                // 占位提示
                Rectangle {
                    width: 232
                    height: 232
                    color: "#111111"
                    anchors.centerIn: parent
                    visible: !videoFrame.hasVideoSource
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        width: Math.max(emptyImage.width, emptyText.width)
                        Image {
                            id: emptyImage
                            source: "qrc:/images/videoEmpty.png"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            id: emptyText
                            text: qsTr("待上传视频")
                            font.pixelSize: 14
                            font.family: "Alibaba PuHuiTi 3.0"
                            color: "#78787A"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // 底部时间 + 播放/暂停控制栏
            Rectangle {
                id: bottomControlBar
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: videoFrame.bottomBarHeight
                color: "#1A1A1A"
                radius: videoFrame.radius
                // 同上：上半部分用直角
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.radius
                    color: parent.color
                }

                // 左侧当前播放时间
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: root._formatTime(player.position)
                    font.pixelSize: 12
                    font.family: "Alibaba PuHuiTi 3.0"
                    color: "#7AA2FF"
                }

                // 中间播放/暂停按钮
                Item {
                    id: playPauseBtn
                    width: 32
                    height: 32
                    anchors.centerIn: parent

                    property bool isPlaying: player.playbackState === MediaPlayer.PlayingState

                    Canvas {
                        id: playIcon
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        visible: !playPauseBtn.isPlaying
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = playMouseArea.containsMouse ? "#FFFFFF" : "#E5E7EB"
                            ctx.beginPath()
                            ctx.moveTo(2, 1)
                            ctx.lineTo(14, height / 2)
                            ctx.lineTo(2, height - 1)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }

                    // 监听 hover 状态变化重绘
                    Connections {
                        target: playMouseArea
                        function onContainsMouseChanged() { playIcon.requestPaint() }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        visible: playPauseBtn.isPlaying
                        Rectangle {
                            width: 4
                            height: 14
                            color: playMouseArea.containsMouse ? "#FFFFFF" : "#E5E7EB"
                            radius: 1
                        }
                        Rectangle {
                            width: 4
                            height: 14
                            color: playMouseArea.containsMouse ? "#FFFFFF" : "#E5E7EB"
                            radius: 1
                        }
                    }

                    MouseArea {
                        id: playMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: videoFrame.hasVideoSource
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (player.playbackState === MediaPlayer.PlayingState) {
                                player.pause()
                            } else {
                                player.play()
                            }
                        }
                    }
                }

                // 右侧视频总时间
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: root._formatTime(player.duration)
                    font.pixelSize: 12
                    font.family: "Alibaba PuHuiTi 3.0"
                    color: "#7AA2FF"
                }
            }
        }
    }

    // 把毫秒格式化为 hh:mm:ss / mm:ss
    function _formatTime(ms) {
        if (!ms || ms < 0) ms = 0
        var totalSec = Math.floor(ms / 1000)
        var h = Math.floor(totalSec / 3600)
        var m = Math.floor((totalSec % 3600) / 60)
        var s = totalSec % 60
        function pad(n) { return n < 10 ? "0" + n : "" + n }
        return pad(h) + ":" + pad(m) + ":" + pad(s)
    }

    Rectangle {
        height: 1
        width: parent.width
        color: "#1E2939"
    }

    Column {
        id: operateCol
        height: 222 - 1
        width: parent.width
        padding: 10
        spacing: 16

        Row {
            height: 32
            width: parent.width - 20
            spacing: 16
            CustomButton {
                iconSource: "qrc:/images/edit.png"
                width: 82
                height: 32
                text: "编辑"
                backgroundColor: "#29FFFFFF"
                textColor: "#FFFFFF"
            }
            Row {
                height: parent.height
                spacing: 10
                Text {
                    text: qsTr("选择画笔颜色")
                    font.pixelSize: 12
                    font.family: "Alibaba PuHuiTi 3.0"
                    color: "#99A1AF"
                    anchors.verticalCenter: parent.verticalCenter
                }
                // 工具下拉框：选择背景和器械工具
                DropdownSelect {
                    id: brushToolSelect
                    width: 140
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    borderWidth: 1
                    borderColor: "#2E2E30"
                    alignment: Qt.AlignLeft
                    model: root.brushToolNames
                    textColor: "#FFFFFF"
                    chevronColor: "#9A9A9A"
                    popupBackgroundColor: "#2B2B2B"
                    popupBorderColor: "#3A3A3A"
                    hoverColor: "#22FFFFFF"
                    pressedColor: "#33FFFFFF"
                    selectedItemColor: "#333C7EFF"
                    onSelected: function(index, text) { root.brushIndex = index }
                }
                // 颜色选择器：平铺一行色块，与工具下拉框同步
                ColorPickerSelect {
                    id: brushColorSelect
                    anchors.verticalCenter: parent.verticalCenter
                    colors: root.brushToolColors
                    onSelected: function(index) { root.brushIndex = index }
                }
            }
        }

        // 时间轴进度条
        TimelineBar {
            id: timeline
            width: parent.width - 20
            height: 56
            duration: player.duration
            position: player.position
            seekable: player.seekable && player.duration > 0
            onSeekRequested: function(ms) {
                if (player.seekable) player.seek(Math.round(ms))
            }
        }
    }
}
