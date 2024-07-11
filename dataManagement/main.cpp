#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "databasemanager.h"

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    // 注册自定义的 C++ 类型到 QML 上下文中
    qmlRegisterType<DatabaseManager>("DatabaseManager", 1, 0, "DatabaseManager");

    // 创建数据库管理对象
    DatabaseManager dbManager;

    // 创建 QML 应用程序引擎
    QQmlApplicationEngine engine;

    // 将数据库管理对象暴露给 QML 上下文
    engine.rootContext()->setContextProperty("dbManager", &dbManager);

    // 加载主 QML 文件
    const QUrl url(QStringLiteral("qrc:/qt/qml/datamanagement/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
