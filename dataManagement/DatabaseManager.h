// databasemanager.h
#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QtSql>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject* parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE bool openDatabase(const QString& username, const QString& password,
        const QString& databaseName, const QString& hostname = "localhost");
    Q_INVOKABLE void closeDatabase();
    Q_INVOKABLE bool isConnected() const;

    Q_INVOKABLE QVariantList queryData(const QString& queryString);
    Q_INVOKABLE QVariantList deleteData(const int id);
    Q_INVOKABLE QVariantList searchData(const QString& experimentName, const QString& experimentScene, const QString& project, const QString& participant, const QString& date, const QString& sensorType);
    Q_INVOKABLE bool executeQuery(const QString& queryString);

private:
    QSqlDatabase m_database;
};

#endif // DATABASEMANAGER_H
