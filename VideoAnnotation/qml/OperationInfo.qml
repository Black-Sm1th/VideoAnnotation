import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

Column {
    id: root

    height: parent.height
    width: parent.width

    // 标注图例分组数据：每组包含标题、是否展开、条目（颜色 + 名称）
    property var legendGroups: [
        {
            title: "背景和器械工具",
            expanded: true,
            items: [
                { color: "#000000", name: "背景" },
                { color: "#F53F3F", name: "抓取器" },
                { color: "#FF5C26", name: "双极 bipolar" },
                { color: "#FF7D00", name: "钩 hook" },
                { color: "#FFAB00", name: "剪刀 scissors" },
                { color: "#FFE03C", name: "夹子 clipper" },
                { color: "#C6E83C", name: "冲洗器 irrigator" },
                { color: "#FFB3C6", name: "纱布 gauze" }
            ]
        },
        {
            title: "解剖目标",
            expanded: false,
            items: [
                { color: "#3491FA", name: "肝脏" },
                { color: "#23C343", name: "胆囊" },
                { color: "#722ED1", name: "胆总管" },
                { color: "#F53F3F", name: "血管" }
            ]
        },
        {
            title: "动作指令",
            expanded: false,
            items: [
                { color: "#3491FA", name: "抓取" },
                { color: "#FF7D00", name: "切割" },
                { color: "#23C343", name: "分离" },
                { color: "#722ED1", name: "缝合" }
            ]
        },
        {
            title: "手术阶段",
            expanded: false,
            items: [
                { color: "#3491FA", name: "术前规划" },
                { color: "#FF7D00", name: "解剖暴露" },
                { color: "#F53F3F", name: "切除" },
                { color: "#23C343", name: "缝合关闭" }
            ]
        }
    ]

    // 手术信息增强：键值对
    property var surgeryInfo: [
        { label: "手术阶段", value: "术前规划" },
        { label: "手术时长(累计)", value: "00:02:13" },
        { label: "关键器械", value: "电钩 / 超声刀" },
        { label: "上传日期", value: "2026-04-20" }
    ]

    // 标题栏
    Row {
        id: titleRow
        width: parent.width
        height: 62
        leftPadding: 16
        spacing: 8

        Rectangle {
            width: 18
            height: 18
            radius: 9
            color: "transparent"
            border.color: "#9A9A9A"
            border.width: 1.5
            anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                text: "i"
                color: "#9A9A9A"
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Alibaba PuHuiTi 3.0"
            }
        }
        Text {
            text: "操作信息"
            font.weight: Font.Bold
            font.pixelSize: 20
            color: "#FFFFFF"
            font.family: "Alibaba PuHuiTi 3.0"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ScrollView {
        id: scrollView
        clip: true
        width: parent.width
        height: parent.height - titleRow.height
        leftPadding: 16
        rightPadding: 16
        bottomPadding: 16
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            width: scrollView.width - 32
            spacing: 16

            // 卡片一：标注图例
            Rectangle {
                width: parent.width
                color: "#2B2B2B"
                radius: 12
                height: legendColumn.height + 32

                Column {
                    id: legendColumn
                    width: parent.width - 32
                    x: 16
                    y: 16
                    spacing: 4

                    Text {
                        text: "标注图例"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        font.family: "Alibaba PuHuiTi 3.0"
                        bottomPadding: 8
                    }

                    Repeater {
                        model: root.legendGroups

                        delegate: Column {
                            id: groupColumn
                            width: legendColumn.width
                            property bool expanded: modelData.expanded

                            // 分组标题（可点击展开/收起）
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: "transparent"

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.title
                                    font.pixelSize: 14
                                    color: "#C9C9C9"
                                    font.family: "Alibaba PuHuiTi 3.0"
                                }

                                Canvas {
                                    id: chevron
                                    width: 16
                                    height: 16
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    rotation: groupColumn.expanded ? 0 : 180
                                    Behavior on rotation {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.reset()
                                        ctx.strokeStyle = "#9A9A9A"
                                        ctx.lineWidth = 1.5
                                        ctx.lineCap = "round"
                                        ctx.lineJoin = "round"
                                        ctx.beginPath()
                                        ctx.moveTo(4, 6)
                                        ctx.lineTo(8, 10)
                                        ctx.lineTo(12, 6)
                                        ctx.stroke()
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: groupColumn.expanded = !groupColumn.expanded
                                }
                            }

                            // 分组内容（颜色 + 名称列表）
                            Column {
                                width: parent.width
                                visible: groupColumn.expanded
                                height: groupColumn.expanded ? implicitHeight : 0
                                Repeater {
                                    model: modelData.items
                                    delegate: Item {
                                        width: groupColumn.width
                                        height: 34
                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: modelData.color
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 14
                                            color: "#FFFFFF"
                                            font.family: "Alibaba PuHuiTi 3.0"
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 卡片二：手术信息增强
            Rectangle {
                width: parent.width
                color: "#2B2B2B"
                radius: 12
                height: infoColumn.height + 32

                Column {
                    id: infoColumn
                    width: parent.width - 32
                    x: 16
                    y: 16
                    spacing: 16

                    Text {
                        text: "手术信息增强"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        font.family: "Alibaba PuHuiTi 3.0"
                    }

                    Repeater {
                        model: root.surgeryInfo
                        delegate: Column {
                            width: infoColumn.width
                            spacing: 4
                            Text {
                                text: modelData.label
                                font.pixelSize: 12
                                color: "#78787A"
                                font.family: "Alibaba PuHuiTi 3.0"
                            }
                            Text {
                                text: modelData.value
                                font.pixelSize: 14
                                color: "#FFFFFF"
                                font.family: "Alibaba PuHuiTi 3.0"
                            }
                        }
                    }
                }
            }
        }
    }
}
