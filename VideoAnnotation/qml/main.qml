import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import "./"
import "./components"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1920
    height: 1080
    font.family: "Alibaba PuHuiTi 3.0"
    font.pixelSize: 14
    title: qsTr("内镜手术智能感知系统")

    // 全局共享的视频素材库模型，被左侧列表与中间播放器共用
    VideoLibrary { id: videoLibrary }

    Rectangle{
        id: topBar
        height: 64
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#111111"
        Row{
            width: parent.width
            height: parent.height
            leftPadding: 16
            rightPadding: 16
            spacing: 10
            Image{
                source: "qrc:/images/titileIcon.png"
                anchors.verticalCenter: parent.verticalCenter
            }
            Label {
                id: titleLabel
                text: qsTr("内镜手术智能感知系统")
                font.pixelSize: 20
                font.weight: Font.Bold
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    Rectangle{
        id: leftPanel
        color: "#232323"
        anchors.left: parent.left
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        width: 320
        Column{
            width: parent.width
            height: parent.height
            VideoMaterialList {
                width: parent.width
                height: parent.height * 2 / 3
                library: videoLibrary
            }
            Rectangle{
                width: parent.width
                height: 1
                color: "#0A0A0A"
            }
            HistoryList {
                height: parent.height * 1 / 3 - 1
                width: parent.width
            }
        }
    }
    Rectangle{
        id: rightPanel
        color: "#232323"
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        width: 320
        OperationInfo {
            anchors.fill: parent
        }
    }
    Rectangle{
        id: midPanel
        color: "#0A0A0A"
        anchors.left: leftPanel.right
        anchors.right: rightPanel.left
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        VideoPlayer {
            anchors.fill: parent
            library: videoLibrary
        }
    }
    // VideoPlayerPage {
    //     anchors.fill: parent
    // }
}
