import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.quicklaunch 1.0

Popup {
    property int selectedAppPid
    property string selectedAppName
    id: confirmationDialog

    SystemPalette {
        id: disabledPalette;
        colorGroup: SystemPalette.Disabled
    }

    Logic {
        id: logic
    }

    focus: true
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    implicitWidth: 400
    implicitHeight: 150
    anchors.centerIn: Overlay.overlay
    dim: true
    modal: true
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0;
                duration: 300
            }
            NumberAnimation {
                property: "scale";
                from: 0.4;
                to: 1.0;
                easing.type: Easing.OutBack
                duration: 300
            }
        }
    }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity";
                from: 1.0
                to: 0.0;
                duration: 300
            }
            NumberAnimation {
                property: "scale";
                from: 1.0
                to: 0.8;
                duration: 300
            }
        }
    }
    contentItem: ColumnLayout {
        Layout.margins: 20
        RowLayout {
            id: textRow
            Kirigami.Icon {
                id: iconWarning
                width: 128
                source: "dialog-warning"
            }
            ColumnLayout {
                Label {
                    width: parent.width * 0.9
                    Layout.preferredWidth: width
                    Layout.fillWidth: true
                    fontSizeMode: Text.Fit
                    wrapMode: Text.Wrap
                    color: activePalette.text
                    text: i18n("Do you want to force %1 to quit?", confirmationDialog.selectedAppName)
                    font.bold: true
                }

                Label {
                    color: activePalette.text
                    text: i18n("You will lose any unsaved changes.")
                    font.weight: Font.Light
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                focusPolicy: Qt.TabFocus
                id: cancelForceQuit
                text: i18n("Cancel");
                onClicked: {
                    confirmationDialog.close()
                }
            }
            Button {
                focusPolicy: Qt.TabFocus
                text: i18nc("force quit action", "Force Quit")
                onClicked: {
                    logic.openExec(`kill ${confirmationDialog.selectedAppPid}`)
                    confirmationDialog.close()
                    confirmationDialog.selectedAppPid = 0
                    confirmationDialog.selectedAppName = ""
                }
            }
        }
    }
    Overlay.modal: Rectangle {
        color: {
            const color = disabledPalette.window
            return Qt.hsla(color.hslHue, color.hslSaturation, color.hslLightness, 0.7)
        }
    }
    closePolicy: Popup.NoAutoClose
}