import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ColumnLayout
{
    id: layout
    anchors.fill: parent

           Item
        {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.margins: 0
			Layout.maximumHeight: parent.height * 0.7
			Layout.preferredHeight: parent.height * 0.7
			Layout.minimumHeight: parent.height * 0.7
			Image
        {
            anchors.centerIn: parent
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            width: parent.width
            height: parent.height * 0.9
            source: "file://"+currentUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.height: height
            sourceSize.width: width
        }
        
       
		}
         
    ScrollView
    {
		Layout.fillWidth: true
		Layout.fillHeight: true
		
		contentHeight: children.implicitHeight
		
		Column
		{
			id: _columnInfo
// 			spacing: rowHeight
			Label
			{				
				text: iteminfo.name
				
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: fontSizes.big
				font.weight: Font.Bold
				font.bold: true
			}
			
			Label
			{
			
				text: qsTr("Type: ")+ iteminfo.mime
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: fontSizes.default
			}
			
			Label
			{
				text: qsTr("Date: ")+ iteminfo.date
				
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: fontSizes.default
			}
			
			Label
			{
				text: qsTr("Modified: ")+ iteminfo.modified
				
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: fontSizes.default
			}
			
			Label
			{
				text: qsTr("Owner: ")+ iteminfo.owner
				
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: fontSizes.default
			}
			
			Label
			{
				text: qsTr("Tags: ")+ iteminfo.tags
				
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: fontSizes.default
			}
			
			Label
			{
				text: qsTr("Permisions: ")+ iteminfo.permissions
				
				elide: Qt.ElideRight
				wrapMode: Text.Wrap
				font.pointSize: fontSizes.default
			}
		}
		
	}
   
}

