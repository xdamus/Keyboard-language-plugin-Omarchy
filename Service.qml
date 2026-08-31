import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var manifest: null

  property string currentLayout: "us"
  property var layouts: []
  property string lastError: ""

  readonly property string pluginDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir)
    : (Quickshell.env("HOME") + "/.config/omarchy/plugins/damus.keyboard-switcher")

  function switchLayout(layoutCode) {
    if (!layoutCode || layoutCode.length < 2 || layoutCode.length > 10) {
      root.lastError = "Invalid layout code"
      return
    }
    if (switchProc.running) return
    root.lastError = ""
    switchProc.command = [pluginDir + "/bin/switch-layout", layoutCode]
    switchProc.running = true
  }

  function refreshLayouts() {
    if (listProc.running) return
    listProc.running = true
  }

  function getCurrentLayout() {
    if (queryProc.running) return
    queryProc.running = true
  }

  function onDropdownOpen() {
    root.refreshLayouts()
    root.getCurrentLayout()
  }

  function getLayoutName(code) {
    if (!root.layouts || !code) return code
    for (var i = 0; i < root.layouts.length; i++) {
      if (root.layouts[i].code === code)
        return root.layouts[i].name
    }
    return code
  }

  function getInitials(code) {
    var name = root.getLayoutName(code)
    if (!name || !name.length) return "??"
    return name.slice(0, 2).toUpperCase()
  }

  Process {
    id: listProc
    command: [pluginDir + "/bin/list-layouts"]
    stdout: StdioCollector {
      onStreamFinished: {
        var trimmed = text.trim()
        if (!trimmed) return
        try {
          var parsed = JSON.parse(trimmed)
          if (Array.isArray(parsed) && parsed.length > 0)
            root.layouts = parsed
        } catch(e) {
          console.warn("keyboard-switcher: failed to parse layouts:", e)
        }
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim())
          console.warn("keyboard-switcher: list-layouts error:", text.trim())
      }
    }
  }

  Process {
    id: queryProc
    command: ["setxkbmap", "-query"]
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i].trim()
          if (line.indexOf("layout:") === 0) {
            var layout = line.split(":")[1].trim()
            if (layout && layout.length >= 2)
              root.currentLayout = layout
            break
          }
        }
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim())
          console.warn("keyboard-switcher: query error:", text.trim())
      }
    }
  }

  Process {
    id: switchProc
    stdout: StdioCollector {
      onStreamFinished: {
        var output = text.trim()
        if (output.indexOf("Switched to:") === 0)
          Qt.callLater(root.getCurrentLayout)
        else if (output)
          root.lastError = output
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim()) {
          root.lastError = text.trim()
          console.warn("keyboard-switcher: switch error:", text.trim())
        }
      }
    }
  }

  Timer {
    interval: 15000
    running: true
    repeat: true
    onTriggered: root.getCurrentLayout()
  }

  Component.onCompleted: {
    root.getCurrentLayout()
    root.refreshLayouts()
  }
}
