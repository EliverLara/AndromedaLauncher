/*****************************************************************************
 *   Copyright (C) 2022 by Friedrich Schriewer <friedrich.schriewer@gmx.net> *
 *                                                                           *
 *   This program is free software; you can redistribute it and/or modify    *
 *   it under the terms of the GNU General Public License as published by    *
 *   the Free Software Foundation; either version 2 of the License, or       *
 *   (at your option) any later version.                                     *
 *                                                                           *
 *   This program is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 *   GNU General Public License for more details.                            *
 *                                                                           *
 *   You should have received a copy of the GNU General Public License       *
 *   along with this program; if not, write to the                           *
 *   Free Software Foundation, Inc.,                                         *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .          *
 ****************************************************************************/
import org.kde.plasma.core as PlasmaCore
import QtQuick
import org.kde.kcmutils as KCM

import org.kde.plasma.private.kicker as Kicker
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PC3
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
  property var iconSize
  width: iconSize * 3.55
  height: iconSize

  Kicker.SystemModel {
    id: systemModel
    favoritesModel: kicker.systemFavorites
  }

  component FilteredModel : KItemModels.KSortFilterProxyModel {
      sourceModel: systemModel

      function systemFavoritesContainsRow(sourceRow, sourceParent) {
          const FavoriteIdRole = sourceModel.KItemModels.KRoleNames.role("favoriteId");
          const favoriteId = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), FavoriteIdRole);
          return String(Plasmoid.configuration.systemFavorites).includes(favoriteId);
      }

      function trigger(index) {
          const sourceIndex = mapToSource(this.index(index, 0));
          systemModel.trigger(sourceIndex.row, "", null);
      }

      Component.onCompleted: {
          Plasmoid.configuration.valueChanged.connect((key, value) => {
              if (key === "systemFavorites") {
                  invalidateFilter();
              }
          });
      }
  }

  FilteredModel {
    id: filteredButtonsModel
    filterRowCallback: (sourceRow, sourceParent) =>
        systemFavoritesContainsRow(sourceRow, sourceParent)
  }

  FilteredModel {
      id: filteredMenuItemsModel
      filterRowCallback: root.shouldCollapseButtons
          ? null /*i.e. keep all rows*/
          : (sourceRow, sourceParent) => !systemFavoritesContainsRow(sourceRow, sourceParent)
  }

  PC3.RoundButton {
    id: settingsButton
    visible: true
    flat: true
    height: iconSize * 1.5
    width: height
    anchors.left: parent.left

    Kirigami.Icon {
        id: settingsImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.fill: parent
        source: Qt.resolvedUrl("icons/feather/stngs.svg")
        isMask: true
        color: main.textColor
    }
    onClicked: {
      KCM.KCMLauncher.openSystemSettings("kcm_landingpage")
      root.toggle()
    }
  }

  PC3.RoundButton {
      id: leaveButton
      Accessible.role: Accessible.ButtonMenu
      anchors.right: parent.right
      flat: true
      height: iconSize * 1.5
      width: height
      visible: true
      // Make it look pressed while the menu is open
      down: contextMenu.status === PlasmaExtras.Menu.Open || pressed
      Kirigami.Icon {
        id: powerImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.fill: parent
        source: Qt.resolvedUrl("icons/feather/pwr.svg")
        isMask: true
        color: Kirigami.Theme.textColor
      }

      Keys.onLeftPressed: event => {
          if (Qt.application.layoutDirection == Qt.LeftToRight) {
              nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
          }
      }
      Keys.onRightPressed: event => {
          if (Qt.application.layoutDirection == Qt.RightToLeft) {
              nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
          }
      }
      onPressed: contextMenu.openRelative()
  }

  Instantiator {
      model: filteredMenuItemsModel
      delegate: PlasmaExtras.MenuItem {
          required property int index
          required property var model

          text: model.display
          icon: model.decoration
          onClicked: {
            root.toggle();
            filteredMenuItemsModel.trigger(index);
          }
      }
      onObjectAdded: (index, object) => contextMenu.addMenuItem(object)
      onObjectRemoved: (index, object) => contextMenu.removeMenuItem(object)
  }

  PlasmaExtras.Menu {
      id: contextMenu
      visualParent: leaveButton
      placement: PlasmaExtras.Menu.BottomPosedLeftAlignedPopup
  }
}
