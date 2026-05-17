import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: 8

        StyledPopupHeaderRow {
            icon: "vpn_lock"
            label: "VPN"
        }

        Column {
            spacing: 4

            StyledPopupValueRow {
                icon: MullvadVpn.connected ? "lock" : "lock_open"
                label: Translation.tr("Status:")
                value: {
                    const color = MullvadVpn.connected ? "#50fa7b" : "#ff5555"
                    const text = MullvadVpn.connected ? Translation.tr("Connected") : Translation.tr("Disconnected")
                    return "<font color='" + color + "'>" + text + "</font>"
                }
            }

            StyledPopupValueRow {
                visible: MullvadVpn.connected && MullvadVpn.country !== ""
                icon: "public"
                label: Translation.tr("Location:")
                value: MullvadVpn.city ? MullvadVpn.city + ", " + MullvadVpn.country : MullvadVpn.country
            }

            StyledPopupValueRow {
                visible: MullvadVpn.connected && MullvadVpn.server !== ""
                icon: "dns"
                label: Translation.tr("Server:")
                value: MullvadVpn.server
            }

            StyledPopupValueRow {
                visible: MullvadVpn.connected && MullvadVpn.ip !== ""
                icon: "router"
                label: Translation.tr("IP:")
                value: MullvadVpn.ip
            }

            StyledPopupValueRow {
                visible: MullvadVpn.connected
                icon: "enhanced_encryption"
                label: Translation.tr("Quantum:")
                value: MullvadVpn.quantumResistant ? Translation.tr("Yes") : Translation.tr("No")
            }
        }
    }
}
