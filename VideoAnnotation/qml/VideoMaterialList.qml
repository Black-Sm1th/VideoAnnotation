import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import "./components"
Column {
    height: parent.height
    width: parent.width
    Column {
        id: videoTitle
        width: parent.width
        padding: 16
        spacing: 16
        Label {
            text: qsTr("视频素材库")
            font.pixelSize: 20
            color: "#FFFFFF"
            font.weight: Font.Bold
        }
        Row {
            height: 38
            width: parent.width - 32
            spacing: 8
            CustomButton {
                width: (parent.width - 8) / 2
                height: 38
                backgroundColor: "#3C7EFF"
                text: "导入"
                iconSource: "qrc:/images/upload.png"
                textColor: "#FFFFFF"
            }
            CustomButton {
                width: (parent.width - 8) / 2
                height: 38
                color: "transparent"
                text: "一键分析"
                iconSource: "qrc:/images/magic.png"
                textColor: "#4080FF"
                borderWidth: 1
                borderColor: "#165DFF"
            }
        }
    }
    ScrollView {
        id: videoListScrollView
        clip: true
        height: parent.height - videoTitle.height - remindInfo.height
        width: parent.width
        padding: 16
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        Column {
            width: parent.width - 32
            spacing: 8
            Repeater {
                model: 10
                delegate: Rectangle {
                    width: videoListScrollView.width - 32
                    height: 64
                    color: "#1A1A1A"
                    radius: 10
                    Column {
                        spacing: 4
                        padding: 12
                        width: parent.width
                        Row {
                            height: 20
                            spacing: 8
                            Image{
                                source: "qrc:/images/video.png"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                id: videoName
                                text: qsTr("手术案例_001.mp4")
                                font.pixelSize: 14
                                font.family: "Alibaba PuHuiTi 3.0"
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#FFFFFF"
                            }
                        }
                        Row {
                            height: 16
                            spacing: 12
                            Text {
                                id: videoTime
                                text: qsTr("45:23")
                                font.pixelSize: 12
                                font.family: "Alibaba PuHuiTi 3.0"
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#78787A"
                            }
                            Text {
                                id: videoSize
                                text: qsTr("1.2GB")
                                font.pixelSize: 12
                                font.family: "Alibaba PuHuiTi 3.0"
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#78787A"
                            }
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        id: remindInfo
        height: 44
        width: parent.width
        color: "transparent"
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: qsTr("本次共导入3条视频")
            font.pixelSize: 12
            font.family: "Alibaba PuHuiTi 3.0"
            color: "#80FFFFFF"
        }
        ImageButton{
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16
            source: "qrc:/images/delete.png"
        }
    }
}
