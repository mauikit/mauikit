import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.kde.okular 2.0 as Okular

Maui.Page
{
	id: control
	
	property int currentPage;
	property int pageCount;
	property var pagesModel;
	title: documentItem.windowTitleForDocument
	
	footBar.middleContent: [
		ToolButton
		{
			icon.name: "go-previous"
			enabled: documentItem.currentPage > 0
			onClicked: 
			{
				if(documentItem.currentPage - 1  > -1)
					documentItem.currentPage --
			}
		},
		
		ToolButton
		{
			icon.name: "go-next"
			enabled: documentItem.pageCount > 1	&& 	documentItem.currentPage + 1 < documentItem.pageCount
			onClicked: 
			{
				if(documentItem.currentPage +1  < documentItem.pageCount)
					documentItem.currentPage ++
			}
		}
	]
	
	Okular.DocumentItem
	{
		id: documentItem
		url : currentUrl
		//         onWindowTitleForDocumentChanged: {
		//             fileBrowserRoot.title = windowTitleForDocument
		//         }
		onOpenedChanged: {
			if(opened === true) {
				//                control.loadingCompleted(true);
				//                initialPageChange.start();
			}
		}
		onCurrentPageChanged: {
			if(control.currentPage !== currentPage) {
				control.currentPage = currentPage;
			}
		}
	}
	
	ListView
	{
		id: imageBrowser
		anchors.fill: parent;
		model: documentItem.matchingPages
		clip: true
		currentIndex: control.currentPage
		property int imageWidth: control.width + Kirigami.Units.largeSpacing
		property int imageHeight: control.height
		highlightMoveDuration: 0
		
		orientation: ListView.Horizontal
		snapMode: ListView.SnapOneItem
		
		// This ensures that the current index is always up to date, which we need to ensure we can track the current page
		// as required by the thumbnail navigator, and the resume-reading-from functionality
		onMovementEnded:
		{
			var indexHere = indexAt(contentX + width / 2, contentY + height / 2);
			if(currentIndex !== indexHere) 
			{
				currentIndex = indexHere;
			}
		}
		
		delegate: Flickable
		{
			id: flick
			width: imageBrowser.imageWidth
			height: imageBrowser.imageHeight
			contentWidth: imageBrowser.imageWidth
			contentHeight: imageBrowser.imageHeight
			interactive: contentWidth > width || contentHeight > height
			onInteractiveChanged: imageBrowser.interactive = !interactive;
			z: interactive ? 1000 : 0
			PinchArea {
				width: Math.max(flick.contentWidth, flick.width)
				height: Math.max(flick.contentHeight, flick.height)
				
				property real initialWidth
				property real initialHeight
				
				onPinchStarted: {
					initialWidth = flick.contentWidth
					initialHeight = flick.contentHeight
				}
				
				onPinchUpdated: {
					// adjust content pos due to drag
					flick.contentX += pinch.previousCenter.x - pinch.center.x
					flick.contentY += pinch.previousCenter.y - pinch.center.y
					
					// resize content
					flick.resizeContent(Math.max(imageBrowser.imageWidth, initialWidth * pinch.scale), Math.max(imageBrowser.imageHeight, initialHeight * pinch.scale), pinch.center)
				}
				
				onPinchFinished: {
					// Move its content within bounds.
					flick.returnToBounds();
				}
				
				Item {
					Okular.PageItem {
						id: page;
						document: documentItem;
						pageNumber: index;
						anchors.centerIn: parent;
						property real pageRatio: implicitWidth / implicitHeight
						property bool sameOrientation: control.width / control.height > pageRatio
						width: sameOrientation ? parent.height * pageRatio : parent.width
						height: !sameOrientation ? parent.width / pageRatio : parent.height
					}
					implicitWidth: page.implicitWidth
					implicitHeight: page.implicitHeight
					width: flick.contentWidth
					height: flick.contentHeight
					MouseArea {
						anchors.fill: parent
						onDoubleClicked: {
							abortToggleControls();
							if (flick.interactive) {
								flick.resizeContent(imageBrowser.imageWidth, imageBrowser.imageHeight, {x: imageBrowser.imageWidth/2, y: imageBrowser.imageHeight/2});
							} else {
								flick.resizeContent(imageBrowser.imageWidth * 2, imageBrowser.imageHeight * 2, {x: mouse.x, y: mouse.y});
							}
						}
					}
				}
			}
		}
	}
	
// 	Component.onCompleted:
// 	{
// 		documentItem.url = currentUrl
// 	}
}
