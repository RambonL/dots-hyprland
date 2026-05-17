import qs.modules.common
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool alwaysShowAllResources: false
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    RowLayout {
        id: rowLayout

        spacing: 0
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        BatteryRessource {
            iconName: "battery_android_frame_bolt"
            percentage: BatteryUsage.mouseBattery / 100
            warningThreshold: Config.options.bar.resources.memoryWarningThreshold
        }
    }

    DevicesBatteryPopup {
        hoverTarget: root
    }
}
