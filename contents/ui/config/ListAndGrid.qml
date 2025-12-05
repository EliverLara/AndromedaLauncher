import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM
import org.kde.kirigami 2.3 as Kirigami

KCM.SimpleKCM {

    property alias cfg_compactListItems: compactListItems.checked
    property alias cfg_showItemsInGrid: showItemsInGrid.checked
    property alias cfg_appsIconSize: appsIconSize.currentIndex
    property alias cfg_numberColumns: numberColumns.value
    property alias cfg_numberOfRows: numberOfRows.value
     Kirigami.FormLayout {
        CheckBox {
            id: compactListItems
            Kirigami.FormData.label: i18n("Lists:")
            text: i18n("Compact list items")
        }

        CheckBox {
            id: showItemsInGrid
            Kirigami.FormData.label: i18n("All applications view:")
            text: i18n("show items in grid")
        }

        ComboBox {
            id: appsIconSize
            Kirigami.FormData.label: i18n("Grid icon size:")
            model: [i18n("Small"),i18n("Medium"),i18n("Large"), i18n("Huge")]
        }

        SpinBox{
            id: numberColumns

            from: 4
            to: 8
            Kirigami.FormData.label: i18n("Number of columns in grid")
        }

         SpinBox{
            id: numberOfRows

            from: 3
            to: 8
            Kirigami.FormData.label: i18n("Number of rows in grid")
        }
      }
}