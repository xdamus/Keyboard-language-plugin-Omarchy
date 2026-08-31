import QtQuick
import qs.Commons
import qs.Ui

// The layout list shown inside the PopupCard dropdown.
Rectangle {
  id: root

  property var service: null

  readonly property var layouts: service ? service.layouts : []
  readonly property string current: service ? service.currentLayout : ""

  color: "transparent"

  Column {
    anchors.fill: parent
    anchors.margins: 6
    spacing: 4

    // Header with current layout
    Rectangle {
      width: parent.width
      height: 30
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

    // Scrollable layout list
    Flickable {
      width: parent.width
      height: Math.min(300, Math.max(60, root.height - 44))
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
                    var name = modelData.name || ""
                    return name.length >= 2 ? name.slice(0, 2).toUpperCase() : (modelData.code || "??").toUpperCase().slice(0, 2)
                  }
                  color: "white"
                  font.pixelSize: 9
                  font.bold: true
                  font.family: Style.fontFamily
                }
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 40
                text: modelData.name || modelData.code
                color: Color.popups.text
                font.pixelSize: 12
                font.family: Style.fontFamily
                elide: Text.ElideRight
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: isCurrent
                text: "✓"
                color: Color.accent
                font.pixelSize: 12
                font.family: Style.fontFamily
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
  }
}
