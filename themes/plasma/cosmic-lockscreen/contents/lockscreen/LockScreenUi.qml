// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.kde.plasma.private.sessions

Item {
    id: lockUi
    property bool waitingForPrompt: false
    property bool requestSent: false
    property bool secret: true
    property string notification: ""
    property bool failed: false

    SessionManagement { id: sessionManagement }
    Component.onCompleted: Qt.callLater(() => authenticator.startAuthenticating())

    CosmicScene {
        id: scene
        anchors.fill: parent
        accountName: kscreenlocker_userName
        accountImage: kscreenlocker_userImage ? "file://" + kscreenlocker_userImage : ""
        busy: lockUi.requestSent || authenticator.graceLocked
        allowSubmit: lockUi.waitingForPrompt && !authenticator.graceLocked
        secretPrompt: lockUi.secret
        message: lockUi.notification
        messageIsError: lockUi.failed
        canRestart: sessionManagement.canReboot
        canShutdown: sessionManagement.canShutdown
        onSubmitted: response => {
            lockUi.requestSent = true
            lockUi.waitingForPrompt = false
            lockUi.notification = "Verificando senha…"
            authenticator.respond(response)
        }
        onRestartRequested: sessionManagement.requestReboot(SessionManagement.Skip)
        onShutdownRequested: sessionManagement.requestShutdown(SessionManagement.Skip)
    }
    Timer {
        id: retry
        interval: 3000
        onTriggered: authenticator.startAuthenticating()
    }
    Connections {
        target: authenticator
        function onPromptForSecretChanged() {
            if (!authenticator.promptForSecret) return
            lockUi.secret = true
            lockUi.waitingForPrompt = true
            lockUi.requestSent = false
            scene.focusPassword()
        }
        function onPromptChanged() {
            if (!authenticator.prompt) return
            lockUi.secret = false
            lockUi.waitingForPrompt = true
            lockUi.requestSent = false
            lockUi.notification = authenticator.prompt
            scene.focusPassword()
        }
        function onInfoMessageChanged() { lockUi.notification = authenticator.infoMessage }
        function onErrorMessageChanged() {
            lockUi.notification = authenticator.errorMessage
            lockUi.failed = true
        }
        function onFailed(kind) {
            if (kind !== 0) return
            scene.clearPassword()
            lockUi.requestSent = false
            lockUi.waitingForPrompt = false
            lockUi.failed = true
            lockUi.notification = "Senha incorreta. Tente novamente."
            retry.restart()
            scene.focusPassword()
        }
        function onSucceeded() {
            Qt.quit()
        }
    }
}
