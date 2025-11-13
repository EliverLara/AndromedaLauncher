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
import QtQuick 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import QtQuick.Window 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kirigami as Kirigami
import QtQuick.Controls 2.15

import "../code/tools.js" as Tools

Item {
  id: favItem

  required property var model
  required property int index
  required property url url
  property var triggerModel

  width: root.cellSizeWidth
  height: root.cellSizeHeight

  signal itemActivated(int index, string actionId, string argument)
  signal actionTriggered(string actionId, variant actionArgument)
  signal aboutToShowActionMenu(variant actionMenu)

  property bool isDraging: false

  property bool hasActionList: ((model.favoriteId !== null)
      || (("hasActionList" in model) && (model.hasActionList !== null)))    

  property Item dragIconItem: appicon
  readonly property Flickable view: ListView.view ?? GridView.view

  z: Drag.active ? 4 : 1

  function openActionMenu(visualParent, x, y) {
    aboutToShowActionMenu(actionMenu);
    actionMenu.visualParent = visualParent;
    actionMenu.open(x, y);
  }

  function trigger() {
    triggerModel.trigger(index, "", null);
    root.toggle()
  }

  onAboutToShowActionMenu: actionMenu => {
        const actionList = (model.hasActionList !== null) ? model.actionList : [];
        Tools.fillActionMenu(i18n, actionMenu, actionList, globalFavorites, model.favoriteId);
    }
  onActionTriggered: (actionId, actionArgument) => {
      if (Tools.triggerAction(triggerModel, model.index, actionId, actionArgument) === true) {
            kicker.expanded = false;
        }
  }

  function performDrag(handler: DragHandler): void {
    if (!handler.active) {
      kicker.dragSource.Drag.active = false;
      kicker.dragSource.Drag.imageSource = "";
      kicker.dragSource.sourceItem = null;
      return;
    }
    favItem.dragIconItem.grabToImage(result => {
      if (!handler.active) {
        return;
      }
      kicker.dragSource.sourceItem = favItem;
      kicker.dragSource.Drag.imageSource = result.url;
      kicker.dragSource.Drag.mimeData = {
        "text/uri-list" : [favItem.url]
      };
      kicker.dragSource.Drag.active = handler.active;
    });
  }

 Kirigami.Icon {
    id: appicon
    y: (2 * highlightItemSvg.margins.top) 
    anchors.horizontalCenter: parent.horizontalCenter
    width: root.iconSize
    height: width
    source: model.decoration
  }

  PlasmaComponents.Label {
    id: appname
    text: ("name" in model ? model.name : model.display)
    font.family: main.textFont
    font.pointSize: main.textSize
    color: main.textColor
    anchors {
      top: appicon.bottom
      left: parent.left
      right: parent.right
      topMargin: Kirigami.Units.smallSpacing
      leftMargin: Kirigami.Units.smallSpacing
      rightMargin: Kirigami.Units.smallSpacing
    }
    textFormat: Text.PlainText
    elide: Text.ElideMiddle
    horizontalAlignment: Text.AlignHCenter
    maximumLineCount: 2
    wrapMode: Text.Wrap
  }

  DropShadow {
    id:appIconGlow
    visible: plasmoid.configuration.enableGlow
    anchors.fill: appicon
    cached: true
    horizontalOffset: 0
    verticalOffset: 0
    radius: 15.0
    samples: 16
    color: main.glowColor1
    source: appicon
    states: [
      State {
        name: "highlight"; when: (focus)
        PropertyChanges { target: appIconGlow; opacity: 1}
         PropertyChanges { target: appNameGlow; opacity: 1}
      },
      State {
        name: "default"; when: (!focus)
        PropertyChanges { target: appIconGlow; opacity: 0}
        PropertyChanges { target: appNameGlow; opacity: 0}
      }
    ]
    transitions: highlight
  }

  DropShadow {
    id: appNameGlow
    visible: plasmoid.configuration.enableGlow
    anchors.fill: appname
    cached: true
    horizontalOffset: 0
    verticalOffset: 0
    radius: 15.0
    samples: 16
    color: main.glowColor1
    source: appname
  }
  
  MouseArea {
      id: ma
      anchors.fill: parent
      z: parent.z + 1
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: !grid.movedWithWheel
      onClicked: {
       
          if (mouse.button == Qt.RightButton ) {
            if (favItem.hasActionList) {
                var mapped = mapToItem(favItem, mouse.x, mouse.y);
                favItem.openActionMenu(favItem, mouse.x, mouse.y);
            }
          } else {
           trigger();
          }
        
      }
      onReleased: {
        isDraging: false
      }
      onEntered: {
          // - When the movedWithKeyboard condition is broken, we do not want to
          //   select the hovered item without moving the mouse.
          // - Don't highlight separators.
          // - Don't switch category items on hover if the setting isn't enabled
          if (grid.movedWithKeyboard) {
              return
          }

          // forceActiveFocus() touches multiple items, so check for
          // activeFocus first to be more efficient.
          if (!grid.activeFocus) {
              grid.forceActiveFocus(Qt.MouseFocusReason)
          }
          // No need to check currentIndex first because it's
          // built into QQuickListView::setCurrentIndex() already
          grid.currentIndex = index        
      }
  }
  ActionMenu {
      id: actionMenu

      onActionClicked: {
          actionTriggered(actionId, actionArgument);
         // root.toggle()
      }
  }
  Transition {
    id: highlight
    ColorAnimation {duration: 100 }
  }

  DragHandler {
      id: dragHandler
      acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
      enabled: favItem.dragIconItem !== null
      target: null // Using this Item fixes drag and drop causing delegates to reset to a 0 X position and overlapping each other.
      onActiveChanged: favItem.performDrag(this)
  }
}
