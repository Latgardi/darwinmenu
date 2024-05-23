import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.platform as QtLabs
import org.kde.kcmutils
import org.kde.plasma.plasmoid
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2 as Kirigami
import org.kde.coreaddons as KCoreAddons
import org.kde.plasma.private.sessions 2.0 as Sessions
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.private.quicklaunch 1.0

AbstractButton {
    id: menuButton

    readonly property string appStoreCommand: Plasmoid.configuration.appStoreCommand
        ?? Plasmoid.configuration.appStoreCommandDefault
    readonly property string aboutThisPCCommand: Plasmoid.configuration.aboutThisPCCommand
        ?? Plasmoid.configuration.aboutThisPCCommandDefault
    readonly property bool aboutThisPCUseCommand: Plasmoid.configuration.aboutThisPCUseCommand
        ?? Plasmoid.configuration.aboutThisPCUseCommandDefault

    readonly property var customCommandsConfig: Plasmoid.configuration.commands
    readonly property bool customCommandsInSeparateMenu: Plasmoid.configuration.customCommandsInSeparateMenu
        ?? Plasmoid.configuration.customCommandsInSeparateMenuDefault
    readonly property string customCommandsMenuTitle: Plasmoid.configuration.customCommandsMenuTitle ?? ""

    property var customCommands: []

    enum State {
        Rest,
        Hover,
        Down
    }
    property int menuState: {
        if (down) {
            return MainMenuButton.State.Down;
        } else if (hovered && !menu.isOpened) {
            return MainMenuButton.State.Hover;
        }
        return MainMenuButton.State.Rest;
    }

    Connections {
        target: Plasmoid
        function onActivated() {
            Plasmoid.configuration.shortcutOpensPlasmoid
                ? menuButton.clicked()
                : forceQuit.show()
        }
    }

    Sessions.SessionManagement {
        id: sm
    }

    TaskManager.TasksModel {
        id: tasksModel
    }

    KCoreAddons.KUser {
        id: kUser
    }

    Logic {
        id: logic
    }

    onCustomCommandsConfigChanged: {
        let commands = [];
        for (const command of Plasmoid.configuration.commands ?? []) {
            const data = JSON.parse(command)
            commands.push(data)
        }
        customCommands = commands
    }
    onCustomCommandsChanged: {
        customMenuEntries.clear()
        for (const command of customCommands) {
            customMenuEntries.append(command);
        }
    }

    onClicked: {
        menu.isOpened ? menu.close() : menu.open(root)
    }

    Layout.preferredHeight: root.height
    Layout.preferredWidth: Plasmoid.configuration.useRectangleButtonShape
        ? Layout.preferredHeight * 1.5
        : Layout.preferredHeight

    contentItem: Item {
        width: parent.width
        height: parent.height
        Kirigami.Icon {
            id: menuIcon
            anchors.centerIn: parent
            source: root.icon
            height: {
                if (Plasmoid.configuration.useFixedIconSize) {
                    if (Plasmoid.configuration.resizeIconToRoot) {
                        return Plasmoid.configuration.fixedIconSize > root.height
                            ? root.height
                            : Plasmoid.configuration.fixedIconSize
                    }
                    return Plasmoid.configuration.fixedIconSize
                }
                return parent.height * (Plasmoid.configuration.iconSizePercent / 100)
            }
            width: height
        }
    }

    down: menu.isOpened

    background: KSvg.FrameSvgItem {
        id: rest
        height: parent.height
        width: parent.width
        imagePath: "widgets/menubaritem"
        prefix: switch (menuButton.menuState) {
            case MainMenuButton.State.Down: return "pressed";
            case MainMenuButton.State.Hover: return "hover";
            case MainMenuButton.State.Rest: return "normal";
        }
    }

    QtLabs.Menu {
        id: menu
        property bool isOpened: false
        readonly property int customCommandsEntryStartIndex: 2
        QtLabs.MenuItem {
            id: aboutThisPCMenuItem
            text: i18n("About This PC")
            onTriggered: menuButton.aboutThisPCUseCommand
                ? logic.openExec(menuButton.aboutThisPCCommand)
                : KCMLauncher.openInfoCenter("")
        }

        QtLabs.MenuSeparator {}
        ListModel {
            id: customMenuEntries
            Component.onCompleted: {
                for (const command of customCommands) {
                    customMenuEntries.append(command);
                }
            }
        }
        QtLabs.Menu {
            id: customCommandsSubMenu
            enabled: menuButton.customCommandsInSeparateMenu && customMenuEntries.length > 0
            visible: menuButton.customCommandsInSeparateMenu
            title: menuButton.customCommandsMenuTitle?.length > 0 ? menuButton.customCommandsMenuTitle : i18n("Commands")
            Instantiator {
                model: menuButton.customCommandsInSeparateMenu ? customMenuEntries : []
                active: menuButton.customCommandsInSeparateMenu
                delegate: QtLabs.MenuItem {
                    text: model.text
                    onTriggered: {
                        logic.openExec(model.command)
                    }
                }

                onObjectAdded: (index, object) => customCommandsSubMenu.insertItem(
                    customCommandsSubMenu.customCommandsEntryStartIndex,
                    object
                )
                onObjectRemoved: (index, object) => customCommandsSubMenu.removeItem(object)
            }
        }
        Instantiator {
            model: menuButton.customCommandsInSeparateMenu ? [] : customMenuEntries
            active: !menuButton.customCommandsInSeparateMenu
            delegate: QtLabs.MenuItem {
                text: model.text
                onTriggered: {
                    logic.openExec(model.command)
                }
            }

            onObjectAdded: (index, object) => menu.insertItem(menu.customCommandsEntryStartIndex, object)
            onObjectRemoved: (index, object) => menu.removeItem(object)
        }

        QtLabs.MenuSeparator {}

        QtLabs.MenuItem {
            id: systemSettingsMenuItem
            text: i18n("System Settings...")
            onTriggered: {
                KCMLauncher.openSystemSettings("");
            }
        }

        QtLabs.MenuItem {
            id: appStoreMenuItem
            text: i18n("App Store...")
            onTriggered: {
                logic.openExec(menuButton.appStoreCommand)
            }
        }

        QtLabs.MenuSeparator {}

        QtLabs.MenuItem {
            text: i18n("Force Quit...")
            onTriggered: {
                root.forceQuit.show()
            }
            shortcut: Plasmoid.configuration.shortcutOpensPlasmoid ? null : plasmoid.globalShortcut
        }

        QtLabs.MenuSeparator {}

        QtLabs.MenuItem {
            visible: sm.canSuspend
            text: i18n("Sleep")
            onTriggered: sm.suspend()
        }
        QtLabs.MenuItem {
            text: i18n("Restart...")
            onTriggered: sm.requestReboot();
        }
        QtLabs.MenuItem {
            text: i18n("Shut Down...")
            onTriggered: sm.requestShutdown();
        }

        QtLabs.MenuSeparator {}

        QtLabs.MenuItem {
            text: i18n("Lock Screen")
            shortcut: "Meta+L"
            onTriggered: sm.lock()
        }
        QtLabs.MenuItem {
            text: {
                i18n("Log Out %1...", kUser.fullName)
            }
            shortcut: "Ctrl+Alt+Delete"
            onTriggered: sm.requestLogout()
        }
        onAboutToHide: menu.isOpened = false
        onAboutToShow: menu.isOpened = true
    }
}
