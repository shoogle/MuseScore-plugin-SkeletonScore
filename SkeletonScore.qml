// SPDX-License-Identifier: MIT
//============================================================================
// SkeletonScore - a plugin for MuseScore (https://musescore.org/)
//
// Copyright (c) 2019 Peter Jonas
//
// This file is licensed under the MIT License (a.k.a. the "Expat License").
// Repository: https://github.com/shoogle/MuseScore-plugin-SkeletonScore
//============================================================================
import QtQuick 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.0
import MuseScore 3.0
import FileIO 3.0

MuseScore {
    menuPath: "Plugins.layoutBreaks"
    version: "1.0"
    description: qsTr("Quickly add line breaks, page breaks, and section breaks to a score to match the layout of a PDF or paper edition.")
    requiresScore: true
    pluginType: "dialog"

    id:window
    width:  800; height: 500;
    onRun: {}

    FileIO {
        id: myFileAbc
        onError: console.log(msg + "  Filename = " + myFileAbc.source)
        }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a file")
        onAccepted: {
            var filename = fileDialog.fileUrl
            //console.log("You chose: " + filename)

            if(filename){
                myFileAbc.source = filename
                //read abc file and put it in the TextArea
                abcText.text = myFileAbc.read()
                }
            }
        }

    Label {
        id: textLabel
        wrapMode: Text.WordWrap
        text: qsTr("Paste your desired layout here. Enter number of measures, each separated by a space (system break) or newline (page break).")
        font.pointSize:12
        anchors.left: window.left
        anchors.top: window.top
        anchors.leftMargin: 10
        anchors.topMargin: 10
        }

    // Where people can paste their ABC tune or where an ABC file is put when opened
    TextArea {
        id:abcText
        anchors.top: textLabel.bottom
        anchors.left: window.left
        anchors.right: window.right
        anchors.bottom: buttonOpenFile.top
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        width:parent.width
        height:400
        wrapMode: TextEdit.WrapAnywhere
        textFormat: TextEdit.PlainText
        }

    Button {
        id : buttonOpenFile
        text: qsTr("Open file")
        anchors.bottom: window.bottom
        anchors.left: abcText.left
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        onClicked: {
            fileDialog.open();
            }
        }

    function layoutBreakToStr(layoutBreak) {
        switch (layoutBreak.layoutBreakType) {
            case LayoutBreak.LINE: return qsTr("System"); break;
            case LayoutBreak.PAGE: return qsTr("Page"); break;
            case LayoutBreak.SECTION: return qsTr("Section"); break;
            case LayoutBreak.NOBREAK: return qsTr("No Break"); break;
            default: return qsTr("Invalid type '%1' for break %2").arg(layoutBreak.layoutBreakType).arg(layoutBreak);
            }
        }

    function advanceMeasures(cursor, numMeasures) {
        for (var i = 0; i < numMeasures; i++) {
            if (!cursor.nextMeasure()) {
                console.log(qsTr("End of Score!"));
                return false;
                }
            }
        return true;
        }

    Button {
        id : buttonConvert
        text: qsTr("Add breaks")
        anchors.bottom: window.bottom
        anchors.right: abcText.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        onClicked: {
            var input = abcText.text.replace(/\r\n/g, "\n"); // replace CRLF with LF
            var inputLine = 1;
            var inputCol = 1;

            curScore.startCmd(); // so that user can undo change made by plugin

            var cursor = curScore.newCursor();
            cursor.rewind(Cursor.SCORE_START);

            while (input.length > 0) {
                var matchInt = input.match(/^([0-9]+)([\s\S]*)/);

                if (!matchInt) {
                    console.log(qsTr("%1:%2: Not an integer '%3'").arg(inputLine).arg(inputCol).arg(input));
                    break;
                    }

                // console.log(qsTr("%1:%2: Integer '%3'").arg(inputLine).arg(inputCol).arg(matchInt[1]));
                var numMeasures = parseInt(matchInt[1]);
                inputCol += matchInt[1].length;
                input = matchInt[2];

                var matchBreak = input.match(/^( |\n+)([\s\S]*)/);

                if (!matchBreak) {
                    console.log(qsTr("%1:%2: Not a break '%3'").arg(inputLine).arg(inputCol).arg(input));
                    break;
                    }

                // console.log(qsTr("%1:%2: Break '%3'").arg(inputLine).arg(inputCol).arg(matchBreak[1]));
                var lb = newElement(Element.LAYOUT_BREAK);
                input = matchBreak[2];

                if (matchBreak[1] == " ") {
                    inputCol++;
                    lb.layoutBreakType = LayoutBreak.LINE;
                    }
                else {
                    inputLine += matchBreak[1].length;
                    inputCol = 1;
                    if (matchBreak[1] == "\n")
                        lb.layoutBreakType = LayoutBreak.PAGE;
                    else
                        lb.layoutBreakType = LayoutBreak.SECTION;
                    }
                console.log(qsTr("Skip %1 measures and add a %2 break").arg(numMeasures).arg(layoutBreakToStr(lb)));
                if (!advanceMeasures(cursor, numMeasures - 1))
                    break; // reached end of score
                cursor.add(lb);
                if (!advanceMeasures(cursor, 1))
                    break; // reached end of score
                }

            curScore.endCmd(); // so that user can undo change made by plugin
            }
        }

    Button {
        id : buttonCancel
        text: qsTr("Cancel")
        anchors.bottom: window.bottom
        anchors.right: buttonConvert.left
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        onClicked: {
                Qt.quit();
            }
        }
    }
