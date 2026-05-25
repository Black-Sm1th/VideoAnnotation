import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtQml 2.15
import "./components"

Column {
    id: root

    // 注入的共享视频库（main.qml 中实例化的 VideoLibrary）
    property var library: null

    height: parent.height
    width: parent.width

    // 多选视频文件对话框
    FileDialog {
        id: importDialog
        title: qsTr("选择视频文件")
        folder: shortcuts.movies
        selectExisting: true
        selectMultiple: true
        nameFilters: [
            qsTr("视频文件 (*.mp4 *.avi *.mov *.mkv *.wmv *.flv *.webm *.m4v *.ts)"),
            qsTr("所有文件 (*)")
        ]
        onAccepted: {
            if (!root.library) return
            // Qt5 的 FileDialog 在 selectMultiple=true 时通过 fileUrls 获取所有选中
            var urls = importDialog.fileUrls
            if (urls && urls.length > 0) {
                root.library.addVideoUrls(urls)
            } else if (importDialog.fileUrl) {
                root.library.addVideoUrl(importDialog.fileUrl)
            }
        }
    }

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
                onClicked: importDialog.open()
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
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        Column {
            width: parent.width - 32
            spacing: 8
            Repeater {
                model: root.library ? root.library.videos : null
                delegate: Rectangle {
                    width: videoListScrollView.width - 32
                    height: 64
                    radius: 10
                    property bool selected: root.library && root.library.currentIndex === index
                    color: selected ? "#23375A"
                                    : (videoItemMouse.containsMouse ? "#222533" : "#1A1A1A")
                    border.color: selected ? "#3C7EFF" : "transparent"
                    border.width: selected ? 1 : 0
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Column {
                        spacing: 4
                        padding: 12
                        width: parent.width
                        Row {
                            height: 20
                            spacing: 8
                            width: parent.width - 24
                            Image {
                                source: "qrc:/images/video.png"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                id: videoNameText
                                text: model.name
                                font.pixelSize: 14
                                font.family: "Alibaba PuHuiTi 3.0"
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#FFFFFF"
                                elide: Text.ElideMiddle
                                width: parent.width - 28
                            }
                        }
                        Row {
                            height: 16
                            spacing: 12
                            Text {
                                text: model.timeText
                                font.pixelSize: 12
                                font.family: "Alibaba PuHuiTi 3.0"
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#78787A"
                            }
                            Text {
                                text: model.sizeText
                                font.pixelSize: 12
                                font.family: "Alibaba PuHuiTi 3.0"
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#78787A"
                            }
                        }
                    }

                    MouseArea {
                        id: videoItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.library) root.library.selectIndex(index)
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
            text: root.library
                  ? qsTr("本次共导入%1条视频").arg(root.library.importedCount)
                  : qsTr("本次共导入0条视频")
            font.pixelSize: 12
            font.family: "Alibaba PuHuiTi 3.0"
            color: "#80FFFFFF"
        }
        ImageButton {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16
            source: "qrc:/images/delete.png"
            onClicked: {
                if (root.library) root.library.removeAll()
            }
        }
    }
}
