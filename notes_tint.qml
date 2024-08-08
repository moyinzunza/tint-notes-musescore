/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore BVBA and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3
import QtQuick.Controls 1.5
import Qt.labs.settings 1.0
import MuseScore 3.0
import "lists"

MuseScore {
	menuPath:		"Plugins." + qsTr("Tint notes")
	description:	qsTr("Change color of a notes")
	version:		"1.0"
	requiresScore:	true;
	property var	error: false;
	property var	cur;
	property bool	busy;
      property var selected: "#000000"

	
	
	Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title = "Tint Notes"
			categoryCode = "notes-color"
        }
    }//Component
	
	onRun: {
		cur = curScore.newCursor()
		cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
		tupletWindow.visible = true
	}
	
	function runPlugin() {
            selected = tuplet1D.model.get(tuplet1D.currentIndex).fact
		applyToNotesInSelection(colorNote)
		smartQuit()	
	}


      function applyToNotesInSelection(func) {
            var fullScore = !curScore.selection.elements.length
            if (fullScore) {
                  cmd("select-all")
            }
            curScore.startCmd()
            for (var i in curScore.selection.elements)
                  if (curScore.selection.elements[i].pitch)
                        func(curScore.selection.elements[i])
            curScore.endCmd()
            if (fullScore) {
                  cmd("escape")
            }
      }

      function colorNote(note) {
            note.color = selected;

            if (note.accidental) {
                  note.accidental.color = selected;
            }

            if (note.dots) {
                  for (var i = 0; i < note.dots.length; i++) {
                        if (note.dots[i]) {
                              note.dots[i].color = selected;
                        }
                  }
            }
      }

	
	
	ApplicationWindow {
		id: tupletWindow
		title: qsTr("Change Color")
		visible: false
		maximumHeight: tupletValues.height + buttonsRow.height + 30
		maximumWidth: Math.max(tupletValues.width, buttonsRow.width) + 20
		minimumHeight: tupletValues.height + buttonsRow.height + 30
		minimumWidth: Math.max(tupletValues.width, buttonsRow.width) + 20
		flags: Qt.Dialog
		
		ColumnLayout {
			id: tupletValues
			spacing: 10
			y: 10
			anchors.horizontalCenter: parent.horizontalCenter
			
			Label {text: qsTr("Select Color"); anchors.horizontalCenter: parent.horizontalCenter}
			
			RowLayout {
				id: top
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.margins: 5;
				anchors.leftMargin: 10;
				anchors.rightMargin: 10;
				
				
				ComboBox {id: tuplet1D; implicitWidth: 120; height: 30;
					currentIndex: 0; model: ColorListModel {}
				}//combobox
			}
			
		}//Column
		
		RowLayout {
			id: buttonsRow
			anchors.margins: 10;
			x: parent.width - (width+10);
			y: parent.height - (height+10);
			  
					
					
			Button {
				id: rightButton
				text: qsTr("Tint")
				enabled: ! invalid
				opacity: enabled ? 1.0 : 0.5
				onClicked: {
					tupletWindow.visible = false
					runPlugin()
				}
			}//rightbutton
		}//rowlayout
		
	}//dialog
	
	function smartQuit() {
		tupletWindow.visible = false
		if (mscoreMajorVersion < 4) {Qt.quit()}
		else {quit()}
	}//smartQuit
}//MuseScore
