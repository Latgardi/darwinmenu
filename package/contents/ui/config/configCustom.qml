import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM

KCM.ScrollViewKCM {
    id: configCustom
    property alias cfg_customCommandsInSeparateMenu: customCommandsInSeparateMenu.checked
    property alias cfg_customCommandsMenuTitle: customCommandsMenuTitle.text
    property list<string> cfg_commands: Plasmoid.configuration.commands ?? []

    header: ColumnLayout {
        Switch {
            id: customCommandsInSeparateMenu
            text: i18n("Show custom commands in separate menu")
            checked: Plasmoid.customCommandsInSeparateMenu.checked
        }
        RowLayout {
            visible: customCommandsInSeparateMenu.checked
            Label {
                text: i18n("Custom commands menu title")
            }
            TextField {
                id: customCommandsMenuTitle
                text: Plasmoid.configuration.customCommandsMenuTitle ?? ""
            }
        }
        Item {
            Kirigami.FormData.isSection: true
        }
        Kirigami.ActionToolBar {
            alignment: Qt.AlignCenter
            actions: [
                Kirigami.Action {
                    text: i18n("Add command")
                    icon.name: "add"
            shortcut: StandardKey.New
            onTriggered: {
                customCommands.append({
                    "text": "",
                    "command": ""
                });
            }
        },
            Kirigami.Action {
                text: i18n("Clear command list")
                icon.name: "edit-clear-all"
                onTriggered: customCommands.clear()
            }
            ]
        }
    }

    ListModel {
        id: customCommands
        Component.onCompleted: {
            for (const rawCommand of configCustom.cfg_commands) {
                const command = JSON.parse(rawCommand)
                console.log(typeof command)
                customCommands.append({
                    "text": command.text,
                    "command": command.command
                });
            }
        }
        onDataChanged: index => {
            const command = customCommands.get(index)
            const entry = JSON.stringify(command)
            configCustom.cfg_commands[index.row] = entry
        }
    }
    view: ListView {
        id: commandsList
        height: parent.height
        width: parent.width
        clip: true
        model: customCommands
        delegate: PlasmaComponents.ItemDelegate {
            width: ListView.view.width
            contentItem: RowLayout {
                width: ListView.view.width
                spacing: Kirigami.Units.smallSpacing
                Label {
                    text: i18n("Title")
                }
                TextField {
                    text: model.text

                    onTextChanged: {
                        customCommands.setProperty(model.index, "text", text)
                    }
                }
                Label {
                    text: i18n("Command")
                }
                TextField {
                    text: model.command

                    onTextChanged: {
                        customCommands.setProperty(model.index, "command", text)
                    }
                }
                ToolButton {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    icon.name: "delete"
                    onClicked: {
                        const index = model.index
                        customCommands.remove(index)
                        Plasmoid.configuration.commands = configCustom.cfg_commands
                            .splice(index)
                    }
                }
            }
        }
        onCountChanged: count => {
            Qt.callLater(commandsList.positionViewAtEnd )
        }
    }
}
