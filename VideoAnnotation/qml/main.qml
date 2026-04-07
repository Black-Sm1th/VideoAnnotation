import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import QtAV 1.7
import "./components"
Window {
    visible: true
    width: 1280
    height: 720
    title: qsTr("Hello World")
    property var lines: []               // 存放所有标注 {x1,y1,x2,y2,text}
    property bool dragging: false
    property var currentStart: ({x:0,y:0})
    property real mouseXpos: 0
    property real mouseYpos: 0
    property int nextId: 1
    property real videoFps: 25.0         // 视频帧率，默认25fps
    property int currentFrame: 0         // 当前帧数
    property int totalFrames: 0          // 总帧数
    
    // 格式化时间显示函数 (毫秒转 mm:ss)
    function formatTime(ms) {
        var seconds = Math.floor(ms / 1000)
        var minutes = Math.floor(seconds / 60)
        seconds = seconds % 60
        return (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }
    DropArea {
        anchors.fill: parent
        onEntered: {
            if (!drag.hasUrls)
                return;
            console.log(drag.urls)
            player.source = drag.urls[0]
        }
    }
    Column{
        width: parent.width
        spacing: 12
        Rectangle {
            id:videoRec
            width: 800; height: 450; color: "black"
            anchors.horizontalCenter: parent.horizontalCenter
            VideoOutput2 {
                id: videoOut
                opengl: true
                fillMode: VideoOutput.PreserveAspectFit
                anchors.fill: parent
                source: player
                orientation: 0
                property real zoom: 1
                //filters: [negate, hflip]
            }

            // 标注画布
            Canvas {
                id: canvas
                anchors.fill: parent
                enabled: !player.playbackState === MediaPlayer.PlayingState

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    // 绘制已保存的标注框
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i];
                        ctx.strokeStyle = "#00FF00";
                        ctx.lineWidth = 2;
                        ctx.strokeRect(line.x1, line.y1, line.x2 - line.x1, line.y2 - line.y1);

                        // 绘制标注文字
                        if (line.text && line.text.length > 0) {
                            ctx.fillStyle = "#00FF00";
                            ctx.font = "14px Arial";
                            ctx.fillText(line.text, line.x1, line.y1 - 5);
                        }
                    }

                    // 绘制当前正在拖动的框
                    if (dragging) {
                        ctx.strokeStyle = "#FFFF00";
                        ctx.lineWidth = 2;
                        ctx.strokeRect(currentStart.x, currentStart.y,
                                     mouseXpos - currentStart.x,
                                     mouseYpos - currentStart.y);
                    }
                }
            }

            // 鼠标区域用于绘制标注
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: player.playbackState !== MediaPlayer.PlayingState
                hoverEnabled: true

                onPressed: {
                    if (player.playbackState === MediaPlayer.PlayingState)
                        return;
                    dragging = true;
                    currentStart = {x: mouse.x, y: mouse.y};
                    mouseXpos = mouse.x;
                    mouseYpos = mouse.y;
                }

                onPositionChanged: {
                    if (dragging) {
                        mouseXpos = mouse.x;
                        mouseYpos = mouse.y;
                        canvas.requestPaint();
                    }
                }

                onReleased: {
                    if (!dragging)
                        return;
                    dragging = false;

                    var x1 = Math.min(currentStart.x, mouse.x);
                    var y1 = Math.min(currentStart.y, mouse.y);
                    var x2 = Math.max(currentStart.x, mouse.x);
                    var y2 = Math.max(currentStart.y, mouse.y);

                    // 只有当框的大小足够大时才添加
                    if (Math.abs(x2 - x1) > 10 && Math.abs(y2 - y1) > 10) {
                        var newLine = {
                            id: nextId++,
                            x1: x1,
                            y1: y1,
                            x2: x2,
                            y2: y2,
                            text: ""
                        };
                        lines.push(newLine);

                        // 显示文本输入框
                        annotInput.currentLineId = newLine.id;
                        annotInput.x = x1;
                        annotInput.y = y1 > 40 ? y1 - 40 : y2 + 5;
                        annotInput.visible = true;
                        textInput.focus = true;
                    }

                    canvas.requestPaint();
                }
            }

            MediaPlayer {
                id: player
                objectName: "player"
                //loops: MediaPlayer.Infinite
                //autoLoad: true
                // autoPlay: true
                videoCapture {
                    autoSave: true
                    onSaved: {
                        console.log("capture saved at: " + path)
                    }
                }

                onPositionChanged: {
                    if (duration > 0 && !progressSlider.pressed) {
                        currentFrame = Math.floor((position / 1000.0) * videoFps)
                    }
                }

                onDurationChanged: {
                    if (duration > 0) {
                        totalFrames = Math.floor((duration / 1000.0) * videoFps)
                        // 尝试获取实际帧率
                        if (player.metaData && player.metaData.videoFrameRate) {
                            videoFps = player.metaData.videoFrameRate
                            totalFrames = Math.floor((duration / 1000.0) * videoFps)
                        }
                    }
                }
            }
        }
        Row {
           height: 40
           spacing: 12
           anchors.horizontalCenter: parent.horizontalCenter
           CustomButton{
                text: "播放"
                onClicked: {
                    player.play()
                }
           }
           CustomButton{
                text: "暂停"
                onClicked: {
                    player.pause()
                }
           }
           CustomButton{
                text: "清空标注"
                onClicked: { 
                    lines = []
                    canvas.requestPaint()
                }
           }
           CustomButton{
                text: "保存标注图片"
                enabled: player.playbackState !== MediaPlayer.PlayingState && lines.length > 0
                onClicked: {
                    // 先让canvas绘制完成
                    canvas.requestPaint()
                    // 保存截图
                    player.videoCapture.capture()
                    console.log("已保存带标注的图片")
                }
           }
        }

        // 进度条区域
        Rectangle {
            width: 800
            height: 80
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                anchors.fill: parent
                spacing: 8

                // 帧控制按钮行
                Row {
                    height: 30
                    spacing: 8
                    anchors.horizontalCenter: parent.horizontalCenter

                    CustomButton {
                        text: "◄◄ 上一帧"
                        width: 100
                        height: 30
                        enabled: player.duration > 0
                        onClicked: {
                            if (currentFrame > 0) {
                                currentFrame--
                                var newPos = (currentFrame / videoFps) * 1000
                                player.seek(Math.floor(newPos))
                            }
                        }
                    }

                    Text {
                        text: "帧: " + currentFrame + " / " + totalFrames
                        font.pixelSize: 14
                        color: "#333333"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 120
                        horizontalAlignment: Text.AlignHCenter
                    }

                    CustomButton {
                        text: "下一帧 ►►"
                        width: 100
                        height: 30
                        enabled: player.duration > 0
                        onClicked: {
                            if (currentFrame < totalFrames - 1) {
                                currentFrame++
                                var newPos = (currentFrame / videoFps) * 1000
                                player.seek(Math.floor(newPos))
                            }
                        }
                    }
                }

                // 进度条
                Row {
                    width: parent.width
                    spacing: 8
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: formatTime(player.position)
                        font.pixelSize: 12
                        color: "#666666"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                    }

                    Slider {
                        id: progressSlider
                        width: parent.width - 140
                        from: 0
                        to: player.duration > 0 ? player.duration : 1000
                        stepSize: player.duration > 0 ? (1000.0 / videoFps) : 1
                        
                        // 只在不拖动时更新进度条位置
                        Binding {
                            target: progressSlider
                            property: "value"
                            value: player.position
                            when: !progressSlider.pressed
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        onMoved: {
                            if (pressed) {
                                player.seek(Math.floor(value))
                                currentFrame = Math.floor((value / 1000.0) * videoFps)
                            }
                        }

                        background: Rectangle {
                            x: progressSlider.leftPadding
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 6
                            width: progressSlider.availableWidth
                            height: implicitHeight
                            radius: 3
                            color: "#E0E0E0"

                            Rectangle {
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#4CAF50"
                                radius: 3
                            }
                        }

                        handle: Rectangle {
                            x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 8
                            color: progressSlider.pressed ? "#45a049" : "#4CAF50"
                            border.color: "#FFFFFF"
                            border.width: 2
                        }
                    }

                    Text {
                        text: formatTime(player.duration)
                        font.pixelSize: 12
                        color: "#666666"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                    }
                }
            }
        }


        // 提示信息
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: player.playbackState === MediaPlayer.PlayingState ? 
                  "播放中..." : 
                  "暂停后可以在视频上拖动鼠标绘制标注框"
            color: "#666666"
            font.pixelSize: 12
        }
    }

    // 文本输入浮窗
    Rectangle {
        id: annotInput
        width: 240
        height: 36
        color: "#E0E0E0"
        radius: 6
        border.color: "#00FF00"
        border.width: 2
        visible: false
        property int currentLineId: -1
        z: 100

        TextInput {
            id: textInput
            anchors.fill: parent
            anchors.margins: 8
            font.pixelSize: 14
            color: "#000000"
            verticalAlignment: TextInput.AlignVCenter

            onAccepted: {
                // 找到对应的标注并写入文本
                for (var i = 0; i < lines.length; ++i) {
                    if (lines[i].id === annotInput.currentLineId) {
                        lines[i].text = text
                        break
                    }
                }
                annotInput.visible = false
                text = ""
                canvas.requestPaint()
            }

            Keys.onEscapePressed: {
                annotInput.visible = false
                text = ""
            }
        }
    }
}
