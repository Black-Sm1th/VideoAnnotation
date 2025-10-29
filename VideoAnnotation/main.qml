import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtAV 1.7
Window {
    visible: true
    width: 1280
    height: 720
    title: qsTr("Hello World")

    Rectangle {
        width: 800; height: 450; color: "black"
        anchors.centerIn: parent

        Video {
            anchors.fill: parent
            autoPlay: true
            source: "file:///C:/Users/71455/Desktop/demo.mp4"
        }
    }
}
