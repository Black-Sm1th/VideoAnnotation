import QtQuick 2.15
import QtQuick.Controls 2.15

Row {
    id: root

    // 颜色列表（颜色字符串数组）
    property var colors: []
    property int currentIndex: 0
    property color currentColor: (currentIndex >= 0 && currentIndex < colors.length)
                                 ? colors[currentIndex] : "#000000"

    property int swatchSize: 18
    property int cellSize: 28
    property color selectedBorderColor: "#3C7EFF"
    property color hoverColor: "#22FFFFFF"

    signal selected(int index)

    spacing: 2

    Repeater {
        model: root.colors
        delegate: Rectangle {
            width: root.cellSize
            height: root.cellSize
            radius: 6
            color: cellMouse.containsMouse ? root.hoverColor : "transparent"
            border.color: index === root.currentIndex ? root.selectedBorderColor : "transparent"
            border.width: index === root.currentIndex ? 2 : 0

            Behavior on color { ColorAnimation { duration: 100 } }

            Rectangle {
                anchors.centerIn: parent
                width: root.swatchSize
                height: root.swatchSize
                radius: width / 2
                color: modelData
                border.color: "#33FFFFFF"
                border.width: 1
            }

            MouseArea {
                id: cellMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.currentIndex = index
                    root.selected(index)
                }
            }
        }
    }
}
