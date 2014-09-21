/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Rectangle{
    id: root

    property var allDayEvents;
    property var startDay: DateExt.today();
    property var model;

    property int type: ViewType.ViewTypeWeek

    height: units.gu(6)
    width: parent.width
    color: "#C8C8C8"

    function getAllDayEvents(startDate, endDate) {
        var map = {};
        var items = model.getItems(startDate,endDate);
        for(var i = 0 ; i < items.length ; ++i) {
            var event = items[(i)];
            if( event && event.allDay ) {
                var key  = Qt.formatDateTime(event.startDateTime, "dd-MMM-yyyy");
                if( !(key in map)) {
                    map[key] = [];
                }
                map[key].push(event);
            }
        }
        return map;
    }

    function createAllDayEvents() {
        if(!startDay || startDay === undefined) {
            return;
        }
        var sd = startDay.midnight();
        var ed = sd.addDays( (type == ViewType.ViewTypeDay) ? 1 : 7);
        allDayEvents = getAllDayEvents(sd,ed);
    }

    Row {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        Repeater{
            model: type == ViewType.ViewTypeWeek ? 7 : 1
            delegate: Label{
                id: allDayLabel

                property var events;

                clip: true
                width: parent.width/ (type == ViewType.ViewTypeWeek ? 7 : 1)
                horizontalAlignment: Text.AlignHCenter

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if(!allDayLabel.events || allDayLabel.events.length === 0) {
                            return;
                        }

                        if(type == ViewType.ViewTypeWeek) {
                            PopupUtils.open(popoverComponent, root,{"events": allDayLabel.events})
                        } else {
                            if( allDayLabel.events.length > 1 ) {
                                PopupUtils.open(popoverComponent, root,{"events": allDayLabel.events})
                            } else {
                                pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":allDayLabel.events[0],"model": root.model});
                            }
                        }
                    }
                }

                Connections{
                    target: root
                    onAllDayEventsChanged:{
                        var sd = startDay.midnight();
                        sd = sd.addDays(index);
                        var key  = Qt.formatDateTime(sd, "dd-MMM-yyyy");
                        events = allDayEvents[key];

                        if(!events || events.length === 0) {
                            text = "";
                            return;
                        }

                        if(type == ViewType.ViewTypeWeek) {
                            // TRANSLATORS: the first parameter refers to the number of all-day events
                            // on a given day. "Ev." is short form for "Events".
                            // Please keep the translation of "Ev." to 3 characters only, as the week view
                            // where it's shown has limited space
                            text =  i18n.tr("%1 Ev.").arg(events.length)
                        } else {
                            if( events.length > 1) {
                                text = i18n.tr("%1 All day event", "%1 All day events", events.length).arg(events.length)
                            } else {
                                text = events[0].displayLabel;
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: popoverComponent

        Popover {
            id: popover

            property var events;

            ListView{
                id: allDayEventsList

                property var delegateHight: units.gu(4);
                property int maxEventToDisplay: 3;

                clip: true
                visible: true
                width: parent.width
                height: ( delegateHight * (events.length > maxEventToDisplay ? maxEventToDisplay : events.length) ) + units.gu(1)
                model: popover.events
                anchors {
                    top: parent.top; topMargin: units.gu(1); bottomMargin: units.gu(1)
                }

                delegate: Label{
                    text: modelData.displayLabel;
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "black"
                    height: allDayEventsList.delegateHight

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            popover.hide();
                            pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":modelData,"model": root.model});
                        }
                    }
                }
            }
        }
    }
}
