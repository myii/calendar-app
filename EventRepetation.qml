import QtQuick 2.3
import QtOrganizer 5.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Themes.Ambiance 1.0
import Ubuntu.Components.Pickers 1.0
import QtOrganizer 5.0
import "Defines.js" as Defines
Page {
    id: repetation
    title: i18n.tr("Repeat")
    property var weekDays : [];
    property var rule
    property var date
    property var isEdit
    EventUtils{
        id:eventUtils
    }

    Component.onCompleted: {
        //Fill Date & limitcount if any
        var index = 0;
        index =  rule.frequency ;
        if(index > 0 )
        {
            if(rule.limit !== undefined){
                var temp = rule.limit;
                if(parseInt(temp)){
                    limitOptions.selectedIndex = 1;
                    limitCount.value = temp;
                }
                else{
                    limitOptions.selectedIndex = 2;
                    datePick.date= temp;
                }
            }
            else{
                // If limit is infinite
                limitOptions.selectedIndex = 0;
            }
            switch(index){
            case RecurrenceRule.Weekly:
                index = eventUtils.getWeekDaysIndex(rule.daysOfWeek.sort());
                if(rule.daysOfWeek.length>0 && index === 5){
                    for(var j = 0;j<rule.daysOfWeek.length;++j){
                        //Start childern after first element.
                        weeksRow.children[rule.daysOfWeek[j] === 7 ? 0 :rule.daysOfWeek[j]].children[1].checked = true;
                    }
                }
                break;
            case RecurrenceRule.Monthly:
                index = 6
                break;
            case RecurrenceRule.Yearly:
                index = 7
                break;
            }
            recurrenceOption.selectedIndex = index;
        }

    }
    visible: false

    head.backAction: Action{
        id:backAction
        iconName: "back"
        onTriggered: {
            var recurrenceRule = Defines.recurrenceValue[ recurrenceOption.selectedIndex ];
            console.log(recurrenceRule);
            console.log("Invalid "  + RecurrenceRule.Daily)
            if( recurrenceRule !== RecurrenceRule.Invalid ) {
                rule.frequency = recurrenceRule;
                if(limitOptions.selectedIndex > 0) {
                    rule.daysOfWeek = eventUtils.getDaysOfWeek(recurrenceOption.selectedIndex,weekDays );
                    if(limitOptions.selectedIndex === 1 && recurrenceOption.selectedIndex > 0){
                        rule.limit =  parseInt(limitCount.value);
                    }
                    else if(limitOptions.selectedIndex === 2 && recurrenceOption.selectedIndex > 0){
                        rule.limit =  datePick.date;
                    }
                    else{
                        rule.limit = undefined;
                    }
                }
            }
            else{
                rule.frequency = 0
            }
            console.log("Frq  " + rule.frequency )
            pop()
        }
    }
    Column{
        id:repeatColumn
        anchors {
            fill: parent
            margins: units.gu(2)
        }

        spacing: units.gu(1)
        ListItem.Header{
            text: i18n.tr("Repeat")
        }
        OptionSelector{
            id: recurrenceOption
            visible: true
            width: parent.width
            model: Defines.recurrenceLabel
            containerHeight: itemHeight * 4
            onExpandedChanged: Qt.inputMethod.hide();
            //selectedIndex: selectedReccurence === undefined ? 0 : selectedReccurence
        }

        ListItem.Header{
            text: i18n.tr("Repeats On:")
            visible: recurrenceOption.selectedIndex == 5
        }
        Row {
            id: weeksRow
            width: parent.width
            spacing: units.gu(2)
            visible: recurrenceOption.selectedIndex == 5
            Repeater {
                model: Defines.weekLabel
                Column {
                    id: weeksRowColumn
                    spacing: units.gu(1)
                    Label {
                        id:lbl
                        text:modelData
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    CheckBox {
                        id: weekCheck
                        onCheckedChanged: {
                            //EDS consider 7 as Sunday index so if the index is 0 then we have to explicitly push Sunday.
                            if(index === 0)
                                (checked) ? weekDays.push(Qt.Sunday) : weekDays.splice(weekDays.indexOf(Qt.Sunday),1);
                            else
                                (checked) ? weekDays.push(index) : weekDays.splice(weekDays.indexOf(index),1);
                        }
                        checked:{
                            (weekDays.length === 0 && index === date.getDay() && isEdit== false) ? true : false;
                        }

                    }
                }
            }
        }
        ListItem.Header {
            text: i18n.tr("Recurring event ends")
            visible: recurrenceOption.selectedIndex != 0
        }

        OptionSelector{
            id: limitOptions
            visible: recurrenceOption.selectedIndex != 0
            width: parent.width
            model: Defines.limitLabel
            containerHeight: itemHeight * 4
            onExpandedChanged:   Qt.inputMethod.hide();

        }
        ListItem.Header{
            text:i18n.tr("Recurrences")
            visible:  recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex == 1;
        }
        Slider{
            id:limitCount
            live:true
            width: parent.width
            objectName:"limitCount"
            visible:  recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex == 1;
            minimumValue: 1
            maximumValue: 50
            onValueChanged: {
                backAction.enabled = value !== 1 ? true :false
            }

        }

        ListItem.Header{
            text:i18n.tr("Date")
            visible:  recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex == 2;
        }
        Item {
            id: limitDate
            width: parent.width
            height: datePick.height
            visible: recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex===2;
            DatePicker{
                id:datePick;
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }

    }
}
