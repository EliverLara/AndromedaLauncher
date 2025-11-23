import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Item {
    property var textSize
    readonly property var textWidth: nameLabel.width
    Text {
        id: nameLabel
        text: plasmoid.configuration.enableGreeting && plasmoid.configuration.customGreeting ? plasmoid.configuration.customGreeting : plasmoid.configuration.enableGreeting ? i18n("Hi, %1", kuser.fullName): i18n("%1@%2", kuser.loginName, kuser.host)
        color: textColor
        font.family: textFont
        font.pixelSize: textSize
        font.bold: true
    }
    // Text shadow for greeting label
    DropShadow {
        anchors.fill: nameLabel
        cached: true
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10.0
        samples: 16
        color: glowColor1
        source: nameLabel
        visible: plasmoid.configuration.enableGlow
    }
}