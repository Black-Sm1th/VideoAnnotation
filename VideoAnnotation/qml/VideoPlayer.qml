import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import "./components"

Column {
    width: parent.width
    height: parent.height
    Column {
        padding: 10
        height: parent.height - operateCol.height
        width: parent.width
        Rectangle {
            width: parent.width - 20
            height: parent.height - 20
            color: "#232323"
            radius: 10
            Rectangle{
                width: 232
                height: 232
                color: "#111111"
                anchors.centerIn: parent
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
    }
    Rectangle{
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
                DropdownSelect {
                    borderWidth: 1
                    borderColor: "#2E2E30"

                }
            }
        }
    }
}
