#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include "FileHelper.h"

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    // 在 Windows 上强制 Qt Multimedia 优先使用 Windows Media Foundation (WMF) 后端，
    // 避免 DirectShow 因系统缺少 H.264/AAC 解码 Filter 报 0x80040266 之类的错误。
    // 必须在 QGuiApplication 构造之前设置才会生效。
    qputenv("QT_MULTIMEDIA_PREFERRED_PLUGINS", "windowsmediafoundation");
#endif

    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("VideoAnnotation"));
    QGuiApplication::setOrganizationName(QStringLiteral("VideoAnnotation"));

    QQmlApplicationEngine engine;

    FileHelper fileHelper;
    engine.rootContext()->setContextProperty(QStringLiteral("fileHelper"), &fileHelper);

    int fontId1 = QFontDatabase::addApplicationFont(":/fonts/AlibabaPuHuiTi-3-55-Regular.ttf");
    int fontId2 = QFontDatabase::addApplicationFont(":/fonts/AlibabaPuHuiTi-3-65-Medium.ttf");
    int fontId3 = QFontDatabase::addApplicationFont(":/fonts/AlibabaPuHuiTi-3-85-Bold.ttf");
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
