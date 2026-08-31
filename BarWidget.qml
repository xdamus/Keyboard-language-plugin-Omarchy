import Quickshell
import QtQuick
import QtQuick.Controls
import qs.Commons

PanelWindow {
    id: root

    property var shell: null
    property var manifest: null
    property var service: null

    implicitWidth: 48
    implicitHeight: 26

    color: "transparent"

    property bool menuOpen: false

    function getLayoutName(code) {
        if (!service || !service.layouts || !code) return ""
        for (var i = 0; i < service.layouts.length; i++) {
            if (service.layouts[i].code === code)
                return service.layouts[i].name
        }
        return ""
    }

    function getLayoutInitials(code) {
        var name = getLayoutName(code)
        if (!name && code) return code.toUpperCase().slice(0, 2)
        if (!name) return "??"
        return name.slice(0, 2).toUpperCase()
    }

    function closeMenu() {
        root.menuOpen = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: layoutMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.06)

        Row {
            anchors.centerIn: parent
            spacing: 4

            Text {
                id: layoutLabel
                text: service ? root.getLayoutInitials(service.currentLayout) : "??"
                color: Color.text
                font.pixelSize: 11
                font.family: Style.fontFamily
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "▼"
                color: Color.text
                font.pixelSize: 8
                opacity: 0.6
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: layoutMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.menuOpen = !root.menuOpen
        }
    }

    // Dropdown menu
    Rectangle {
        id: menu
        visible: root.menuOpen
        z: 100
        width: 220
        height: Math.min(menuContent.implicitHeight + 12, 400)
        radius: 6
        color: Color.popups.background
        border.width: 1
        border.color: Color.popups.border

        x: 0
        y: root.height + 4

        // Prevent clicks inside menu from closing it
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            id: menuContent
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2

            // Empty state
            Text {
                visible: !service || !service.layouts || service.layouts.length === 0
                text: "No layouts available"
                color: Color.text
                font.pixelSize: 12
                font.family: Style.fontFamily
                opacity: 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                height: 28
                verticalAlignment: Text.AlignVCenter
            }

            // Error state
            Rectangle {
                visible: service && service.lastError && service.lastError.length > 0
                width: parent.width
                height: 28
                radius: 4
                color: Qt.rgba(1, 0.3, 0.3, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: service ? service.lastError : ""
                    color: "#ef4444"
                    font.pixelSize: 11
                    font.family: Style.fontFamily
                    elide: Text.ElideRight
                    width: parent.width - 16
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Layout list
            Flickable {
                width: parent.width
                height: 370
                contentHeight: layoutRepeater.height
                clip: true
                flickableDirection: Flickable.VerticalFlick

                Column {
                    width: parent.width
                    spacing: 2

                    Repeater {
                        id: layoutRepeater
                        model: service ? service.layouts : []

                        Rectangle {
                            required property var modelData
                            required property int index

                            width: menuContent.width
                            height: 28
                            radius: 4
                            color: {
                                if (modelData.code === service.currentLayout)
                                    return Qt.rgba(1, 1, 1, 0.15)
                                return rowMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 4
                                    color: modelData.code === service.currentLayout ? "#3b82f6" : Qt.rgba(1, 1, 1, 0.1)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            var name = modelData.name || ""
                                            return name.length >= 2 ? name.slice(0, 2).toUpperCase() : modelData.code.toUpperCase().slice(0, 2)
                                        }
                                        color: "white"
                                        font.pixelSize: 9
                                        font.bold: true
                                        font.family: Style.fontFamily
                                    }
                                }

                                Text {
                                    text: modelData.name || modelData.code
                                    color: Color.text
                                    font.pixelSize: 12
                                    font.family: Style.fontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    width: parent.width - 36
                                }

                                Text {
                                    visible: modelData.code === service.currentLayout
                                    text: "✓"
                                    color: "#3b82f6"
                                    font.pixelSize: 12
                                    font.family: Style.fontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    service.switchLayout(modelData.code)
                                    root.closeMenu()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Close menu when clicking outside
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.closeMenu()
    }

    // Close on escape
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape && root.menuOpen) {
            root.closeMenu()
            event.accepted = true
        }
    }

    Component.onCompleted: {
        if (service) {
            service.getCurrentLayout()
            service.refreshLayouts()
        }
    }
}
