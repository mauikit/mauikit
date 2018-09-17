import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.0 as Kirigami

Popup
{
    property var itemUrls : []

    padding: contentMargins

    modal: true

    height: grid.itemSize * 5
    width: isMobile ? parent.width * 0.9 : parent.width * 0.5

    parent: ApplicationWindow.overlay

    x: (parent.width / 2) - (width / 2)
    y: (parent.height) - (height *1.3)
    
    background: Rectangle
    {
        color: viewBackgroundColor
        radius: unit * 6
        border.color: borderColor
    }

    ColumnLayout
    {
        anchors.fill: parent
        height: parent.height
        width: parent.width

        Label
        {
            text: qsTr("Open with...")
            color: textColor
            height: toolBarHeightAlt
            width: parent.width
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            font.pointSize: fontSizes.big
            padding: contentMargins
            font.bold: true
            font.weight: Font.Bold
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: space.medium
            Maui.GridBrowser
            {
                id: grid
                showEmblem: false
                centerContent: true

                onItemClicked:
                {
                    grid.currentIndex = index
                    triggerService(index)
                }
            }
        }
    }


    onOpened: populate()

    function show(urls)
    {
        if(urls.length > 0)
        {
            itemUrls = urls
            open()
        }
    }

    function populate()
    {
        grid.model.clear()
        var services = Maui.KDE.services(itemUrls[0])
        var devices = Maui.KDE.devices()

        grid.model.append({icon: "internet-mail", label: "Email", email: true})

        if(devices.length > 0)
            for(var i in devices)
            {
                devices[i].icon = "smartphone"
                grid.model.append(devices[i])

            }

        if(services.length > 0)
            for(i in services)
                grid.model.append(services[i])

    }

    function triggerService(index)
    {
        var obj = grid.model.get(index)

        if(obj.serviceKey)
            Maui.KDE.sendToDevice(obj.label, obj.serviceKey, itemUrls)
        else if(obj.email)
            Maui.KDE.attachEmail(itemUrls)
        else
            Maui.KDE.openWithApp(obj.actionArgument, itemUrls)

        close()
    }
}

