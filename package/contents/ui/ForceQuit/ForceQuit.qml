import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import org.kde.taskmanager 0.1 as TaskManager

Window {
    id: "root"
    title: i18nc("force quit title", "Force Quit")
    minimumHeight: Kirigami.Units.gridUnit * 20
    minimumWidth: Kirigami.Units.gridUnit * 20

    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 25

    SystemPalette {
        id: activePalette;
        colorGroup: SystemPalette.Active
    }
    color: activePalette.window

    TaskManager.TasksModel {
        id: tasksModel

        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupApplications
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit
        width: parent.width
        height: parent.width
        spacing: 2

        Label {
            id: header
            Layout.maximumWidth: parent.width

            height: parent.height
            width: parent.width
            text: i18n("If an app doesn't respond for a while, select its name and click Force Quit.")
            wrapMode: Text.WordWrap

        }
        Rectangle {
            Layout.minimumWidth: parent.width
            Layout.maximumWidth: parent.width
            Layout.minimumHeight: parent.height - header.height - footer.height - Kirigami.Units.gridUnit * 2
            Layout.maximumHeight: parent.height - header.height - footer.height - Kirigami.Units.gridUnit * 2
            id: windows
            color: activePalette.dark


            ListView {
                clip: true
                focus: true
                id: windowList
                height: parent.height
                width: parent.width
                model: tasksModel
                delegate: PlasmaComponents.ItemDelegate {
                    highlighted: ListView.isCurrentItem
                    width: ListView.view.width

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            id: iconItem

                            source: model.decoration
                            visible: source !== "" && iconItem.valid

                            implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
                            implicitHeight: Kirigami.Units.iconSizes.sizeForLabels
                        }

                        Kirigami.Icon {
                            source: "preferences-system-windows"
                            visible: !iconItem.valid

                            implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
                            implicitHeight: Kirigami.Units.iconSizes.sizeForLabels
                        }
                        PlasmaComponents.Label {
                            Layout.fillWidth: true
                            text: model.AppName
                            elide: Text.ElideRight
                        }
                    }

                    onClicked:  {
                        windowList.currentIndex = index
                    }
                }
                onCurrentItemChanged: {
                    const modelIndex = model.makePersistentModelIndex(windowList.currentIndex)
                    confirmationDialog.selectedAppPid = tasksModel.data(
                        modelIndex,
                        TaskManager.AbstractTasksModel.AppPid
                    ) ?? 0
                    confirmationDialog.selectedAppName = tasksModel.data(
                        modelIndex,
                        TaskManager.AbstractTasksModel.AppName
                    ) ?? ""
                }
            }
        }

        RowLayout {
            id: footer
            Layout.minimumWidth: parent.width
            Layout.maximumWidth: parent.width
            Button {
                visible: plasmoid.configuration.shortcutOpensPlasmoid || plasmoid.globalShortcut.toString().length === 0
                id: openConfig
                icon.name: "configure"
                onClicked: plasmoid.internalAction("configure").trigger()
            }
            Label {
                Layout.maximumWidth: parent.width - openConfig.width - forceQuit.width
                visible: plasmoid.configuration.shortcutOpensPlasmoid || plasmoid.globalShortcut.toString().length === 0
                height: parent.height
                width: parent.width
                text: {
                        i18n("Configure this window to open on global shortcut.")
                }
                wrapMode: Text.WordWrap

            }
            Label {
                Layout.maximumWidth: parent.width - forceQuit.width
                visible: plasmoid.globalShortcut.toString().length > 0
                height: parent.height
                width: parent.width
                text: {
                    plasmoid.globalShortcut.toString().length > 0
                        ? i18n("You can open this window by pressing %1.", plasmoid.globalShortcut.toString())
                        : ""
                }
                wrapMode: Text.WordWrap

            }
            Button {
                Layout.alignment: Qt.AlignRight
                id: forceQuit
                text: i18nc("force quit action", "Force Quit")

                onClicked: {
                    confirmationDialog.open()
                }
            }
        }
    }

    ConfirmationDialog {
        id: confirmationDialog
    }
}
