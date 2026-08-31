import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var manifest: null

  property string currentLayout: "us"
  property var layouts: []
  property var customLayouts: []
  property string lastError: ""
  property string addStatus: ""

  readonly property string pluginDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir)
    : (Quickshell.env("HOME") + "/.config/omarchy/plugins/damus.keyboard-switcher")

  function switchLayout(layoutCode) {
    if (!layoutCode || layoutCode.trim().length < 2 || layoutCode.trim().length > 10) {
      root.lastError = "Invalid layout code"
      return
    }
    if (switchProc.running) return
    root.lastError = ""
    switchProc.command = [pluginDir + "/bin/layouts-manager", "switch", layoutCode.trim()]
    switchProc.running = true
  }

  function refreshLayouts() {
    root.loadCustomLayouts()
  }

  function getCurrentLayout() {
    if (queryProc.running) return
    queryProc.running = true
  }

  function onDropdownOpen() {
    root.refreshLayouts()
    root.getCurrentLayout()
  }

  function loadCustomLayouts() {
    if (customProc.running) return
    customProc.running = true
  }

  function rebuild() {
    if (listProc.running) return
    listProc.running = true
  }

  function addCustomLayout(code, name) {
    if (!code || code.trim().length < 2 || code.trim().length > 10) {
      root.addStatus = "Invalid code (2-10 chars)"
      return false
    }
    if (!/^[A-Za-z0-9_-]+$/.test(code.trim())) {
      root.addStatus = "Code may only contain letters, numbers, - and _"
      return false
    }
    root.addStatus = ""
    addProc.command = [pluginDir + "/bin/custom-layouts", "add", code.trim(), (name || code).trim()]
    addProc.running = true
    return true
  }

  function removeCustomLayout(code) {
    if (!code) return
    removeProc.command = [pluginDir + "/bin/custom-layouts", "remove", code.trim()]
    removeProc.running = true
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

  function codeForName(name) {
    if (!name) return ""
    var nm = name.trim().toLowerCase()
    for (var i = 0; i < root.layouts.length; i++) {
      var lname = (root.layouts[i].name || "").toLowerCase()
      if (lname === nm) return root.layouts[i].code
      // tolerate "English (US)" vs short forms
      if (lname.indexOf(nm) !== -1 && nm.length >= 3) return root.layouts[i].code
    }
    return ""
  }

  function isCustom(code) {
    if (!root.customLayouts || !code) return false
    for (var i = 0; i < root.customLayouts.length; i++) {
      if (root.customLayouts[i].code === code)
        return true
    }
    return false
  }

  function mergeLayouts(base) {
    var customs = root.customLayouts || []
    var seen = {}
    var merged = []
    for (var i = 0; i < base.length; i++) {
      var b = base[i]
      if (!b || !b.code) continue
      seen[b.code] = true
      merged.push(b)
    }
    // Append custom layouts that aren't already in the built-in list.
    for (var j = 0; j < customs.length; j++) {
      var c = customs[j]
      if (!c || !c.code) continue
      if (seen[c.code]) continue
      seen[c.code] = true
      merged.push({ code: c.code, name: c.name || c.code, current: false, custom: true })
    }
    return merged
  }

  Process {
    id: listProc
    command: [pluginDir + "/bin/list-layouts"]
    stdout: StdioCollector {
      onStreamFinished: {
        var trimmed = text.trim()
        if (!trimmed) return
        try {
          var base = JSON.parse(trimmed)
          if (Array.isArray(base))
            root.layouts = root.mergeLayouts(base)
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
    id: customProc
    command: [pluginDir + "/bin/custom-layouts", "list"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var data = JSON.parse(text)
          root.customLayouts = Array.isArray(data.custom) ? data.custom : []
        } catch(e) {
          console.warn("keyboard-switcher: failed to parse custom layouts:", e)
        }
        rebuild()
      }
    }
  }

  Process {
    id: addProc
    stdout: StdioCollector {
      onStreamFinished: {
        var out = text.trim()
        root.addStatus = out ? out : "Added"
        root.loadCustomLayouts()
        root.onDropdownOpen()
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        root.addStatus = text.trim() || "Failed to add"
      }
    }
  }

  Process {
    id: removeProc
    stdout: StdioCollector {
      onStreamFinished: {
        root.loadCustomLayouts()
        root.onDropdownOpen()
      }
    }
  }

  Process {
    id: queryProc
    command: [pluginDir + "/bin/layouts-manager", "get"]
    stdout: StdioCollector {
      onStreamFinished: {
        // layouts-manager get prints the Hyprland display name, e.g. "German".
        var name = text.trim()
        if (!name) return
        var code = root.codeForName(name)
        if (code && code.length >= 2)
          root.currentLayout = code
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
        if (output.indexOf("Switched to:") === 0) {
          root.currentLayout = output.slice("Switched to: ".length).trim()
          Qt.callLater(root.refreshLayouts)
        } else if (output) {
          root.lastError = output
        }
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
