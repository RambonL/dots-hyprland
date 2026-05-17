import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    implicitWidth: iconRow.implicitWidth + iconRow.anchors.leftMargin + iconRow.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: !Config.options.bar.tooltips.clickToShow
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onPressed: mouse => {
        if (mouse.button === Qt.RightButton)
            MullvadVpn.nextRelay()
        else if (mouse.button === Qt.MiddleButton)
            MullvadVpn.nextCountry()
        else if (mouse.button === Qt.LeftButton)
            MullvadVpn.toggle()
    }

    RowLayout {
        id: iconRow
        spacing: 0
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            text: MullvadVpn.connected ? "lock" : "lock_open"
            iconSize: Appearance.font.pixelSize.larger
            color: Appearance.colors.colOnLayer0
        }
    }

    MullvadPopup {
        hoverTarget: root
    }
}
