import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.2 as Maui
import QtGraphicalEffects 1.0

Maui.ItemDelegate
{
    id: control

    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#333"
    Kirigami.Theme.textColor: "#fafafa"

    /**
     * template : function
     */
    property alias template : _template

    /**
     * images : function
     */
    property var images : []

    /**
     * label1 : function
     */
    property alias label1 : _template.label1

    /**
     * label2 : function
     */
    property alias label2 : _template.label2

    /**
     * label3 : function
     */
    property alias label3 : _template.label3

    /**
     * label4 : function
     */
    property alias label4 : _template.label4

    /**
     * iconSource : function
     */
    property alias iconSource : _template.iconSource

    /**
     * iconSizeHint : function
     */
    property alias iconSizeHint: _template.iconSizeHint

    /**
     * margins : function
     */
    property int margins : isWide ? Maui.Style.space.medium : Maui.Style.space.tiny

    /**
     * cb : function
     */
    property var cb

    Component.onCompleted: _featuredTimer.start()

    background: Item {}

    Item
    {
        id: _cover
        anchors.fill: parent
        anchors.margins: control.margins

        Rectangle
        {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            radius: Maui.Style.radiusV

            HoverHandler
            {
                id: _hoverHandler
            }

            Timer
            {
                id: _featuredTimer
                interval: 6000
                repeat: true
                onTriggered: _featuredRoll.cycleSlideForward()
            }

            ListView
            {
                id: _featuredRoll
                anchors.fill: parent
                interactive: false
                orientation: Qt.Horizontal
                snapMode: ListView.SnapOneItem
                clip: true

                model: control.images

                function cycleSlideForward()
                {
                    _featuredTimer.restart()

                    if (_featuredRoll.currentIndex === _featuredRoll.count - 1)
                    {
                        _featuredRoll.currentIndex = 0
                    } else
                    {
                        _featuredRoll.incrementCurrentIndex()
                    }
                }

                function cycleSlideBackward()
                {
                    _featuredTimer.restart()

                    if (_featuredRoll.currentIndex === 0)
                    {
                        _featuredRoll.currentIndex = _featuredRoll.count - 1;
                    } else
                    {
                        _featuredRoll.decrementCurrentIndex();
                    }
                }

                delegate: Item
                {
                    width: ListView.view.width
                    height: ListView.view.height * (_hoverHandler.hovered ? 1.2 : 1)

                    Image
                    {
                        anchors.fill: parent
                        sourceSize.width: 500
                        sourceSize.height: 500
                        asynchronous: true
                        smooth: false
                        source: control.cb ? control.cb(modelData) : modelData
                        fillMode: Image.PreserveAspectCrop
                    }

                    Behavior on height
                    {
                        NumberAnimation
                        {
                            duration: Kirigami.Units.shortDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                
                OpacityMask
                {
                    source: mask
                    maskSource: _featuredRoll
                }
                
                LinearGradient 
                {
                    id: mask
                    anchors.fill: parent
                    gradient: Gradient 
                    {
                        GradientStop { position: 0.2; color: "transparent"}
                        GradientStop { position: 0.9; color: control.Kirigami.Theme.backgroundColor}
                    }                    
                }
            }

            LinearGradient
            {
                anchors.fill: parent
                start: Qt.point(0, parent.height* 0.6)
                end: Qt.point(0, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.9; color: control.Kirigami.Theme.backgroundColor }
                }
            }

            Maui.ListItemTemplate
            {
                id: _template
                isCurrentItem: control.isCurrentItem
                hovered: control.hovered
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Maui.Style.space.medium
                //            color: Kirigami.Theme.textColor
                label1.font.bold: true
                label1.font.weight: Font.Bold
                label1.font.pointSize: Maui.Style.fontSizes.enormous
                label2.font.pointSize: Maui.Style.fontSizes.big
                label3.font.pointSize: Maui.Style.fontSizes.enormous
                label4.font.pointSize: Maui.Style.fontSizes.small
                label3.font.bold: true
                label3.font.weight: Font.Bold

                //                label1.wrapMode: Text.WordWrap
                //                label1.elide: Text.ElideRight
                //            horizontalAlignment: Qt.AlignHCenter
            }

            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: _cover.width
                    height: _cover.height

                    Rectangle
                    {
                        anchors.fill: parent
                        radius: Maui.Style.radiusV
                    }
                }
            }
        }

        Rectangle
        {
            Kirigami.Theme.inherit: false
            anchors.fill: parent
            color: "transparent"
            radius: Maui.Style.radiusV
            border.color: control.isCurrentItem || control.hovered ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)

            Rectangle
            {
                anchors.fill: parent
                color: "transparent"
                radius: parent.radius - 0.5
                border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
                opacity: 0.2
                anchors.margins: 1
            }
        }
    }
}
