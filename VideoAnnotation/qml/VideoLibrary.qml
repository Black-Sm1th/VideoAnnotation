import QtQuick 2.15

// 视频素材库的共享数据模型，由 main.qml 实例化一次后通过属性
// 注入给 VideoMaterialList / VideoPlayer 等使用方共享。
QtObject {
    id: root

    // 视频列表数据，每一项字段：
    //   name     - 显示名（不含扩展名等修饰前的文件名）
    //   source   - 供 MediaPlayer.source 使用的 file:// URL
    //   path     - 本地路径（用于展示与去重）
    //   sizeText - 文件大小展示文本，未知时为 "--"
    //   timeText - 时长展示文本，未知时为 "--:--"
    property ListModel videos: ListModel {}

    // 当前选中视频在 videos 中的索引；-1 表示未选中
    property int currentIndex: -1

    // 当前选中视频的派生属性，便于绑定使用
    readonly property string currentSource:
        currentIndex >= 0 && currentIndex < videos.count
            ? videos.get(currentIndex).source : ""
    readonly property string currentName:
        currentIndex >= 0 && currentIndex < videos.count
            ? videos.get(currentIndex).name : ""
    readonly property string currentPath:
        currentIndex >= 0 && currentIndex < videos.count
            ? videos.get(currentIndex).path : ""

    // 本次（自上次清空起）累计导入的视频条数，用于底部统计文案
    property int importedCount: 0

    function _basename(path) {
        if (!path) return ""
        var s = String(path).replace(/\\/g, "/")
        var i = s.lastIndexOf("/")
        return i >= 0 ? s.substring(i + 1) : s
    }

    function _hasPath(path) {
        for (var i = 0; i < videos.count; ++i) {
            if (videos.get(i).path === path) return true
        }
        return false
    }

    // 添加单个视频（来自 FileDialog 的 url）
    // 返回 true 表示新增成功，false 表示重复
    function addVideoUrl(url) {
        if (!url) return false
        var path = ""
        if (typeof fileHelper !== "undefined" && fileHelper) {
            path = fileHelper.urlToLocalFile(url)
        } else {
            path = String(url).replace(/^file:\/+/, "")
        }
        if (!path || _hasPath(path)) return false

        videos.append({
            name: _basename(path),
            source: String(url),
            path: path,
            sizeText: "--",
            timeText: "--:--"
        })
        if (currentIndex < 0) currentIndex = 0
        importedCount += 1
        return true
    }

    // 批量添加（FileDialog.fileUrls 为数组）
    function addVideoUrls(urls) {
        if (!urls) return 0
        var added = 0
        for (var i = 0; i < urls.length; ++i) {
            if (addVideoUrl(urls[i])) added += 1
        }
        return added
    }

    function selectIndex(idx) {
        if (idx < 0 || idx >= videos.count) return
        currentIndex = idx
    }

    function removeAll() {
        videos.clear()
        currentIndex = -1
        importedCount = 0
    }

    function updateDuration(idx, ms) {
        if (idx < 0 || idx >= videos.count) return
        videos.setProperty(idx, "timeText", _formatDuration(ms))
    }

    function _formatDuration(ms) {
        if (!ms || ms < 0) ms = 0
        var totalSec = Math.floor(ms / 1000)
        var h = Math.floor(totalSec / 3600)
        var m = Math.floor((totalSec % 3600) / 60)
        var s = totalSec % 60
        function pad(n) { return n < 10 ? "0" + n : "" + n }
        return (h > 0 ? pad(h) + ":" : "") + pad(m) + ":" + pad(s)
    }
}
