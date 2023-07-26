import FileIO 3.0
import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2

MuseScore {
    id:pluginscope

    property alias model: commentModel

    description: "Allows uses to comment on friends music in real time"
    version: "1.0"
    menuPath: "Plugins.Aplz"
    pluginType: "dock"

    width:  2000
    height: 2000


    QProcess { id: proc }

    onRun: {

        var commentPath = outfile.homePath() + "/aplz/" 
        console.log("Comment Path " + commentPath)

        var c
        switch (Qt.platform.os){
            case "windows":
                c = 'cmd /c "mkdir -p ' + commentPath + '&& type nul > ' + commentPath + '/' + curScore.scoreName +'.json"'
                break;
            default:
                console.log('/bin/sh -c mkdir -p ' + commentPath+' && touch ' + commentPath + '/' + curScore.scoreName+  ".json")
                c = 'bash -c "mkdir -p ' + commentPath + '&& touch ' + commentPath + '/' + curScore.scoreName +'.json"'
        }
            
        proc.start(c)
        var val=proc.waitForFinished(5000)
        // DEBUG
        try {
            var out=proc.readAllStandardOutput()
            console.log("-- Command output: "+out)
            if (val) {
                console.log('terminated correctly.')
            } else {
                console.log('failure')
            }
        } catch (err) {
            console.log("--" + err.message);
        }
        

        outfile.source = commentPath + curScore.scoreName + ".json";
    }

    FileIO {
        id: outfile
        onError: console.log("outfile Err: " + msg)
    }

    FileIO {
        id: initFIle
        onError: console.log("outfile Err: " + msg)
    }


    function cat(username, measure, comment){
        console.log("submit")
        model.append({
            "commenter": username,
            "measure": measure,
            "comment": comment
        });


        var commentObject = {}
        commentObject.name = "ScoreComments"
        commentObject.comments = []

        //TOD doesn't work
        for( var i = 0; i < model.rowCount(); i++ ) {
            commentObject.comments.push(model.get(i))
        }
        var json = JSON.stringify(commentObject)
        console.log(json)
        outfile.write(json)
    }

    Rectangle { 
        color: "#4595a1"
        anchors.fill: parent
    }
    
    Column{
        visible: true
        id:main
        y: 10
    
        Rectangle{
            id: bg2
            width: 220
            height: 350
            x: 10
            y: 10
            color: "#f2f2f2"
            border.color:"#808080"
            radius: 4

            ListModel {
                id: commentModel
            }
            
            ListView {
                anchors.fill: parent
                model: commentModel
                delegate: contactDelegate
                focus: true
                spacing: 10
                width: 220
                height: 350
                

                Component {
                    id: contactDelegate

                    Item {
                        width: 200
                        height: 50
                        x:10
                        y:10
                        Column {
                            Text {
                                text: '<b>Name:</b> ' + model.commenter 
                            }
                            Text {
                                text: "<b>Measure</b>: " + model.measure
                            }
                            Text {
                                text: "<b>Comment</b>: " + model.comment
                            }
                        }
                    }
                }
            }

            Timer {
                interval: 500
                running: true
                repeat: true
                onTriggered: () =>{
                    commentModel.clear()
                    var text = outfile.read()
                    if (text.trim() == ""){
                        return;
                    }

                    var JsonObject = JSON.parse(text);
                    JsonObject.comments.forEach((r) => {
                        commentModel.append({
                            "commenter": r.commenter,
                            "measure": r.measure,
                            "comment": r.comment
                        });
                    });
                }
            }
        }

        Grid {
            id: grid
            columns: 1
            spacing: 10
            padding:10

            TextArea { 
                wrapMode: Text.WordWrap
                background: Rectangle {
                    color: "#f2f2f2"
                    border.color:"#808080"
                    radius: 4
                }
                placeholderText:"Username"; 
                width: 220
                id:"usernameTxt";
                Keys.onTabPressed: nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason) 
            }

            TextArea { 
                wrapMode: Text.WordWrap
                background: Rectangle {
                    color: "#f2f2f2"
                    border.color:"#808080"
                    radius: 4
                }
                placeholderText:"Measure"; 
                width: 220
                id:"measureTxt";
                Keys.onTabPressed: nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason) 
            }
        
            ScrollView {
            id: view
            width:220; 
            height: 113;
                TextArea { 
                    wrapMode: Text.WordWrap
                    background: Rectangle {
                        color: "#f2f2f2"
                        border.color:"#808080"
                        radius: 4
                    }
                    placeholderText:"Comment"; 
                    width: 220
                    id:"commentTxt";
                    Keys.onTabPressed: nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason) 
                }
            }

            Button {
                id: loopButton
                text: "Comment"
                onClicked: cat(usernameTxt.text,measureTxt.text,commentTxt.text )
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: button.down ? "#d6d6d6" : "#f6f6f6"
                    border.color: "#26282a"
                    border.width: 1
                    radius: 4
                }
            }
        }
        
    }
}
