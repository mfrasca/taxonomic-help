import QtQuick 1.0
import com.nokia.meego 1.0

PageStackWindow {
    id: appWindow

    initialPage: mainPage
    MainPage {
        id: mainPage
    }

    Menu {
        id: myMenu
        MenuLayout {

            MenuItem {
                text: "About"
                onClicked: { about.open(); }
            }

            MenuItem {
                text: "Help"
                onClicked: { help.open(); }
            }
        }
    }

    QueryDialog {
        id: about
        icon: "../img/icon_80.png"
        titleText: "GPS Logger"
        message: "Version: " + app.get_version() + "\n" +
                 "Copyright 2018 by Mario Frasca\n"+
                 "Contact: george@ruinelli.ch\n"+
                 "Web: github.com/mfrasca/gpslogger"
        acceptButtonText: "Ok"
    }

    QueryDialog {
        id: help
        icon: "../img/icon_80.png"
        titleText: "GPS Logger"
        message: "The tracks will be saved in MyDocs/GPS-Logger."
        acceptButtonText: "Ok"
    }
}
