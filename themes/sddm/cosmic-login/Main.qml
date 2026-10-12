// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick

Item {
    id: root
    width: 1600
    height: 900
    property int selectedIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string selectedUser: userModel.lastUser || ""
    property string selectedName: selectedUser
    property string selectedImage: ""
    property bool pending: false
    property string notification: ""
    property bool failed: false

    CosmicScene {
        id: scene
        anchors.fill: parent
        accountName: root.selectedName || "Usuário"
        accountImage: root.selectedImage
        busy: root.pending
        allowSubmit: root.selectedUser.length > 0
        message: root.notification
        messageIsError: root.failed
        canRestart: sddm.canReboot
        canShutdown: sddm.canPowerOff
        onSubmitted: response => {
            root.pending = true
            root.failed = false
            root.notification = "Verificando senha…"
            sddm.login(root.selectedUser, response, sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0)
        }
        onAccountSelected: account => {
            root.selectedUser = account.username
            root.selectedName = account.label
            root.selectedImage = account.image
            scene.clearPassword()
        }
        onRestartRequested: sddm.reboot()
        onShutdownRequested: sddm.powerOff()
    }
    Repeater {
        model: userModel
        delegate: Item {
            required property int index
            required property string name
            required property string realName
            required property string icon
            Component.onCompleted: {
                const account = {username: name, label: realName || name, image: icon}
                scene.accounts = scene.accounts.concat([account])
                if (index === root.selectedIndex) {
                    root.selectedUser = name
                    root.selectedName = realName || name
                    root.selectedImage = icon
                }
            }
        }
    }
    Connections {
        target: sddm
        function onLoginFailed() {
            root.pending = false
            root.failed = true
            root.notification = "Senha incorreta. Tente novamente."
            scene.focusPassword()
        }
    }
}
