import QtQuick 2.0
import QtQuick.Controls 2.2
import "."
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui 

import TagsList 1.0 
import TagsModel 1.0

ListView
{
    id: control 
    orientation: ListView.Horizontal
    clip: true
    spacing: Maui.Style.contentMargins   
    boundsBehavior: Kirigami.Settings.isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds

    property string placeholderText: qsTr("Add tags...")
    property alias list : _tagsList
    property bool showPlaceHolder:  true
    property bool showDeleteIcon: true
    
    signal tagRemoved(int index)
	signal tagClicked(int index)
    
    TagsModel
    {
		id: _tagsModel
		list: _tagsList
	}
	
	TagsList
	{
		id: _tagsList
	}
	
	model: _tagsModel
	
    Label
    {
        height: parent.height
        width: parent.width
        verticalAlignment: Qt.AlignVCenter
        text: qsTr(control.placeholderText)
        opacity: 0.7
        visible: count === 0 && control.showPlaceHolder
        color: Kirigami.Theme.textColor
        font.pointSize: Maui.Style.fontSizes.default
    }

    delegate: TagDelegate
    {
        id: delegate
        showDeleteIcon: control.showDeleteIcon
        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
        height: implicitHeight
        width: implicitWidth
        
        ListView.onAdd:
        {
			control.positionViewAtEnd()
		}
        
        Connections
        {
            target: delegate
            onRemoveTag: tagRemoved(index)
            onClicked: tagClicked(index)
        }
    }
}
