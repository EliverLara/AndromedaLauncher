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
import QtQuick.Controls 2.15

import QtQuick.Layouts 1.0

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.kirigami as Kirigami

import org.kde.draganddrop 2.0


Item {
  id: allApps

  property QtObject allAppsModel: rootModel.modelForRow(2)

  property var currentStateIndex: plasmoid.configuration.defaultPage

  property bool showItemsInGrid: plasmoid.configuration.showItemsInGrid

  property Component preferredAppsViewComponent: showItemsInGrid ? applicationsGridViewComponent : applicationsListViewComponent

  property alias viewItem: appViewLoader.item

  property var appsCategoriesList: { 

    var categories = [];
    var categoryName;
    var categoryIcon;

    for (var i = 2; i < rootModel.count; i++) {
      categoryName  = rootModel.data(rootModel.index(i, 0), Qt.DisplayRole);
      categoryIcon  = rootModel.data(rootModel.index(i, 0), Qt.DecorationRole);
      categories.push({
        name: categoryName,
        index: i,
        icon: categoryIcon
      });
    }
    allApps.allAppsModel =  rootModel.modelForRow(2)
    return categories;
  }

  function updateModels() {
      allApps.allAppsModel = rootModel.modelForRow(2)
  }

  function updateShowedModel(index){
    viewItem.model = rootModel.modelForRow(index);
    viewItem.currentIndex = 0;
  }

  function incrementCurrentStateIndex() {
    currentStateIndex +=1;
    if (currentStateIndex > appsCategoriesList.length - 1) {
        currentStateIndex = 0;
    }
  }

  function decrementCurrentStateIndex() {
    currentStateIndex -=1;
    if (currentStateIndex < 0) {
      currentStateIndex = appsCategoriesList.length - 1;
    }
  }

  function resetCurrentStateIndex() {
    currentStateIndex = plasmoid.configuration.defaultPage;
  }

  function getCurrentCategory(){
    return appsCategoriesList[currentStateIndex];
  }

  function reset(){
    currentStateIndex = plasmoid.configuration.defaultPage
  }

  Connections {
      target: root
      function onVisibleChanged() {
        currentStateIndex = plasmoid.configuration.defaultPage
      }
  }

  Loader {
    id: appViewLoader
    // Explicitly set the size of the
    // Loader to the parent item's size
    anchors.fill: parent
    sourceComponent: preferredAppsViewComponent
    active: true
  }

  Component {
    id: applicationsListViewComponent
    AppListView {
      id: appList

      anchors.fill: parent
      showSectionSeparator: false
      model: allAppsModel
    }
  }

  Component {
    id: applicationsGridViewComponent

    AppGridView {
      id: grid
      anchors.fill: parent
      model: allAppsModel
    }
  }
}
