import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ImageViewer
{
	id: control
	anchors.fill: parent
	source: currentUrl
    animated: iteminfo.mime === "image/gif"
}
	


