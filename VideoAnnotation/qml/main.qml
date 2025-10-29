import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtAV 1.7
import "./components"
Window {
    visible: true
    width: 1280
    height: 720
    title: qsTr("Hello World")
    Column{
        width: parent.width
        spacing: 12
        Rectangle {
            width: 800; height: 450; color: "black"
            anchors.horizontalCenter: parent.horizontalCenter
            Video {
                id: video
                anchors.fill: parent
                autoPlay: true
                source: "file:///C:/Users/71455/Desktop/demo.mp4"
            }
        }
        Row {
           height: 40
           spacing: 12
           anchors.horizontalCenter: parent.horizontalCenter
           CustomButton{
                text: "播放"
                onClicked: {
                    video.play()
                }
           }
           CustomButton{
                text: "暂停"
                onClicked: {
                    video.pause()
                }
           }
        }
    }
}
