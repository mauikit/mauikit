import QtQuick 2.9
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import QtGraphicalEffects 1.0

QQC2.Page
{
    id: control

    property bool headBarVisible : true
    property bool footBarVisible : true
    property bool headBarExit : true
    property bool headBarTitleVisible: headBarTitle
    property string headBarExitIcon : "dialog-close"
    property string headBarTitle: ""

    property int margins: contentMargins * 1.5

    property alias headBar: topToolBar
    property alias footBar: bottomToolBar
    property alias headBarBG : headBarBG

    property int footBarAligment : Qt.AlignCenter

    property bool dropShadow: true
    property bool altToolBars : false
    property int footBarMargins : space.large
    property bool floatingBar: false
    property bool footBarOverlap: false
    property bool allowRiseContent: floatingBar && footBarOverlap

    property bool contentIsRised: false

    signal exit();

    default property alias content : mainContainer.data

    clip: true

    leftPadding: 0
    topPadding: leftPadding
    rightPadding: leftPadding
    bottomPadding: leftPadding

    background: Rectangle
    {
        color: viewBackgroundColor
    }

    GridLayout
    {
        id: rootLayout
        anchors.fill: parent
        rows: 3
        columns: 1
        rowSpacing: 0

        Maui.ToolBar
        {
            id: topToolBar

            Layout.fillWidth: true
            Layout.row: altToolBars ? 3 : 1
            Layout.column: 1
            position: altToolBars ? ToolBar.Footer : ToolBar.Header

            width: parent.width
            height: toolBarHeightAlt
            implicitHeight: toolBarHeightAlt

            visible: headBarVisible && count > 0
            clip: false
            z: container.z +1

            leftContent: Maui.ToolButton
            {
                id: exitBtn
                visible: headBarExit
                anim : true
                iconName : headBarExitIcon
                onClicked : exit()
                //            isMask: false
            }

            middleContent: QQC2.Label
            {
                visible: headBarTitleVisible
                text : headBarTitle
                width: topToolBar.middleLayout.width
                elide : Text.ElideRight
                font.bold : false
                font.weight: Font.Bold
                color : textColor
                font.pointSize: fontSizes.big
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment :  Text.AlignVCenter
            }


            background: Rectangle
            {
                id: headBarBG
                property alias border : headBarBorder.color
                color: viewBackgroundColor
                implicitHeight: toolBarHeightAlt
                
                Kirigami.Separator
                {
                    id: headBarBorder
                    color:  Qt.tint(Kirigami.Theme.textColor, 
Qt.rgba(headBarBG.color.r, headBarBG.color.g, headBarBG.color.b, 0.7))
                    
                    anchors
                    {
                        left: parent.left
                        right: parent.right
                        bottom: altToolBars ? undefined : parent.bottom
                        top: altToolBars ? parent.top : undefined
                    }
                }

                layer.enabled: dropShadow
                layer.effect: DropShadow
                {
                    anchors.fill: headBarBG
                    horizontalOffset: 0
                    verticalOffset: altToolBars ? -1 : 1
                    radius: 8
                    samples: 25
                    color: Qt.darker(headBarBG.color , 1.4)
                    source: headBarBG
                }
            }


        }

        Item
        {
            id: container

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: margins
            Layout.row: altToolBars ? 1 : 2
            Layout.column: 1

            clip: false

            anchors.margins: floatingBar && footBarOverlap ? margins : 0
            anchors.top:  if(floatingBar && footBarOverlap && headBarVisible && !altToolBars)
                              topToolBar.bottom
                          else if(floatingBar && footBarOverlap || altToolBars)
                              rootLayout.top
                          else
                              undefined

            anchors.bottom: if(floatingBar && footBarOverlap && !altToolBars)
                                rootLayout.bottom
                            else if(floatingBar && footBarOverlap && altToolBars && headBarVisible)
                                topToolBar.top
                            else if(floatingBar && footBarOverlap && altToolBars && !headBarVisible)
                                rootLayout.bottom
                            else
                                undefined
            z: 1

            Flickable
            {
                id: flickable
                flickableDirection: Flickable.VerticalFlick
                height: parent.height
                width: parent.width
                z: container.z
                //                boundsMovement: Flickable.StopAtBounds
                boundsBehavior: Flickable.StopAtBounds
                interactive:  allowRiseContent
                contentWidth: parent.width
                contentHeight: allowRiseContent ? parent.height + footBar.height + footBarMargins + space.big :
                                                  parent.height

                onContentYChanged: control.contentIsRised = contentY > 0

                Item
                {
                    id: mainContainer
                    z: container.z
                    width: container.width
                    height: contentIsRised ? container.height - (footBar.height + footBarMargins + space.big) :
                                             container.height
                    y: contentIsRised ? flickable.contentY : 0

                }
            }
        }

        Maui.ToolBar
        {
            id: bottomToolBar

            visible: footBarVisible && count > 0

            readonly property int _margins : footBarMargins


            height: implicitHeight
            implicitHeight: toolBarHeight * (floatingBar ? 0.8 : 1)

            Layout.leftMargin: footBarAligment === Qt.AlignLeft ? _margins : space.small
            Layout.rightMargin: footBarAligment === Qt.AlignRight ? _margins : space.small
            Layout.bottomMargin: floatingBar ? _margins : 0
            Layout.alignment: footBarAligment
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            //            Layout.minimumWidth: parent.width * (floatingBar ? 0.4 :  1)
            Layout.maximumWidth: floatingBar ? middleLayout.implicitWidth + layout.implicitWidth : parent.width
            Layout.row: altToolBars ? 2 : 3
            Layout.column: 1
            z: container.z +1
            position: ToolBar.Footer
            clip: false

            background: Rectangle
            {
                id: footBarBg
                height: toolBarHeight * (floatingBar? 0.8 : 1)
                color: floatingBar ? accentColor : viewBackgroundColor
                radius: floatingBar ? unit*6 : 0
                border.color: floatingBar ? Qt.darker(accentColor, 1.2) : "transparent"
                layer.enabled: floatingBar
                layer.effect: DropShadow
                {
                    anchors.fill: footBarBg
                    horizontalOffset: 0
                    verticalOffset: 3
                    radius: 8
                    samples: 25
                    color: Qt.darker(accentColor, 1.4)
                    source: footBarBg
                }

                Kirigami.Separator
                {
                    visible: !floatingBar
                    color: borderColor
                    anchors
                    {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                }
            }
        }
    }

    function riseContent()
    {
        if(allowRiseContent)
            flickable.flick(0, flickable.contentHeight* -2)
    }

    function dropContent()
    {
        if(allowRiseContent)
            flickable.flick(0, flickable.contentHeight* 2)

    }
}
