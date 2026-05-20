#include "FileHelper.h"

#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QUrl>

FileHelper::FileHelper(QObject *parent)
    : QObject(parent)
{
}

QString FileHelper::urlToLocalFile(const QUrl &url) const
{
    if (url.isLocalFile()) {
        return QDir::toNativeSeparators(url.toLocalFile());
    }
    // 兜底：可能是本地相对路径
    return url.toString();
}

QString FileHelper::urlToLocalFile(const QString &url) const
{
    return urlToLocalFile(QUrl(url));
}

QUrl FileHelper::localFileToUrl(const QString &path) const
{
    return QUrl::fromLocalFile(path);
}

bool FileHelper::ensureDir(const QString &dirPath) const
{
    if (dirPath.isEmpty()) {
        return false;
    }
    QDir dir(dirPath);
    if (dir.exists()) {
        return true;
    }
    return dir.mkpath(QStringLiteral("."));
}

bool FileHelper::fileExists(const QString &path) const
{
    return !path.isEmpty() && QFileInfo::exists(path);
}

QString FileHelper::defaultSnapshotDir() const
{
    const QString picturesDir =
        QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    const QString target = picturesDir.isEmpty()
                               ? QDir::homePath() + QStringLiteral("/VideoAnnotation")
                               : picturesDir + QStringLiteral("/VideoAnnotation");
    return QDir::toNativeSeparators(target);
}

QString FileHelper::suggestSnapshotPath(const QString &videoSource,
                                        qint64 positionMs) const
{
    QString baseName = QStringLiteral("snapshot");
    if (!videoSource.isEmpty()) {
        QString local = videoSource;
        if (local.startsWith(QStringLiteral("file:"))) {
            local = QUrl(videoSource).toLocalFile();
        }
        const QFileInfo fi(local);
        if (!fi.completeBaseName().isEmpty()) {
            baseName = fi.completeBaseName();
        }
    }

    // 把毫秒转成 hh-mm-ss-zzz 形式，便于在文件名中辨识帧位置
    const qint64 totalMs = positionMs < 0 ? 0 : positionMs;
    const int ms = static_cast<int>(totalMs % 1000);
    const int seconds = static_cast<int>((totalMs / 1000) % 60);
    const int minutes = static_cast<int>((totalMs / 60000) % 60);
    const int hours = static_cast<int>(totalMs / 3600000);
    const QString stamp = QString::asprintf("%02d-%02d-%02d-%03d",
                                            hours, minutes, seconds, ms);

    const QString date =
        QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_HHmmss"));

    const QString fileName = QStringLiteral("%1_%2_%3.png")
                                 .arg(baseName, stamp, date);

    return QDir::toNativeSeparators(defaultSnapshotDir() + QStringLiteral("/") + fileName);
}

bool FileHelper::revealInExplorer(const QString &path) const
{
    if (path.isEmpty()) {
        return false;
    }

    const QFileInfo fi(path);
    if (!fi.exists()) {
        // 如果文件不存在，至少打开它所在目录
        return openDir(fi.absolutePath());
    }

#ifdef Q_OS_WIN
    const QString native = QDir::toNativeSeparators(fi.absoluteFilePath());
    const QStringList args{ QStringLiteral("/select,"), native };
    return QProcess::startDetached(QStringLiteral("explorer.exe"), args);
#else
    return QDesktopServices::openUrl(QUrl::fromLocalFile(fi.absolutePath()));
#endif
}

bool FileHelper::openDir(const QString &dirPath) const
{
    if (dirPath.isEmpty()) {
        return false;
    }
    QDir dir(dirPath);
    if (!dir.exists()) {
        dir.mkpath(QStringLiteral("."));
    }
    return QDesktopServices::openUrl(QUrl::fromLocalFile(dir.absolutePath()));
}
