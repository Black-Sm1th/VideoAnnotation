import QtQuick 2.15

// 视频时间轴：底部带刻度与时间标签，顶部带可拖动的播放头（白色三角 + 竖线）
Item {
    id: root

    // 视频总时长（毫秒）
    property real duration: 0
    // 当前播放位置（毫秒）
    property real position: 0
    // 是否允许交互（拖动 / 点击跳转）
    property bool seekable: false

    // 颜色与样式
    property color barColor: "#0F1722"
    property color tickColor: "#475569"
    property color majorTickColor: "#94A3B8"
    property color labelColor: "#94A3B8"
    property color playheadColor: "#FFFFFF"
    property color playedColor: "#3C7EFF"

    // 主刻度间隔（毫秒），默认 10s 一个带文字的主刻度，并在中间各放 1 个小刻度
    property real majorIntervalMs: 10000

    // 用户拖动时不被外部 position 打断
    property bool _userDragging: false
    // 用户拖动时显示的临时位置
    property real _dragPosition: 0

    // 对外发出 seek 请求（毫秒）
    signal seekRequested(real ms)

    implicitHeight: 56

    // 当前播放头实际所处位置（毫秒）：拖动中用临时值，否则跟随播放器
    readonly property real effectivePosition:
        _userDragging ? _dragPosition : position

    // 把时间换算为 x 像素
    function timeToX(ms) {
        if (duration <= 0) return 0
        var ratio = Math.max(0, Math.min(1, ms / duration))
        return ratio * trackArea.width
    }

    // 把 x 像素换算为时间
    function xToTime(x) {
        if (trackArea.width <= 0 || duration <= 0) return 0
        var ratio = Math.max(0, Math.min(1, x / trackArea.width))
        return ratio * duration
    }

    function _formatTime(ms) {
        if (!ms || ms < 0) ms = 0
        var totalSec = Math.floor(ms / 1000)
        var h = Math.floor(totalSec / 3600)
        var m = Math.floor((totalSec % 3600) / 60)
        var s = totalSec % 60
        function pad(n) { return n < 10 ? "0" + n : "" + n }
        return (h > 0 ? pad(h) + ":" : "") + pad(m) + ":" + pad(s)
    }

    // 背景轨
    Rectangle {
        id: bg
        anchors.fill: parent
        color: barColor
        radius: 4
    }

    // 已播放部分的高亮（淡淡的一层）
    Rectangle {
        anchors.left: bg.left
        anchors.top: bg.top
        anchors.bottom: bg.bottom
        width: trackArea.x + timeToX(effectivePosition)
        color: playedColor
        opacity: 0.10
        radius: 4
        visible: duration > 0
    }

    // 刻度与时间标签绘制区
    Item {
        id: trackArea
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        Canvas {
            id: ticksCanvas
            anchors.fill: parent
            antialiasing: true

            function _formatTime(ms) {
                if (!ms || ms < 0) ms = 0
                var totalSec = Math.floor(ms / 1000)
                var h = Math.floor(totalSec / 3600)
                var m = Math.floor((totalSec % 3600) / 60)
                var s = totalSec % 60
                function pad(n) { return n < 10 ? "0" + n : "" + n }
                return (h > 0 ? pad(h) + ":" : "") + pad(m) + ":" + pad(s)
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                if (width <= 0 || height <= 0) return

                var dur = root.duration
                var major = root.majorIntervalMs
                var minor = major / 2  // 主刻度之间再加一个小刻度

                // 即使没有视频也画一条基准线，呈现样式
                var baseY = Math.floor(height * 0.55) + 0.5
                ctx.strokeStyle = root.tickColor
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.moveTo(0, baseY)
                ctx.lineTo(width, baseY)
                ctx.stroke()

                if (dur <= 0) return

                ctx.font = "11px \"Alibaba PuHuiTi 3.0\""
                ctx.textAlign = "center"
                ctx.textBaseline = "top"

                // 先画小刻度
                ctx.strokeStyle = root.tickColor
                ctx.lineWidth = 1
                for (var t1 = 0; t1 <= dur + 0.5; t1 += minor) {
                    var x1 = (t1 / dur) * width
                    ctx.beginPath()
                    ctx.moveTo(x1 + 0.5, baseY - 4)
                    ctx.lineTo(x1 + 0.5, baseY + 4)
                    ctx.stroke()
                }

                // 再画主刻度（更长 + 时间标签）
                ctx.strokeStyle = root.majorTickColor
                ctx.fillStyle = root.labelColor
                for (var t2 = 0; t2 <= dur + 0.5; t2 += major) {
                    var x2 = (t2 / dur) * width
                    ctx.beginPath()
                    ctx.moveTo(x2 + 0.5, baseY - 7)
                    ctx.lineTo(x2 + 0.5, baseY + 7)
                    ctx.stroke()

                    var label = _formatTime(t2)
                    // 末尾标签靠右对齐避免被裁剪
                    var align = "center"
                    if (t2 === 0) align = "left"
                    else if (t2 + major > dur) align = "right"
                    ctx.textAlign = align
                    ctx.fillText(label, x2, baseY + 10)
                }
            }
        }

        // 重绘触发
        Connections {
            target: root
            function onDurationChanged() { ticksCanvas.requestPaint() }
            function onMajorIntervalMsChanged() { ticksCanvas.requestPaint() }
        }
        onWidthChanged: ticksCanvas.requestPaint()
        onHeightChanged: ticksCanvas.requestPaint()

        // 已播放进度的加深条
        Rectangle {
            visible: root.duration > 0
            x: 0
            width: root.timeToX(root.effectivePosition)
            y: Math.floor(parent.height * 0.55) - 1
            height: 2
            color: root.playedColor
        }

        // 播放头：顶部三角 + 整条竖线
        Item {
            id: playhead
            visible: root.duration > 0
            width: 14
            height: parent.height
            x: root.timeToX(root.effectivePosition) - width / 2
            z: 3

            // 顶部小三角（朝下）
            Canvas {
                id: triangle
                width: parent.width
                height: 8
                anchors.top: parent.top
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.fillStyle = root.playheadColor
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            // 竖线
            Rectangle {
                width: 2
                height: parent.height - triangle.height
                color: root.playheadColor
                anchors.top: triangle.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // 交互：点击跳转 + 拖拽
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.seekable ? Qt.PointingHandCursor : Qt.ArrowCursor
            preventStealing: true

            onPressed: {
                if (!root.seekable || root.duration <= 0) return
                root._userDragging = true
                root._dragPosition = root.xToTime(mouse.x)
            }
            onPositionChanged: {
                if (!pressed) return
                if (!root.seekable || root.duration <= 0) return
                root._dragPosition = root.xToTime(mouse.x)
            }
            onReleased: {
                if (!root.seekable || root.duration <= 0) {
                    root._userDragging = false
                    return
                }
                var target = root.xToTime(mouse.x)
                root._dragPosition = target
                root.seekRequested(target)
                root._userDragging = false
            }
        }
    }
}
