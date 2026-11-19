// Today's events from DMS's CalendarService (dcal backend).
// Reads what the calendar card already loaded; it doesn't call loadEvents itself,
// so it never replaces the calendar card's month range.
import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Modules.Plugins
import qs.Modules.DDash

DashCardComponent {
    id: root

    readonly property var events: {
        CalendarService.eventsByDate; // re-evaluate when events reload
        if (!CalendarService.calendarAvailable)
            return [];
        return CalendarService.getEventsForDate(clock.date).slice().sort((a, b) => a.start - b.start);
    }
    readonly property string timeFormat: SettingsData.use24HourClock ? "HH:mm" : "h:mm AP"

    function timeText(ev) {
        if (ev.allDay)
            return "All day";
        return Qt.formatTime(ev.start, timeFormat) + " – " + Qt.formatTime(ev.end, timeFormat);
    }

    SystemClock {
        id: clock
        enabled: root.live
        precision: SystemClock.Minutes
    }

    StyledText {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        text: "Today · " + Qt.formatDate(clock.date, "ddd d MMM")
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Theme.fontWeightMedium
        color: root.mutedColor
        elide: Text.ElideRight
    }

    StyledText {
        anchors.centerIn: parent
        visible: root.events.length === 0
        text: "No events"
        font.pixelSize: Theme.fontSizeMedium
        color: root.mutedColor
    }

    ListView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: Theme.spacingS
        anchors.bottom: parent.bottom
        clip: true
        spacing: Theme.spacingS
        model: root.events

        delegate: Row {
            required property var modelData
            width: ListView.view.width
            spacing: Theme.spacingS

            Rectangle {
                width: 4
                height: info.height
                radius: 2
                color: modelData.color?.length ? modelData.color : root.accentColor
            }

            Column {
                id: info
                width: parent.width - 4 - Theme.spacingS

                StyledText {
                    width: parent.width
                    text: modelData.title
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.contentColor
                    elide: Text.ElideRight
                }

                StyledText {
                    width: parent.width
                    text: root.timeText(modelData) + (modelData.location ? " · " + modelData.location : "")
                    font.pixelSize: Theme.fontSizeSmall
                    color: root.mutedColor
                    elide: Text.ElideRight
                }
            }
        }
    }
}
