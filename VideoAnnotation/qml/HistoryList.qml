import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

Column {
    height: parent.height
    width: parent.width
    Row {
        id: historyTitleRow
        width: parent.width
        height: 62
        padding: 16
        spacing: 6
        Image {
            id: historyTitle
            source: "qrc:/images/clock.png"
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "历史记录"
            font.weight: Font.Bold
            font.pixelSize: 20
            color: "#FFFFFF"
            font.family: "Alibaba PuHuiTi 3.0"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    ScrollView {
        id: historyListScrollView
        clip: true
        height: parent.height - historyTitleRow.height
        width: parent.width
        leftPadding: 16
        rightPadding: 16
        bottomPadding: 16
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        Column {
            width: parent.width - 32
            spacing: 8
            Repeater {
                model: 10
                delegate: Rectangle {
                    width: historyListScrollView.width - 32
                    height: 64
                    color: "#1A1A1A"
                    radius: 10
                    Column {
                        spacing: 4
                        padding: 12
                        width: parent.width
                        Text {
                            id: historyName
                            text: qsTr("手术案例_001.mp4")
                            font.pixelSize: 14
                            font.family: "Alibaba PuHuiTi 3.0"
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }
                        Row {
                            height: 16
                            spacing: 12
                            Text {
                                id: historyTime
                                text: qsTr("45:23")
                                font.pixelSize: 12
                                font.family: "Alibaba PuHuiTi 3.0"
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#78787A"
                            }
                            Text {
                                id: historySize
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
}
