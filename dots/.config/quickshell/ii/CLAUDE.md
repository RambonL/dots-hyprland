# Quickshell II

Stack: Quickshell + QML/JS + Hyprland. Entry point: `shell.qml`.

## Projektstruktur

```
shell.qml                  — Einstiegspunkt, importiert services/ + panelFamilies/
services/                  — Globale Singletons (Daten, keine UI)
modules/common/            — Shared: Appearance, Config, Widgets
modules/ii/bar/            — Horizontal Bar Komponenten
modules/ii/verticalBar/    — Vertical Bar Variante
modules/ii/sidebarLeft/    — Linke Sidebar
modules/ii/sidebarRight/   — Rechte Sidebar
modules/waffle/            — Alternative Panel-Familie
scripts/                   — Externe Shell/Python-Scripts
assets/                    — Icons, Bilder
translations/              — i18n-Strings
```

## Module-Imports

```qml
import qs.modules.common         // Appearance, Config, Translation, GlobalStates
import qs.modules.common.widgets // MaterialSymbol, StyledText, StyledPopup, ...
import qs.services               // Battery, Network, MullvadVpn, BatteryUsage, ...
```

Kein `qmldir` nötig — Quickshell auto-discovers alle `.qml` in importierten Verzeichnissen.

## Services (services/)

Alle `pragma Singleton` — global verfügbar nach `import qs.services`.

| Service | Was es tut |
|---------|-----------|
| `Battery.qml` | Laptop-Akku via UPower DBus |
| `BatteryUsage.qml` | Maus/Tastatur-Akku via `/usr/local/bin/get-device-batteries.sh` (60s Poll) |
| `MullvadVpn.qml` | VPN-Status via `mullvad status --json` (10s Poll, 500ms Burst nach Aktion) |
| `Network.qml` | WiFi/Ethernet via nmcli |
| `BluetoothStatus.qml` | Bluetooth via Quickshell Bluetooth API |
| `Audio.qml` | Lautstärke/Mute |
| `ResourceUsage.qml` | CPU/RAM/Swap |
| `Notifications.qml` | Benachrichtigungen |

### Service-Pattern (Timer + Process + StdioCollector)

```qml
pragma Singleton
Singleton {
    property string value: ""
    Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { proc.running = false; proc.running = true }
    }
    Process {
        id: proc
        command: ["some-cli", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                const data = JSON.parse(text.trim())
                // update properties
            }
        }
    }
}
```

## Bar (modules/ii/bar/)

### Layout (BarContent.qml)

```
LEFT                    MIDDLE                        RIGHT
[SidebarBtn][ActiveWin] [Resources][Workspaces][Clock] [Weather][VPN][SysTray][Indicators▼]
```

- **Mittlere Section**: `layoutDirection` normal, 3 BarGroups
- **Rechte Section** (`rightSectionRowLayout`): `layoutDirection: Qt.RightToLeft`
  - Code-Reihenfolge = visual rechts→links
  - `rightSidebarButton` (ganz rechts) → `MullvadIndicator` → `SysTray` → fill → `Weather`

### Bar-Indikator Pattern

```qml
// FooIndicator.qml
MouseArea {
    id: root
    implicitWidth: row.implicitWidth + row.anchors.leftMargin + row.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: !Config.options.bar.tooltips.clickToShow
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onPressed: mouse => {
        if (mouse.button === Qt.RightButton) FooService.doSomething()
        else FooService.toggle()
    }
    RowLayout {
        id: row
        anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4
        MaterialSymbol { text: "icon_name"; iconSize: Appearance.font.pixelSize.larger; color: Appearance.colors.colOnLayer0 }
    }
    FooPopup { hoverTarget: root }
}
```

### Popup Pattern

```qml
// FooPopup.qml
StyledPopup {
    Column {
        anchors.centerIn: parent
        spacing: 8
        StyledPopupHeaderRow { icon: "icon"; label: "Titel" }
        Column {
            spacing: 4
            StyledPopupValueRow { icon: "icon"; label: "Label:"; value: "Wert" }
        }
    }
}
```

`StyledPopup` hat `hoverTarget` Property — zeigt bei `containsMouse` automatisch.

### Indicators (rechte Sidebar-Button)

Icons in `indicatorsRowLayout` in `rightSidebarButton`.  
Pattern: `Revealer { reveal: condition; MaterialSymbol { color: rightSidebarButton.colText } }`  
Kein eigener Klick-Handler — öffnen alle die rechte Sidebar.

## Wichtige Common-Properties

```qml
Appearance.sizes.barHeight          // Bar-Höhe
Appearance.font.pixelSize.larger    // Icon-Schriftgröße
Appearance.colors.colOnLayer0       // Standard-Textfarbe (weiß im Dark Mode)
Appearance.colors.colPrimary        // Accent-Farbe
Appearance.m3colors.m3error         // Fehler-Rot
Appearance.rounding.small           // Border-Radius klein
Config.options.bar.tooltips.clickToShow  // Popup bei Klick statt Hover
Translation.tr("Text")              // Übersetzungsfunktion
```

## Eigene Komponenten

### MullvadVpn (services/MullvadVpn.qml)

Pollt `mullvad status --json` alle 10s, nach Aktionen 500ms Burst (20× max).

| Property | Typ | Bedeutung |
|----------|-----|-----------|
| `state` | string | `"connected"` / `"disconnected"` / `"connecting"` |
| `connected` | bool | `state === "connected"` |
| `country` | string | z.B. `"Germany"` |
| `city` | string | z.B. `"Berlin"` |
| `server` | string | z.B. `"de-ber-wg-007"` |
| `ip` | string | Sichtbare IP |
| `quantumResistant` | bool | Quantum-Verschlüsselung aktiv |
| `countryList` | var | `["de", "tr", "se"]` — Länderliste für MMB-Cycling |

| Funktion | Auslöser | Was |
|----------|----------|-----|
| `toggle()` | LMB | connect / disconnect |
| `nextRelay()` | RMB | `mullvad reconnect` (neuer Server, gleiches Land) |
| `nextCountry()` | MMB | Nächstes Land aus `countryList` |

### MullvadIndicator (modules/ii/bar/MullvadIndicator.qml)

Icon: `lock` (connected) / `lock_open` (disconnected). Farbe immer `colOnLayer0`.

### MullvadPopup (modules/ii/bar/MullvadPopup.qml)

Zeigt: Status (farbig), Location, Server, IP, Quantum Resistance.  
Location/Server/IP/Quantum nur sichtbar wenn connected.

## Externe Scripts

| Script | Zweck |
|--------|-------|
| `/usr/local/bin/get-device-batteries.sh` | Maus + Tastatur Akku → JSON |
| `/usr/local/bin/compx-battery-raw.py` | Compx Tastatur via HID (sudo) |

## Hinweise

- **Kein `qmldir`** — neue `.qml` Dateien einfach in den richtigen Ordner legen
- **Singletons** brauchen `pragma Singleton` + `Singleton { }` als Root
- **Modifier-Check in Maus-Events**: `onPressed` statt `onClicked` — Modifier beim Drücken zuverlässig, nicht beim Loslassen
- **StyledPopup Screen-Clamping**: `StyledPopup.qml` gepatcht um Overflow auf zweiten Monitor zu verhindern (`left` margin geclampt auf `screenWidth - popupWidth`)
- **RTL-Layouts**: In `rightSectionRowLayout` gilt `layoutDirection: Qt.RightToLeft` — erste Komponente im Code = ganz rechts visuell
