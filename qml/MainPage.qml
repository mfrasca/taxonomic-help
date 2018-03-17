import QtQuick 1.0
import com.nokia.meego 1.0

import "." as MyComponents


Page {
    id: mainPage

    // We here define the portrait layout.  `displayOrientationChanged`
    // handles the switch to landscape or back to portrait.  We activate it
    // `onWidthChanged` and we make sure it is also called at start up, with
    // a single shot `Timer`, after 1ms.

    onWidthChanged: {
        displayOrientationChanged()
    }

    Timer {
        interval: 1;
        running: true;
        repeat: false;
        onTriggered: {
            displayOrientationChanged()
        }
    }
    
    function displayOrientationChanged() {
        if (width < 600) { // portrait
            console.log("[QML INFO] Portrait")
        } else { // landscape
            console.log("[QML INFO] Landscape")
        }
    }

    function addResultLine(parent, text) {
        var newObject = Qt.createQmlObject(
            'import QtQuick 1.0; Text {font.pixelSize: 28;}',
            parent)
        newObject.text = text
    }

    Text {
        id: display_label
        text: "lookup genus"
        font.pixelSize: 28
        anchors {
            left: parent.left
            top: parent.top
        }
    }

    Row {
        id: display_box
        width: parent.width
        height: 64
        anchors {
            left: parent.left
            top: display_label.bottom
        }
        TextField {
            id: lookup_text
            font.pixelSize: 48
            width: parent.width - 64
            height: parent.height
            anchors {
                leftMargin: 6
            }
        }
        Button {
            id: display_fgh
            font.pixelSize: 48
            text: "?"
            height: parent.height
            width: 64
            onClicked: {
                for(var i = results.children.length; i > 0 ; i--) {
                    results.children[i - 1].destroy()
                }

                var l = app.get_taxonomic_derivation(lookup_text.text).split('|')
                for (i in l) {
                    addResultLine(results, l[i])
                }
            }
        }
    }

    Flickable {
        id: scroll_me
        contentHeight: results.height
        anchors {
            top: display_box.bottom
        }
        Column {
            id: results
            width: parent.width
        }
    }
}
