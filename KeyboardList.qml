import QtQuick
import qs.Commons
import qs.Ui

// The layout list shown inside the PopupCard dropdown. Includes a header
// showing the current layout, the full layout list, and a "+ add" affordance
// that expands an inline form for adding a custom keyboard language.
Rectangle {
  id: root

  property var service: null
  property bool showAddForm: false
  property real contentH: 340
  readonly property real addFormH: 168
  readonly property real listH: Math.max(70, contentH - root.headerH - root.addFormH - 40 - 8)

  readonly property var layouts: service ? service.layouts : []
  readonly property string current: service ? service.currentLayout : ""
  readonly property int headerH: 30

  color: "transparent"

  Column {
    anchors.fill: parent
    anchors.margins: 6
    spacing: 4

    // ---- Header: current layout ----
    Rectangle {
      width: parent.width
      height: root.headerH
      radius: 6
      color: Qt.rgba(1, 1, 1, 0.08)

      Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: root.current.toUpperCase()
          color: Color.popups.text
          font.pixelSize: 12
          font.bold: true
          font.family: Style.fontFamily
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "Current layout"
          color: Color.popups.text
          opacity: 0.6
          font.pixelSize: 11
          font.family: Style.fontFamily
        }
      }
    }

    Rectangle { width: parent.width; height: 1; color: Color.popups.border }

    // ---- Add-language form (expanded) ----
    Rectangle {
      visible: root.showAddForm
      width: parent.width
      height: root.addFormH
      radius: 6
      border.width: 1
      border.color: Color.popups.border

      Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Text {
          text: "Add keyboard language"
          color: Color.popups.text
          font.pixelSize: 12
          font.bold: true
          font.family: Style.fontFamily
        }

        // Layout code
        TextField {
          id: codeField
          width: parent.width
          height: 26
          verticalPadding: 4
          horizontalPadding: 8
          placeholderText: "Code (e.g. de, fr, ru)"
          font.pixelSize: 12
          foreground: Color.popups.text
        }

        // Display name
        TextField {
          id: nameField
          width: parent.width
          height: 26
          verticalPadding: 4
          horizontalPadding: 8
          placeholderText: "Name (e.g. German)"
          font.pixelSize: 12
          foreground: Color.popups.text
        }

        // Status + actions
        Text {
          visible: service && service.addStatus && service.addStatus.length > 0
          text: service ? service.addStatus : ""
          color: service && service.addStatus && service.addStatus.indexOf("Error") !== -1 ? Color.urgent : Color.accent
          font.pixelSize: 11
          font.family: Style.fontFamily
          wrapMode: Text.WordWrap
          width: parent.width
        }

        Row {
          spacing: 8
          anchors.right: parent.right

          Rectangle {
            width: cancelLbl.implicitWidth + 16
            height: 24
            radius: 4
            color: cancelM.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.06)

            Text {
              id: cancelLbl
              anchors.centerIn: parent
              text: "Cancel"
              color: Color.popups.text
              font.pixelSize: 11
              font.family: Style.fontFamily
            }

            MouseArea {
              id: cancelM
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                root.showAddForm = false
                if (service) service.addStatus = ""
              }
            }
          }

          Rectangle {
            width: addLbl.implicitWidth + 16
            height: 24
            radius: 4
            color: Color.accent

            Text {
              id: addLbl
              anchors.centerIn: parent
              text: "Add"
              color: Color.background
              font.pixelSize: 11
              font.bold: true
              font.family: Style.fontFamily
            }

            MouseArea {
              anchors.fill: parent
              onClicked: {
                if (service)
                  service.addCustomLayout(codeField.text, nameField.text)
              }
            }
          }
        }
      }
    }

    Rectangle { visible: root.showAddForm; width: parent.width; height: 1; color: Color.popups.border }

    // ---- Scrollable layout list ----
    Flickable {
      width: parent.width
      height: root.listH
      contentHeight: listCol.implicitHeight
      clip: true
      flickableDirection: Flickable.VerticalFlick

      Column {
        id: listCol
        width: parent.width
        spacing: 2

        Repeater {
          model: root.layouts

          delegate: Rectangle {
            required property var modelData
            required property int index

            readonly property bool isCurrent: modelData.code === root.current
            readonly property bool isCustom: root.service ? root.service.isCustom(modelData.code) : false

            width: listCol.width
            height: 30
            radius: 4
            color: {
              if (isCurrent) return Qt.rgba(1, 1, 1, 0.15)
              return rowMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
            }

            Row {
              anchors.fill: parent
              anchors.leftMargin: 8
              anchors.rightMargin: 8
              spacing: 8

              Rectangle {
                width: 22
                height: 22
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: isCurrent ? Color.accent : Qt.rgba(1, 1, 1, 0.1)

                Text {
                  anchors.centerIn: parent
                  text: {
                    var nm = modelData.name || ""
                    return nm.length >= 2 ? nm.slice(0, 2).toUpperCase() : (modelData.code || "??").toUpperCase().slice(0, 2)
                  }
                  color: "white"
                  font.pixelSize: 9
                  font.bold: true
                  font.family: Style.fontFamily
                }
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 62
                text: modelData.name || modelData.code
                color: Color.popups.text
                font.pixelSize: 12
                font.family: Style.fontFamily
                elide: Text.ElideRight
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                horizontalAlignment: Text.AlignHCenter
                visible: isCurrent
                text: "✓"
                color: Color.accent
                font.pixelSize: 12
                font.family: Style.fontFamily
              }

              // Remove button for custom layouts only
              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                horizontalAlignment: Text.AlignHCenter
                visible: isCustom && !isCurrent
                text: "✕"
                color: Color.muted
                font.pixelSize: 12
                font.family: Style.fontFamily

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    if (root.service) root.service.removeCustomLayout(modelData.code)
                  }
                }
              }
            }

            MouseArea {
              id: rowMouse
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                if (root.service) root.service.switchLayout(modelData.code)
              }
            }
          }
        }
      }
    }

    Rectangle { width: parent.width; height: 1; color: Color.popups.border }

    // ---- "+ Add language" button ----
    Rectangle {
      width: parent.width
      height: 26
      radius: 4
      color: addBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.06)

      Text {
        anchors.centerIn: parent
        text: "+  Add language"
        color: Color.popups.text
        font.pixelSize: 12
        font.family: Style.fontFamily
      }

      MouseArea {
        id: addBtnMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          root.showAddForm = !root.showAddForm
          if (service) service.addStatus = ""
        }
      }
    }
  }
}
