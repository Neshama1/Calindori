/*
 *   Copyright 2018-2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property date todoDt
    property var calendar

    title: i18n("Tasks")

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("Add task")
        onTriggered: pageStack.push(todoEditor, {startDt: todoDt})
    }

    leftPadding: 0
    rightPadding: 0

    Component {
        id: todoEditor
        TodoEditor {
            calendar: localCalendar

            onEditcompleted: pageStack.pop(todoEditor)
        }
    }

    Controls2.Label {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: cardsListview.count == 0
        wrapMode: Text.WordWrap
        text: todoDt.toLocaleDateString() != "" ? i18n("No tasks scheduled for %1", todoDt.toLocaleDateString(Qt.locale(), Locale.ShortFormat)) : i18n("No tasks scheduled")
        font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
    }

    Kirigami.CardsListView {
        id: cardsListview

        anchors.fill: parent

        model: todosModel

        delegate: TodoCard {
            id: cardDelegate

            dataModel: model

            actions: [
                Kirigami.Action {
                    text: i18n("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        var vtodo = { "uid" : model.uid };
                        _todoController.remove(root.calendar, vtodo);
                    }
                },

                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "editor"

                    onTriggered: pageStack.push(todoEditor, { startDt: model.dtstart, uid: model.uid, incidenceData: model })
                }
            ]
        }
    }

    Calindori.IncidenceModel {
        id: todosModel

        filterDt: root.todoDt
        calendar: root.calendar
        filterMode: 6
    }
}