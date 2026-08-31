import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  // These are the only properties the bar host injects. Keep this entry
  // point as a plain Item, like other third-party bar widgets, to avoid
  // retaining a Bar QObject across registry replacement.
  property QtObject bar: null
  property string moduleName: "damus.keyboard-switcher"
  property var settings: ({})
  property var controller: null
  property color barForeground: Color.foreground
  property string barFontFamily: Style.font.family

  onBarChanged: {
    controller = bar && bar.shell ? bar.shell.serviceFor(moduleName) : null
    barForeground = bar ? bar.barForeground : Color.foreground
    barFontFamily = bar ? bar.fontFamily : Style.font.family
  }

  readonly property string labelText: controller
    ? controller.getInitials(controller.currentLayout)
    : "??"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // The bar's ModuleSlot owns the topmost pointer layer and forwards clicks to
  // this public target. Child MouseAreas are intentionally not reachable.
  function triggerPress(button) {
    if (button === Qt.LeftButton)
      popup.open = !popup.open
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.labelText
    fontSize: Style.font.caption
    horizontalMargin: 6
    tooltipText: controller ? controller.getLayoutName(controller.currentLayout) : ""
    onPressed: function() { root.triggerPress(Qt.LeftButton) }
  }

  PopupCard {
    id: popup
    anchorItem: button
    bar: root.bar
    triggerMode: "click"
    contentWidth: 220
    contentHeight: 360

    onOpenChanged: {
      if (open && controller) controller.onDropdownOpen()
    }

    KeyboardList {
      service: root.controller
    }
  }

  Component.onCompleted: {
    if (bar && bar.shell) controller = bar.shell.serviceFor(moduleName)
  }
}
