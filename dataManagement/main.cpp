#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "databasemanager.h"

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    // ע���Զ���� C++ ���͵� QML ��������
    qmlRegisterType<DatabaseManager>("DatabaseManager", 1, 0, "DatabaseManager");

    // �������ݿ�������
    DatabaseManager dbManager;

    // ���� QML Ӧ�ó�������
    QQmlApplicationEngine engine;

    // �����ݿ�������¶�� QML ������
    engine.rootContext()->setContextProperty("dbManager", &dbManager);

    // ������ QML �ļ�
    const QUrl url(QStringLiteral("qrc:/qt/qml/datamanagement/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
