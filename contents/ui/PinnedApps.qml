
import QtQuick 2.12
import QtQuick.Controls 2.15

import QtQuick.Layouts 1.0

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.kirigami as Kirigami

DropArea {    
    AppGridView {
        id: pinnedAppsGrid
        
        anchors.fill: parent
        
        property QtObject recentAppsModel: rootModel.modelForRow(0);
        showScrollBar: false

        model: main.pinnedModel == 0 ? globalFavorites : recentAppsModel

        Component.onCompleted: {
            recentAppsModel = rootModel.modelForRow(0);
        }
    }
    onPositionChanged: drag => {
        if (drag.source === kicker.dragSource) {
            const source = kicker.dragSource.sourceItem
            if (source === null) {
                return
            }
            const view = source.view
            if (source.view === pinnedAppsGrid ) {
                const pos = mapToItem(view.contentItem, drag.x, drag.y)
                const targetIndex = view.indexAt(pos.x, pos.y)
                if (targetIndex >= 0 && targetIndex !== source.index) {
                    globalFavorites.moveRow(source.index, targetIndex)
                }
            }
        }
    }
}