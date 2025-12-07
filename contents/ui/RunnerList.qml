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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker

import QtQuick.Window 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.kirigami as Kirigami

AppListView {
  id: searchList

  property alias viewItem: searchList

  Loader {
    anchors.fill: parent
    width: searchList.width - (Kirigami.Units.gridUnit * 4)

    active: searchList.count === 0
    visible: active
    asynchronous: true

    sourceComponent: PlasmaExtras.PlaceholderMessage {
      id: emptyHint

      iconName: "edit-none"
      opacity: 0
      text: i18nc("@info:status", "No matches")

      Connections {
        target: runnerModel
        function onQueryFinished() {
          showAnimation.restart()
        }
      }

      NumberAnimation {
        id: showAnimation
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
        property: "opacity"
        target: emptyHint
        to: 1
      }
    }
  }

  Connections {
    target: runnerModel
    function onQueryChanged() { 
      searchList.blockingHoverFocus = true;
      searchList.interceptedPosition = null;
      searchList.currentIndex = 0;
    }
  }
}