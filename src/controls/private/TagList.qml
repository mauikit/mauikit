import QtQuick 2.0
import QtQuick.Controls 2.2
import "."

import TagsList 1.0 
import TagsModel 1.0

ListView
{
    id: control
    orientation: ListView.Horizontal
    clip: true
    spacing: contentMargins
    signal tagRemoved(int index)
    signal tagClicked(int index)
    boundsBehavior: isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds

    property string placeholderText: "Add tags..."
    property alias list : _tagsList
    property bool showPlaceHolder:  true
    property bool showDeleteIcon: true
    
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
        visible: count === 0 && showPlaceHolder
        color: textColor
        font.pointSize: fontSizes.default
    }

    delegate: TagDelegate
    {
        id: delegate
        showDeleteIcon: control.showDeleteIcon
        Connections
        {
            target: delegate
            onRemoveTag: tagRemoved(index)
            onClicked: tagClicked(index)
        }
    }

    function populate(tags)
    {
        model.clear()
        for(var i in tags)
            model.append(tags[i])
    }
}
