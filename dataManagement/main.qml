import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.12

ApplicationWindow {
    id: appWin
    visible: true
    width: 1200
    height: 600
    title: "Database Management"
    font.family: customFont.name

    property int rowHeight: 35//appWin.height/20
    property var selectedIds: []
    property int selectedSingleId: -1

    // 数据库连接配置
    Component.onCompleted: {
        dbManager.openDatabase("root", "mysql", "experiment_db");
    }

    // 字体加载
    FontLoader {
        id: customFont
        source: "qrc:/qt/qml/datamanagement/SourceHanSansCN-Regular.otf"
    }

    // 查询数据模型
    ListModel {
        id: queryModel
    }

    // 加载数据库数据
    function loadDatabaseData() {
        queryModel.clear();
        var queryResult = dbManager.queryData("SELECT * FROM experiment_table");
        for (var i = 0; i < queryResult.length; ++i) {
            queryModel.append(queryResult[i]);
        }
    }

    function restoreButtons() {
        for (var i = 0; i < selectRowCheckBoxGroup.buttons.length; ++i) {
            var button = selectRowCheckBoxGroup.buttons[i];
            var dataId = button.dataId; // 获取每个按钮的 dataId 属性
            console.log(selectedIds);
            // 检查该按钮的 dataId 是否在 selectedIds 中
            if (selectedIds.indexOf(dataId) !== -1) {
                button.checked = true; // 如果在 selectedIds 中，则设置为选中状态
            } else {
                button.checked = false; // 否则设置为未选中状态
            }
        }
    }

    //function addDatabaseData()

    ButtonGroup{
        id: selectRowCheckBoxGroup
        exclusive: false
        checkState: parentBox.checkState
    }

    Row {
        id: funcButtons
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        height: 30
        spacing: 10
        // 添加按钮
        Button {
            text: "添加数据"
            onClicked: addDialog.open()
        }
        Button {
            text: "删除选中"
            onClicked: {
                queryModel.clear();
                appWin.selectedIds.forEach(function(id) {
                     var queryModel = dbManager.deleteData(id);
                     appWin.selectedIds = []
                });
                loadDatabaseData();
            }
        }
        Button {
            text: "修改数据"
            onClicked: {
                var a = appWin.selectedIds;
                if (appWin.selectedIds.length == 1){
                    var id = appWin.selectedIds[0];
                    var sqlCode = "SELECT * FROM experiment_table WHERE id = " + id;
                    var data = dbManager.queryData(sqlCode);
                    if (data.length > 0) {
                        appWin.selectedSingleId = data[0].id;
                        modiExperimentName.text = data[0].experiment_name;
                        modiExperimentScene.text = data[0].experiment_scene;
                        modiProject.text = data[0].project;
                        modiParticipant.text = data[0].participant;
                        modiDate.text = data[0].date; // 这里假设日期格式符合要求，可以进行格式化显示
                        modiSensorType.text = data[0].sensor_type;
                    }
                    modiDialog.open();
                }
            }
        }
    }

    
    Rectangle {
        id: searchRect
        anchors.top: funcButtons.bottom
        anchors.left: parent.left
        anchors.margins: 20
        width: parent.width - 40
        height: 85
        border.color: "#73C2EA"
        Row {
            id: searchGrid
            //anchors.top: funcButtons.bottom
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.margins: 15
            //anchors.bottomMargin: 20
            height: 70
            spacing:10

            Column {
                width: 140
                Label {
                    text: "实验名称"
                }
                TextField {
                    id: searchExperimentName
                    //anchors.margins: 10
                    height: 35
                    width: 120
                    placeholderText: ""
                }
            }

            Column {
                width: 140
                Label {
                    text: "实验场景"
                }
                TextField {
                    id: searchExperimentScene
                    //anchors.margins: 10
                    height: 35
                    width: 120
                    placeholderText: ""
                }
            }

            Column {
                width: 140
                Label {
                    text: "项目"
                }
                TextField {
                    id: searchProject
                    //anchors.margins: 10
                    height: 35
                    width: 120
                    placeholderText: ""
                }
            }

            Column {
                width: 140
                Label {
                    text: "被试"
                }
                TextField {
                    id: searchParticipant
                    //anchors.margins: 10
                    height: 35
                    width: 120
                    placeholderText: ""
                }
            }

            Column {
                width: 140
                Label {
                    text: "日期"
                }
                TextField {
                    id: searchDate
                    //anchors.margins: 10
                    height: 35
                    width: 120
                    placeholderText: qsTr("YYYYMMDD")
                }
            }

            Column {
                width: 140
                Label {
                    text: "传感器类型"
                }
                TextField {
                    id: searchSensorType
                    //anchors.margins: 10
                    height: 35
                    width: 120
                    placeholderText: ""
                }
            }
            Button {
                text: "查找数据"
                anchors.verticalCenter: parent.verticalCenter
                //anchors.rightMargin: 20
                onClicked: {
                    var dateString = searchDate.text.trim();
                    var formattedDate = "";

                    if (dateString.length === 8) {
                        var year = dateString.substring(0, 4);
                        var month = dateString.substring(4, 6) - 1; // 月份从 0 开始
                        var day = dateString.substring(6, 8);
                        var date = new Date(year, month, day);
                        formattedDate = Qt.formatDate(date, "yyyyMMdd");
                        console.log("Formatted Date:", formattedDate);
                    } else {
                        console.log("Invalid date format");
                        //return; // 如果日期格式无效，停止执行
                    }

                    var experimentName = searchExperimentName.text.trim();
                    var experimentScene = searchExperimentScene.text.trim();
                    var project = searchProject.text.trim();
                    var participant = searchParticipant.text.trim();
                    var sensorType = searchSensorType.text.trim();

                    queryModel.clear();
                    var queryResult = dbManager.searchData(experimentName,
                                                            experimentScene,
                                                            project,
                                                            participant,
                                                            formattedDate,
                                                            sensorType);
                    for (var i = 0; i < queryResult.length; ++i) {
                        queryModel.append(queryResult[i]);
                    }
                }

            }
            Button {
                text: "重置查询"
                anchors.verticalCenter: parent.verticalCenter
                //anchors.leftMargin: 20
                onClicked: {
                    searchExperimentName.text = "";
                    searchExperimentScene.text = "";
                    searchProject.text = "";
                    searchParticipant.text = "";
                    searchDate.text = "";
                    searchSensorType.text = "";
                    loadDatabaseData(); // 重新加载数据
                }
            }
        }
    }


    // 页面布局
    Rectangle {
        id: mainTable
        width: parent.width
        // height: appWin.height - 40//appWin.rowHeight * 16
        anchors.top: searchRect.bottom
        anchors.bottom: parent.bottom
        //border.color: "black"
        //border.width: 2
        //anchors.centerIn: parent
        anchors.topMargin: 10
        anchors.rightMargin: 3
        anchors.leftMargin: 3
        anchors.bottomMargin: 30

        // 表头
        Rectangle {
            id: listNameRect
            width: parent.width - 30
            height: appWin.rowHeight
            color: "#e0e0e0"
            border.color: "black"
            border.width: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.rightMargin: 15
            anchors.leftMargin: 15
            //width: parent.width - 30
            //height: parent.height

            Row {
                anchors.fill: parent
                //anchors.margins: 5
                spacing: 10
                
                
                Rectangle {
                    width: parent.width/32
                    height: parent.height
                    border.color: "black"
                    border.width: 1
                    color: "#e0e0e0"
                    CheckBox{
                        property int dataId: model.id
                        id: parentBox
                        checked: false
                        checkState: selectRowCheckBoxGroup.checkState
                        anchors.centerIn: parent
                    }
                }
                Text {
                    width:parent.width/32
                    text: qsTr("id")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }

                Text {
                    width:parent.width/8
                    text: qsTr("实验名称")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }
                Text {
                    width:parent.width/8
                    text: qsTr("实验场景")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }
                Text {
                    width:parent.width/8
                    text: qsTr("项目")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }
                Text {
                    width:parent.width/8
                    text: qsTr("被试")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }
                Text {
                    width:parent.width/8
                    text: qsTr("日期")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: "black"
                }
                Text {
                    width:parent.width/8
                    text: qsTr("传感器类型")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            id: tableRect
            anchors.top: listNameRect.bottom// - appWin.rowHeight / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.rightMargin: 15
            anchors.leftMargin: 15
            width: parent.width - 30
            height: parent.height - appWin.rowHeight
            ListView {
                id: listView
                clip: true
                //anchors.top: listNameRect.bottom
                //anchors.bottom: mainTable.bottom
                anchors.fill: parent
                width: parent.width
                height: appWin.rowHeight *5
                model: queryModel
                Component.onCompleted:{
                    loadDatabaseData();
                }
            
                delegate: Item {
                    width: parent.width
                    //anchors.fill: parent
                    // height: 50
                    height: appWin.rowHeight
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: parent.height
                        border.color: "black"
                        border.width: 1
                        Row {
                            anchors.fill: parent
                            spacing: 10
                            Rectangle {
                                width: parent.width/32
                                height: parent.height
                                border.color: "black"
                                border.width: 1
                                color: "#e0e0e0"
                                CheckBox{
                                    property int dataId: model.id
                                    checked: false
                                    ButtonGroup.group: selectRowCheckBoxGroup
                                    anchors.centerIn: parent
                                    onCheckedChanged:{
                                        if (checked) {
                                            var index = selectedIds.indexOf(model.id);
                                            if (index == -1) {
                                                appWin.selectedIds.push(model.id);
                                            }
                                        } else {
                                            var index = selectedIds.indexOf(model.id);
                                            if (index > -1) {
                                                appWin.selectedIds.splice(index, 1);
                                            }
                                        }
                                    }
                                }
                            }
                            Text {
                                width:parent.width/32
                                text: model.id
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "grey"
                            }
                            Text {
                                width:parent.width/8
                                text: model.experiment_name
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "grey"
                            }
                            Text {
                                width:parent.width/8
                                text: model.experiment_scene
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "grey"
                            }
                            Text {
                                width:parent.width/8
                                text: model.project
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "grey"
                            }
                            Text {
                                width:parent.width/8
                                text: model.participant
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "grey"
                            }
                            Text {
                                width:parent.width/8
                                text: model.date
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "grey"
                            }
                            Text {
                                width:parent.width/8
                                text: model.sensor_type
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    Component.onCompleted: {
                        appWin.restoreButtons();
                    }
                }
                ScrollBar.vertical: ScrollBar {       //滚动条
                    anchors.right: listView.right
                    width: 10
                    active: true
                    background: Item {            //滚动条的背景样式
                        Rectangle {
                            anchors.centerIn: parent
                            height: parent.height
                            width: parent.width * 0.2
                            color: 'grey'
                            radius: width/2
                        }
                    }
 
                    contentItem: Rectangle {
                        radius: width/3        //bar的圆角
                        color: '#33373A'
                    }
                }

            }
        }
    }

    // 添加新数据对话框
    Dialog {
        id: addDialog
        title: "添加数据"
        standardButtons: Dialog.Ok | Dialog.Cancel

        GridLayout {
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            anchors.fill:parent
            anchors.centerIn:parent

            Label {
                text: "实验名称"
            }
            TextField {
                id: newExperimentName
                placeholderText: "Enter experiment name"
            }

            Label {
                text: "实验场景"
            }
            TextField {
                id: newExperimentScene
                placeholderText: "Enter experiment scene"
            }

            Label {
                text: "项目"
            }
            TextField {
                id: newProject
                placeholderText: "Enter project"
            }

            Label {
                text: "参与者"
            }
            TextField {
                id: newParticipant
                placeholderText: "Enter participant"
            }

            Label {
                text: "日期"
            }
            TextField {
                id: newDate
                placeholderText: "Enter date (YYYYMMDD)"
            }

            Label {
                text: "传感器类型"
            }
            TextField {
                id: newSensorType
                placeholderText: "Enter sensor type"
            }
        }


        onAccepted: {
            var dateString = newDate.text.trim();
            if (dateString.length === 8) {
                var year = dateString.substring(0, 4);
                var month = dateString.substring(4, 6) - 1; // 月份从 0 开始
                var day = dateString.substring(6, 8);
                var date = new Date(year, month, day);
                var formattedDate = Qt.formatDate(date, "yyyyMMdd");
                console.log("Formatted Date:", formattedDate);
            } else {
                console.log("Invalid date format");
            }

            var queryString = "INSERT INTO experiment_table (experiment_name, experiment_scene, project, participant, date, sensor_type) "
                            + "VALUES ('" + newExperimentName.text + "', '"
                            + newExperimentScene.text + "', '"
                            + newProject.text + "', '"
                            + newParticipant.text + "', '"
                            + formattedDate + "', '"
                            + newSensorType.text + "')";

            var success = dbManager.executeQuery(queryString);
            if (success) {
                // 清空输入框
                newExperimentName.text = "";
                newExperimentScene.text = "";
                newProject.text = "";
                newParticipant.text = "";
                newDate.text = "";
                newSensorType.text = "";
                loadDatabaseData(); // 重新加载数据
            }
        }
    }

    // 修改数据
    Dialog {
        id: modiDialog
        title: "修改数据"
        standardButtons: Dialog.Ok | Dialog.Cancel

        GridLayout {
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            anchors.fill:parent
            anchors.centerIn:parent

            Label {
                text: "实验名称"
            }
            TextField {
                id: modiExperimentName
                placeholderText: "Enter experiment name"
            }

            Label {
                text: "实验场景"
            }
            TextField {
                id: modiExperimentScene
                placeholderText: "Enter experiment scene"
            }

            Label {
                text: "项目"
            }
            TextField {
                id: modiProject
                placeholderText: "Enter project"
            }

            Label {
                text: "参与者"
            }
            TextField {
                id: modiParticipant
                placeholderText: "Enter participant"
            }

            Label {
                text: "日期"
            }
            TextField {
                id: modiDate
                placeholderText: "Enter date (YYYYMMDD)"
            }

            Label {
                text: "传感器类型"
            }
            TextField {
                id: modiSensorType
                placeholderText: "Enter sensor type"
            }
        }


        onAccepted: {
            var dateString = modiDate.text.trim();
            var formattedDate = "";

            if (dateString.length === 8) {
                var year = dateString.substring(0, 4);
                var month = dateString.substring(4, 6) - 1; // 月份从 0 开始
                var day = dateString.substring(6, 8);
                var date = new Date(year, month, day);
                formattedDate = Qt.formatDate(date, "yyyyMMdd");
                console.log("Formatted Date:", formattedDate);
            } else {
                console.log("Invalid date format");
                return; // 如果日期格式无效，停止执行
            }

            var queryString = "UPDATE experiment_table SET "
                            + "experiment_name = \"" + modiExperimentName.text.trim() + "\""
                            + ", experiment_scene = \"" + modiExperimentScene.text.trim() + "\""
                            + ", project = \"" + modiProject.text.trim() + "\""
                            + ", participant = \"" + modiParticipant.text.trim() + "\""
                            + ", date = \"" + formattedDate + "\""
                            + ", sensor_type = \"" + modiSensorType.text.trim() + "\""
                            + " WHERE id = " + appWin.selectedSingleId; // 假设我们使用一个唯一标识符来确定要更新的行

            var queryParams = [
                modiExperimentName.text.trim(),
                modiExperimentScene.text.trim(),
                modiProject.text.trim(),
                modiParticipant.text.trim(),
                formattedDate,
                modiSensorType.text.trim(),
                appWin.selectedSingleId // 假设你有一个变量 rowId 存储要更新的行的 ID
            ];

            var success = dbManager.executeQuery(queryString);
            if (success) {
                // 清空输入框
                modiExperimentName.text = "";
                modiExperimentScene.text = "";
                modiProject.text = "";
                modiParticipant.text = "";
                modiDate.text = "";
                modiSensorType.text = "";
                loadDatabaseData(); // 重新加载数据
            }
        }
    }


}
