import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid 2.0

Rectangle {

    radius: 10
    color: main.contrastBgColor

    property alias textField: textField

    RowLayout {
        anchors.fill: parent
        spacing: 0
        Kirigami.Icon {
            id: searchIcon
            Layout.preferredWidth: 21
            Layout.preferredHeight: 21
            Layout.margins: 10
            source: Qt.resolvedUrl('icons/feather/search.svg')
            isMask: true
            color: main.textColor
        }

        TextField {
            id: textField
            Layout.fillHeight: true
            Layout.fillWidth: true
            font.pointSize: 12

            placeholderText: i18n("Search...")
            background: Rectangle{
                color: "transparent"
            }
            focus: true
            onTextChanged: {
                textField.forceActiveFocus(Qt.ShortcutFocusReason)
                runnerModel.query = text;   
            }

            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape) {
                    event.accepted = true;
                    if (searching) {
                        clear();
                    } else {
                        root.toggle()
                    }
                }
            }
        }
    }
}