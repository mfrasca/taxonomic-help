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

    Row {
        width: parent.width
        anchors {
            top: display_box.bottom
            bottom: parent.bottom
        }
        Flickable {
            anchors.fill: parent
	    contentWidth: parent.width
	    contentHeight: results.height + 20	    
	
            Column {
                id: results
                width: parent.width
            }
        }
    }
    Item {
        Rectangle {
            anchors.fill: parent
            color: "#50f840"
        }
        id: display_box
        width: parent.width
        height: lookup_text.height + display_label.height + 6 + 6 + 6
        anchors {
            left: parent.left
            top: parent.top
        }
        Text {
            id: display_label
            text: "lookup genus"
            height: 42
            font.pixelSize: 30
            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 12
                topMargin: 6
            }
        }

        TextField {
            id: lookup_text
            font.pixelSize: 48
            width: parent.width - 64 - 6 - 6 - 6
            height: 64
            anchors {
                top: display_label.bottom
                topMargin: 6
                left: parent.left
                leftMargin: 6
            }
        }
        CheckBox {
            id: phonetic
            text: "phonetic"
            checked: false
            anchors {
                top: parent.top
                topMargin: 6
                right: parent.right
                rightMargin: 6
            }
        }
        Button {
            id: display_fgh
            font.pixelSize: 48
            text: "?"
            height: 64
            width: 64
            anchors {
                top: display_label.bottom
                topMargin: 6
                left: lookup_text.right
                leftMargin: 6
            }
            onClicked: {
                for(var i = results.children.length; i > 0 ; i--) {
                    results.children[i - 1].destroy()
                }

                var l = eval(app.get_taxonomic_derivation(lookup_text.text, phonetic.checked))
                for (i in l) {
                    addResultLine(results, l[i])
                }
            }
        }
    }

}
