// databasemanager.cpp
#include "databasemanager.h"

DatabaseManager::DatabaseManager(QObject* parent) : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    closeDatabase();
}

bool DatabaseManager::openDatabase(const QString& username, const QString& password,
    const QString& databaseName, const QString& hostname)
{
    m_database = QSqlDatabase::addDatabase("QMYSQL");
    m_database.setHostName(hostname);
    m_database.setDatabaseName(databaseName);
    m_database.setUserName(username);
    m_database.setPassword(password);

    if (!m_database.open()) {
        qDebug() << "Database Error:" << m_database.lastError().text();
        return false;
    }

    qDebug() << "Database connected!";
    return true;
}

void DatabaseManager::closeDatabase()
{
    m_database.close();
    qDebug() << "Database disconnected.";
}

bool DatabaseManager::isConnected() const
{
    return m_database.isOpen();
}

QVariantList DatabaseManager::queryData(const QString& queryString)
{
    QVariantList resultList;

    QSqlQuery query(m_database);
    if (!query.exec(queryString)) {
        qDebug() << "Query Error:" << query.lastError().text();
        return resultList;
    }

    while (query.next()) {
        QVariantMap row;
        row["id"] = query.value("id").toInt();
        row["experiment_name"] = query.value("experiment_name").toString();
        row["experiment_scene"] = query.value("experiment_scene").toString();
        row["project"] = query.value("project").toString();
        row["participant"] = query.value("participant").toString();
        // 获取日期并转换为yyyyMMdd格式
        QDate date = query.value("date").toDate();
        row["date"] = date.toString("yyyyMMdd");
        row["sensor_type"] = query.value("sensor_type").toString();
        resultList.append(row);
    }

    return resultList;
}

QVariantList DatabaseManager::deleteData(const int id)
{
    QVariantList resultList;

    QSqlQuery query(m_database);
    query.prepare("DELETE FROM experiment_table WHERE id = ?");
    query.addBindValue(id);

    if (!query.exec()) {
        qDebug() << "Query Error:" << query.lastError().text();
        return resultList;
    }
    resultList = queryData("SELECT * FROM experiment_table");

    return resultList;
}

Q_INVOKABLE QVariantList DatabaseManager::searchData(const QString& experimentName, const QString& experimentScene, const QString& project, const QString& participant, const QString& date, const QString& sensorType)
{
    QString queryStr = "SELECT * FROM experiment_table WHERE 1=1";
    if (!experimentName.isEmpty()) {
        queryStr += " AND experiment_name = \"" + experimentName + "\" ";
    }
    if (!experimentScene.isEmpty()) {
        queryStr += " AND experiment_scene = \"" + experimentScene + "\" ";
    }
    if (!project.isEmpty()) {
        queryStr += " AND project = \"" + project + "\" ";
    }
    if (!participant.isEmpty()) {
        queryStr += " AND participant = \"" + participant + "\" ";
    }
    if (!date.isEmpty()) {
        queryStr += " AND date = \"" + date + "\" ";
    }
    if (!sensorType.isEmpty()) {
        queryStr += " AND sensor_type = \"" + sensorType + "\" ";
    }
    QVariantList resultList = queryData(queryStr);
    return resultList;
}

//QVariantList DatabaseManager::modifyData(const int id， )
//{
//    QVariantList resultList;
//
//    QSqlQuery query(m_database);
//    query.prepare("DELETE FROM experiment_table WHERE id = ?");
//    query.addBindValue(id);
//
//    if (!query.exec()) {
//        qDebug() << "Query Error:" << query.lastError().text();
//        return resultList;
//    }
//    resultList = queryData("SELECT * FROM experiment_table");
//
//    return resultList;
//}

bool DatabaseManager::executeQuery(const QString& queryString)
{
    QSqlQuery query(m_database);
    if (!query.exec(queryString)) {
        qDebug() << "Query Error:" << query.lastError().text();
        return false;
    }

    return true;
}
