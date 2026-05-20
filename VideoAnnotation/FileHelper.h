#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QString>
#include <QUrl>

// QML 使用的文件 / 路径辅助工具：
// - 把 FileDialog 选出的 file:// URL 转换为本地路径
// - 反之亦然
// - 创建截图保存目录
// - 在 Windows 资源管理器（或对应文件管理器）中定位文件
class FileHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = nullptr);

    Q_INVOKABLE QString urlToLocalFile(const QUrl &url) const;
    Q_INVOKABLE QString urlToLocalFile(const QString &url) const;
    Q_INVOKABLE QUrl localFileToUrl(const QString &path) const;

    Q_INVOKABLE bool ensureDir(const QString &dirPath) const;
    Q_INVOKABLE bool fileExists(const QString &path) const;

    Q_INVOKABLE QString defaultSnapshotDir() const;
    Q_INVOKABLE QString suggestSnapshotPath(const QString &videoSource,
                                            qint64 positionMs) const;

    Q_INVOKABLE bool revealInExplorer(const QString &path) const;
    Q_INVOKABLE bool openDir(const QString &dirPath) const;
};

#endif // FILEHELPER_H
