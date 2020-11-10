import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import "private"

/**
 * Editor
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Maui.Page
{
    id: control
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    /**
      * showLineCount : bool
      */
    property bool showLineCount : true

    /**
      * showSyntaxHighlightingLanguages : bool
      */
    property bool showSyntaxHighlightingLanguages: false

    /**
      * body : TextArea
      */
    property alias body : body

    /**
      * document : DocumentHandler
      */
    property alias document : document

    /**
      * scrollView : ScrollablePage
      */
    property alias scrollView: _scrollView

    /**
      * text : string
      */
    property alias text: body.text

    /**
      * uppercase : bool
      */
    property alias uppercase: document.uppercase

    /**
      * underline : bool
      */
    property alias underline: document.underline

    /**
      * italic : bool
      */
    property alias italic: document.italic

    /**
      * bold : bool
      */
    property alias bold: document.bold

    /**
      * canRedo : bool
      */
    property alias canRedo: body.canRedo

    /**
      * fileUrl : url
      */
    property alias fileUrl : document.fileUrl

    /**
      * showLineNumbers : bool
      */
    property bool showLineNumbers : false

    focus: true
    title: document.fileName
    showTitle: false
    flickable: _scrollView.flickable

    Maui.DocumentHandler
    {
        id: document
        document: body.textDocument
        cursorPosition: body.cursorPosition
        selectionStart: body.selectionStart
        selectionEnd: body.selectionEnd
        backgroundColor: control.Kirigami.Theme.backgroundColor
        enableSyntaxHighlighting: false
    }

    Row
    {
        z: _scrollView.z +1
        visible: showLineCount
        anchors
        {
            right: parent.right
            bottom: parent.bottom
            margins: Maui.Style.space.big
        }

        width: implicitWidth
        height: implicitHeight

        Label
        {
            text: body.length + " / " + body.lineCount
            color: control.Kirigami.Theme.textColor
            opacity: 0.5
            font.pointSize: Maui.Style.fontSizes.medium
        }
    }

    Menu
    {
        id: documentMenu
        z: 999

        MenuItem
        {
            text: i18n("Copy")
            onTriggered: body.copy()
            enabled: body.selectedText.length
        }

        MenuItem
        {
            text: i18n("Cut")
            onTriggered: body.cut()
            enabled: !body.readOnly && body.selectedText.length
        }

        MenuItem
        {
            text: i18n("Paste")
            onTriggered: body.paste()
            enabled: !body.readOnly
        }

        MenuItem
        {
            text: i18n("Select All")
            onTriggered: body.selectAll()
        }

        MenuItem
        {
            text: i18n("Search Selected Text on Google...")
            onTriggered: Qt.openUrlExternally("https://www.google.com/search?q="+body.selectedText)
            enabled: body.selectedText.length
        }
    }


    headBar.visible: !body.readOnly
    headBar.leftContent: [

    Maui.ToolActions
    {
        expanded: true
        autoExclusive: false
        checkable: false

        Action
        {
            icon.name: "edit-undo"
            enabled: body.canUndo
            onTriggered: body.undo()
        }

        Action
        {
            icon.name: "edit-redo"
            enabled: body.canRedo
            onTriggered: body.redo()
        }
    },

    Maui.ToolActions
    {
        visible: (document.isRich || body.textFormat === Text.RichText) && !body.readOnly
        expanded: true
        autoExclusive: false
        checkable: false

        Action
        {
            icon.name: "format-text-bold"
            checked: document.bold
            onTriggered: document.bold = !document.bold
        }

        Action
        {
            icon.name: "format-text-italic"
            checked: document.italic
            onTriggered: document.italic = !document.italic
        }

        Action
        {
            icon.name: "format-text-underline"
            checked: document.underline
            onTriggered: document.underline = !document.underline
        }

        Action
        {
            icon.name: "format-text-uppercase"
            checked: document.uppercase
            onTriggered: document.uppercase = !document.uppercase
        }
    }
    ]

    footBar.rightContent: ComboBox
    {
        visible: control.showSyntaxHighlightingLanguages
        model: document.getLanguageNameList()
        currentIndex: -1
        onCurrentIndexChanged: document.formatName = model[currentIndex]
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Repeater
        {
            model: document.alerts

            Maui.ToolBar
            {
                id: _alertBar
                property var alert : model.alert
                readonly property int index_ : index
                Layout.fillWidth: true

                Kirigami.Theme.backgroundColor:
                {
                    switch(alert.level)
                    {
                        case 0: return Kirigami.Theme.positiveTextColor
                        case 1: return Kirigami.Theme.neutralTextColor
                        case 2: return Kirigami.Theme.negativeTextColor
                    }
                }

                leftContent: Maui.ListItemTemplate
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    label1.text: alert.title
                    label2.text: alert.body
                }

                rightContent: Repeater
                {
                    model: alert.actionLabels()

                    Button
                    {
                        id: _alertAction
                        property int index_ : index
                        text: modelData
                        onClicked: alert.triggerAction(_alertAction.index_, _alertBar.index_)

                        Kirigami.Theme.backgroundColor: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.2)
                        Kirigami.Theme.textColor: Kirigami.Theme.textColor
                    }
                }
            }
        }

        PinchArea
        {
            id: pinchArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            property real minScale: 1.0
            property real maxScale: 3.0

            pinch.minimumScale: minScale
            pinch.maximumScale: maxScale
            pinch.dragAxis: Pinch.XandYAxis

            onPinchFinished:
            {
                console.log("pinch.scale", pinch.scale)

                if(pinch.scale > 1.5)
                    control.zoomIn()
                    else control.zoomOut()
            }

            MouseArea
            {
                anchors.fill: parent
                onPressed:
                {
                    console.log("Editor")
                    body.forceActiveFocus()
                }

            }

            Kirigami.ScrollablePage
            {
                id: _scrollView
                focus: true
                anchors.fill: parent
                contentWidth: control.width
                contentHeight: body.contentHeight

                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0

                background: Rectangle
                {
                    color: document.backgroundColor
                }

                TextArea
                {
                    id: body
                    width: control.width
                    implicitHeight: Math.max( control.height, contentHeight)
                    text: document.text
                    placeholderText: i18n("Body")
                    selectByKeyboard: !Kirigami.Settings.isMobile
                    selectByMouse : !Kirigami.Settings.isMobile
                    textFormat: TextEdit.AutoText
                    wrapMode: TextEdit.WrapAnywhere
                    color: control.Kirigami.Theme.textColor
                    activeFocusOnPress: true
                    activeFocusOnTab: true
                    persistentSelection: true

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    onPressed:
                    {
                        if(!Kirigami.Settings.isMobile && event.button === Qt.RightButton)
                            documentMenu.popup()
                    }

                    leftInset: leftPadding
                    leftPadding: _linesCounter.width + Maui.Style.space.small

                    Loader
                    {
                        id: _linesCounter
                        active: control.showLineNumbers && !document.isRich
                        anchors.left: parent.left
                        height: Math.max(body.height, control.height)
                        width: active ? 32 : 0
                        sourceComponent: _linesCounterComponent
                    }

                    Component
                    {
                        id: _linesCounterComponent
                        Rectangle
                        {
                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Window
                            color: Qt.darker(Kirigami.Theme.backgroundColor, 1)

                            ListView
                            {
                                currentIndex: document.currentLineIndex
                                model: body.lineCount
                                orientation: ListView.Vertical
                                interactive: false
                                anchors.fill: parent
                                anchors.topMargin: 7
                                snapMode: ListView.NoSnap

                                delegate: Label
                                {
                                    opacity: ListView.isCurrentItem  ? 1 : 0.7
                                    color:  ListView.isCurrentItem ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                                    font.pointSize: Math.min(Maui.Style.fontSizes.medium, body.font.pointSize)
                                    width:  ListView.view.width
                                    height: document.lineHeight(index)
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignTop
                                    renderType: Text.NativeRendering
                                    text: index+1
                                }
                            }

                            Kirigami.Separator
                            {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                            }
                        }
                    }
                }
            }
        }
    }

    /**
      *
      */
    function zoomIn()
    {
        body.font.pointSize = body.font.pointSize *1.5
    }

    /**
      *
      */
    function zoomOut()
    {
        body.font.pointSize = body.font.pointSize / 1.5

    }
}
