pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string state: "unknown"
    readonly property bool connected: state === "connected"
    property string country: ""
    property string city: ""
    property string server: ""
    property string ip: ""
    property bool quantumResistant: false
    property bool toggling: false

    property int _pendingPolls: 0

    function _startFastPoll() {
        _pendingPolls = 20
        actionPollTimer.start()
    }

    function toggle(): void {
        if (toggling) return
        toggling = true
        toggleProcess.command = root.connected ? ["mullvad", "disconnect"] : ["mullvad", "connect"]
        toggleProcess.running = false
        toggleProcess.running = true
    }

    function nextRelay(): void {
        if (!connected) return
        reconnectProcess.running = false
        reconnectProcess.running = true
    }

    readonly property var countryList: ["de", "tr", "se"]

    function nextCountry(): void {
        if (!connected) return
        const current = root.server.split('-')[0]
        const idx = countryList.indexOf(current)
        const next = countryList[(idx + 1) % countryList.length]
        setCountryProcess.command = ["mullvad", "relay", "set", "location", next]
        setCountryProcess.running = false
        setCountryProcess.running = true
    }

    Process {
        id: setCountryProcess
        onExited: {
            reconnectProcess.running = false
            reconnectProcess.running = true
        }
    }

    Process {
        id: toggleProcess
        onExited: {
            root.toggling = false
            root._startFastPoll()
        }
    }

    Process {
        id: reconnectProcess
        command: ["mullvad", "reconnect"]
        onExited: root._startFastPoll()
    }

    Timer {
        id: actionPollTimer
        interval: 500
        repeat: true
        onTriggered: {
            statusProcess.running = false
            statusProcess.running = true
            if (--root._pendingPolls <= 0)
                stop()
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statusProcess.running = false
            statusProcess.running = true
        }
    }

    Process {
        id: statusProcess
        command: ["mullvad", "status", "--json"]

        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                try {
                    const jsonString = outputCollector.text.trim()
                    if (!jsonString) return

                    const data = JSON.parse(jsonString)
                    root.state = data.state ?? "unknown"

                    const details = data.details
                    if (details) {
                        const loc = details.location
                        if (loc) {
                            root.country = loc.country ?? ""
                            root.city = loc.city ?? ""
                            root.server = loc.hostname ?? ""
                            root.ip = loc.ipv4 ?? ""
                        }
                        const ep = details.endpoint
                        if (ep) {
                            root.quantumResistant = ep.quantum_resistant ?? false
                        }
                    } else {
                        root.country = ""
                        root.city = ""
                        root.server = ""
                        root.ip = ""
                        root.quantumResistant = false
                    }
                } catch (err) {
                    console.error("MullvadVpn: parse error:", err, "output:", outputCollector.text)
                }
            }
        }
    }
}
