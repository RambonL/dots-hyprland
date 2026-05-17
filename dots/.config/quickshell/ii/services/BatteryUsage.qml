pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Polled battery service for mouse and keyboard.
 * Uses an external bash script that outputs JSON.
 */
Singleton {
    id: root
    
    // Akkustände
    property int mouseBattery: 0
    property int keyboardBattery: 0
    
    // Optional: Hilfreich, um im UI Icons auszugrauen, wenn das Gerät nicht verbunden/im JSON ist
    property bool mouseConnected: false
    property bool keyboardConnected: false

    // Historie (optional, falls du wie im Beispiel Graphen zeichnen willst)
    readonly property int historyLength: 60
    property list<int> mouseBatteryHistory: []
    property list<int> keyboardBatteryHistory: []

    // Update-Intervall in Millisekunden (hier: 60 Sekunden, da Akkus sich langsam leeren)
    property int updateInterval: 60000

    function updateHistories() {
        if (mouseConnected) {
            mouseBatteryHistory = [...mouseBatteryHistory, mouseBattery]
            if (mouseBatteryHistory.length > historyLength) mouseBatteryHistory.shift()
        }
        
        if (keyboardConnected) {
            keyboardBatteryHistory = [...keyboardBatteryHistory, keyboardBattery]
            if (keyboardBatteryHistory.length > historyLength) keyboardBatteryHistory.shift()
        }
    }

    Timer {
        interval: root.updateInterval
        running: true 
        repeat: true
        triggeredOnStart: true // Direkt beim Start einmal abfragen
        onTriggered: {
            // Prozess neustarten, um die aktuellsten Werte zu bekommen
            batteryProcess.running = false
            batteryProcess.running = true
        }
    }

    Process {
        id: batteryProcess
        command: ["/usr/local/bin/get-device-batteries.sh"]
        
        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                try {
                    const jsonString = outputCollector.text.trim()
                    if (!jsonString) return;

                    // Parse das JSON: {"mouse": 80, "keyboard": 100}
                    const data = JSON.parse(jsonString)

                    // Maus verarbeiten
                    if (data.mouse !== undefined) {
                        root.mouseBattery = Number(data.mouse)
                        root.mouseConnected = true
                    } else {
                        root.mouseConnected = false
                    }

                    // Tastatur verarbeiten
                    if (data.keyboard !== undefined) {
                        root.keyboardBattery = Number(data.keyboard)
                        root.keyboardConnected = true
                    } else {
                        root.keyboardConnected = false
                    }

                    // Historie aktualisieren
                    root.updateHistories()

                } catch (err) {
                    console.error("Fehler beim Parsen der Batterie-Daten:", err, "Output war:", outputCollector.text)
                }
            }
        }
    }
}