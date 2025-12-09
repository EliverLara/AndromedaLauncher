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
import QtQuick 2.15
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.coreaddons 1.0 as KCoreAddons

import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami as Kirigami
import QtQuick.Controls

import "js/colorType.js" as ColorType

Item {
  id: main
  property bool searching: (searchBar.textField.text != "")
 // signal  newTextQuery(string text)

  readonly property color textColor: Kirigami.Theme.textColor
  readonly property string textFont: plasmoid.configuration.useSystemFontSettings ? Kirigami.Theme.defaultFont : "SF Pro Text"
  readonly property real textSize: plasmoid.configuration.useSystemFontSettings ? Kirigami.Theme.defaultFont.pointSize : 11
  readonly property color bgColor: Kirigami.Theme.backgroundColor
  readonly property color highlightColor: Kirigami.Theme.highlightColor
  readonly property color highlightedTextColor: Kirigami.Theme.highlightedTextColor
  readonly property bool isTop: plasmoid.location == PlasmaCore.Types.TopEdge & plasmoid.configuration.launcherPosition != 2 & !plasmoid.configuration.floating

  readonly property color glowColor1: plasmoid.configuration.glowColor == 0 ? "#D300DC" :
                                      plasmoid.configuration.glowColor == 1 ? "#20bdff" :
                                      "#ff005d"
  readonly property color glowColor2: plasmoid.configuration.glowColor == 0 ? "#8700FF" :
                                      plasmoid.configuration.glowColor == 1 ? "#5433ff" :
                                      "#ff8b26"

  property bool showAllApps: false

  property bool isDarkTheme: ColorType.isDark(bgColor)
  property color contrastBgColor: isDarkTheme ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.25)

  property int pinnedModel: plasmoid.configuration.pinnedModel

  property alias headerLabelRow: headerLabelRow
  property alias searchBar: searchBar
  property alias contentY: backdrop
  property int itemSpacing: 8

  KCoreAddons.KUser {
      id: kuser
  }

  function reset(){
    showAllApps = false;
    searchBar.textField.clear();
    searchBar.textField.forceActiveFocus();
    stack.replace(pinnedAppsComponent)
    headerLabelRow.reset();
  }

  onPinnedModelChanged: headerLabelRow.reset()

  Rectangle {
    id: backdrop
    x: 0
    y: isTop ? 125 : 90
    width: main.width
    height: isTop ? main.height - y - Kirigami.Units.largeSpacing : main.height - y //- (searchBarContainer.height + 20)
    color: bgColor
    opacity: 0
  }
  //Floating Avatar
  Item {
    id: avatarParent
    x: main.width / 2
    y: - root.margins.top
    FloatingAvatar { //Anyone looking for an unpredictable number generator?
      id: floatingAvatar
      //visualParent: root
      isTop: main.isTop
      avatarWidth: 110
      visible: root.visible && !isTop ? true : root.visible && plasmoid.configuration.floating ? true : false
    }
  }
  //Power & Settings
  RowLayout {
    id: headerBar
    width: main.width
    Item {
      Layout.fillWidth: true
      UserAvatar {
        width: 80
        height: width
        visible: !floatingAvatar.visible
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: width / 2
      }
    }

    Header {
      id: powerSettings
      iconSize: 20 
      Layout.fillHeight: false
      Layout.alignment: Qt.AlignRight | Qt.AlignTop
    }

  }
  
  //Greeting
  Greeting {
    id: greeting
    visible: true//floatingAvatar.visible
    x: main.width / 2 - textWidth / 2 //This centeres the Text
    y: main.isTop ? 95 : 50 
    textSize: 20 
  }

  // Fvorites / All apps label
  ColumnLayout {

    anchors.top: backdrop.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    spacing: itemSpacing

    RowLayout {
      id: headerLabelRow
      visible: !searching

      function reset() {
        if(showAllApps) {
          var appList = stack.currentItem
          var currentCategory = appList.getCurrentCategory();
          mainLabelGrid.text = currentCategory.name;
          sortingImage.source = currentCategory.icon;
          appList.updateShowedModel(currentCategory.index);
        } else {
          mainLabelGrid.text =  pinnedModel == 0 ? i18n("Favorite Apps") : i18n("Recent Apps");
        }
      }
        
      Kirigami.Icon {
        id: headerLabel
        source:  Qt.resolvedUrl("icons/feather/star.svg")
        visible: !main.showAllApps
        Layout.preferredHeight: 15
        Layout.preferredWidth: 15
        Layout.fillHeight: false
        isMask: true
        color: main.textColor
      }

      Kirigami.Icon {
        id: sortingImage
        Layout.preferredHeight: 15
        Layout.preferredWidth: 15
        Layout.fillHeight: false
        visible: main.showAllApps
      }

      PlasmaComponents.Label {
        id: mainLabelGrid
        font.family: textFont
        font.pointSize: textSize
        Layout.fillWidth: true
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true
          enabled: showAllApps && !searching
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          onClicked: {
            var appList = stack.currentItem;
            if (mouse.button == Qt.LeftButton) { appList.incrementCurrentStateIndex() }
            else if (mouse.button == Qt.RightButton) { appList.decrementCurrentStateIndex() }
            else if (mouse.button == Qt.MiddleButton) { appList.resetCurrentStateIndex() }
            headerLabelRow.reset();
          }
        }
      }

      // Show all app buttons
      PlasmaComponents.Button  {
        id: allAppsButton
        text: showAllApps ? i18n("Back") : i18n("All apps")
        flat: false
        
        topPadding: 6
        bottomPadding: topPadding
        leftPadding: 10
        rightPadding: 10

      //  icon.name: showAllApps ? "go-previous" : "go-next"
        icon.height: 15
        icon.width: icon.height

        font.pointSize: textSize
        font.family: textFont
        
        LayoutMirroring.enabled: true
        LayoutMirroring.childrenInherit: !showAllApps 
        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

        onClicked: {
          showAllApps = !showAllApps;
          stack.replace(showAllApps ? allAppsComponent : pinnedAppsComponent)
          headerLabelRow.reset();
          searchBar.textField.forceActiveFocus(Qt.BacktabFocusReason);
        }
        background: Rectangle {
          id: btnBg
          color: main.contrastBgColor
          border.width: 1
          border.color: main.contrastBgColor
          radius: height / 2

          Rectangle {
            id: bgMask
            width: parent.width
            height: parent.height
            radius: height / 2
            border.width: 1
            visible: plasmoid.configuration.enableGlow && !searching
          }
          Item {
            visible: plasmoid.configuration.enableGlow && !searching
            anchors.fill: bgMask
            layer.enabled: true
            layer.effect: OpacityMask { maskSource: bgMask }

            LinearGradient {
              anchors.fill: parent
              start: Qt.point(bgMask.width, 0)
              end: Qt.point(0, bgMask.height)
              gradient: Gradient {
                  GradientStop { position: 0.0; color: glowColor1 }
                  GradientStop { position: 1.0; color: glowColor2 }
              }
            }
          }
        }

        //All apps button shadow
        DropShadow {
            anchors.fill: btnBg
            cached: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 11.0
            samples: 16
            color: glowColor1
            source: btnBg
            visible: plasmoid.configuration.enableGlow && !searching
        }
      }

      Component.onCompleted: headerLabelRow.reset()
    }

    StackView {
      id: stack
      initialItem: pinnedAppsComponent
      Layout.fillWidth: true
      Layout.preferredHeight: root.cellSizeHeight*root.rows
      Keys.priority: Keys.AfterItem
      Keys.forwardTo: searchBar.textField
    }

    Component {
      id: pinnedAppsComponent
      PinnedApps{
        id: pinnedApps
      }
    }

    Component {
      id: allAppsComponent
      AllAppsList{
        id: appList
      }
    }

    Component {
      id:searchComponent
      RunnerList {
        id: runnerList
        model: runnerModel.count ? runnerModel.modelForRow(0) : null
      }
    }

    // Search Bar

    SearchBar {
      id: searchBar
      Layout.fillWidth: true
      Layout.preferredHeight: 45
      Layout.maximumHeight: Layout.preferredHeight
      Layout.alignment: Qt.AlignBottom
      Keys.priority: Keys.AfterItem
      Keys.forwardTo: stack.currentItem.viewItem
    }
  }
  onSearchingChanged: {
    if(searching){
      stack.replace(searchComponent)
    } else if(showAllApps) {
      stack.replace(allAppsComponent);
       headerLabelRow.reset();
    } else { 
      stack.replace(pinnedAppsComponent);
       headerLabelRow.reset();
    }
  }
}
