// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: scene
    property string accountName: "Usuário"
    property url accountImage: ""
    property var accounts: []
    property bool busy: false
    property bool allowSubmit: false
    property bool secretPrompt: true
    property string message: ""
    property bool messageIsError: false
    property bool canRestart: false
    property bool canShutdown: false
    property string previewTime: ""
    property string previewDate: ""
    signal submitted(string response)
    signal accountSelected(var account)
    signal restartRequested()
    signal shutdownRequested()

    readonly property bool compact: height < 730
    readonly property real cardPadding: compact ? 22 : 24
    readonly property real clockSize: compact ? Math.max(58, Math.min(70, width * 0.05)) : Math.max(64, Math.min(82, width * 0.055))
    FontLoader { id: monoFont; source: "JetBrainsMono-Regular.ttf" }

    function focusPassword() { password.forceActiveFocus() }
    function clearPassword() { password.clear() }
    function sendResponse() {
        if (scene.busy || !scene.allowSubmit) return
        const response = password.text
        password.clear()
        scene.submitted(response)
    }
    function updateTime() {
        const now = new Date()
        clock.text = scene.previewTime || Qt.formatTime(now, "HH:mm")
        const localized = Qt.locale("pt_BR").toString(now, "dddd, d 'de' MMMM 'de' yyyy")
        date.text = scene.previewDate || localized.charAt(0).toUpperCase() + localized.slice(1)
    }
    Component.onCompleted: { updateTime(); password.forceActiveFocus() }
    Timer { interval: 15000; running: true; repeat: true; onTriggered: scene.updateTime() }

    Image {
        id: photograph
        anchors.fill: parent
        source: "cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Qt.rgba(17/255, 17/255, 27/255, 0.88) }
            GradientStop { position: 0.27; color: Qt.rgba(24/255, 24/255, 37/255, 0.72) }
            GradientStop { position: 0.51; color: Qt.rgba(24/255, 24/255, 37/255, 0.32) }
            GradientStop { position: 0.76; color: Qt.rgba(24/255, 24/255, 37/255, 0.08) }
        }
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(17/255, 17/255, 27/255, 0.08) }
            GradientStop { position: 1; color: Qt.rgba(17/255, 17/255, 27/255, 0.18) }
        }
    }

    Flickable {
        id: viewport
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, column.height + 56)
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        Column {
            id: column
            x: scene.width < 700 ? scene.width * 0.07 : scene.width * 0.08 + Math.min(18, scene.width * 0.01)
            y: Math.max(28, (viewport.height - height) / 2)
            width: Math.min(400, viewport.width - x * 2)

            Text {
                id: clock
                x: 3
                height: Math.ceil(scene.clockSize * 1.10)
                color: "#cdd6f4"
                font.family: monoFont.name
                font.pixelSize: scene.clockSize
                font.weight: Font.Normal
                font.letterSpacing: -scene.clockSize * 0.075
                verticalAlignment: Text.AlignVCenter
            }
            Item { width: 1; height: 10 }
            Text {
                id: date
                x: 6
                width: parent.width - 6
                color: Qt.rgba(205/255, 214/255, 244/255, 0.76)
                font.family: "Noto Sans"
                font.pixelSize: 14
                wrapMode: Text.Wrap
            }
            Item { width: 1; height: scene.compact ? 16 : 27 }

            Rectangle {
                id: card
                width: column.width
                height: form.height + scene.cardPadding * 2
                radius: 18
                color: Qt.rgba(24/255, 24/255, 37/255, 0.76)
                border.color: Qt.rgba(205/255, 214/255, 244/255, 0.13)
                Column {
                    id: form
                    x: scene.cardPadding
                    y: scene.cardPadding
                    width: parent.width - scene.cardPadding * 2
                    spacing: 9
                    Row {
                        height: 21
                        spacing: 10
                        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 8; height: 8; radius: 4; color: "#cba6f7" }
                        Text { text: "Entrar"; color: "#cdd6f4"; font.pixelSize: 17; font.weight: Font.Medium }
                    }
                    Item { height: scene.compact ? 0 : 3; width: 1 }
                    Button {
                        id: accountButton
                        width: parent.width
                        height: 50
                        hoverEnabled: scene.accounts.length > 1
                        onClicked: { if (scene.accounts.length > 1) userMenu.open() }
                        Accessible.name: scene.accountName
                        background: Rectangle { radius: 10; color: Qt.rgba(49/255, 50/255, 68/255, 0.42); border.color: accountButton.activeFocus ? "#cba6f7" : "transparent" }
                        contentItem: Item {
                            Rectangle {
                                id: avatar
                                x: 4; anchors.verticalCenter: parent.verticalCenter
                                width: 34; height: 34; radius: 17
                                color: Qt.rgba(203/255, 166/255, 247/255, 0.12)
                                border.color: Qt.rgba(203/255, 166/255, 247/255, 0.28)
                                Text { anchors.centerIn: parent; text: scene.accountName.slice(0,1).toUpperCase(); font.pixelSize: 13; font.weight: Font.DemiBold; color: "#cba6f7"; visible: face.status !== Image.Ready }
                                Image { id: face; anchors.fill: parent; source: scene.accountImage; fillMode: Image.PreserveAspectCrop; visible: false }
                                Rectangle { id: faceMask; anchors.fill: parent; radius: 17; visible: false }
                                OpacityMask { anchors.fill: parent; source: face; maskSource: faceMask; visible: face.status === Image.Ready }
                            }
                            Text { anchors.left: avatar.right; anchors.leftMargin: 11; anchors.right: parent.right; anchors.rightMargin: 20; anchors.verticalCenter: parent.verticalCenter; text: scene.accountName; color: "#cdd6f4"; font.pixelSize: 14; font.weight: Font.Medium; elide: Text.ElideRight }
                            Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: "⌄"; color: "#a6adc8"; visible: scene.accounts.length > 1 }
                        }
                    }
                    Text { text: scene.secretPrompt ? "Senha" : "Resposta"; color: "#a6adc8"; font.pixelSize: 12 }
                    Rectangle {
                        width: parent.width
                        height: scene.compact ? 40 : 45
                        radius: 9
                        color: Qt.rgba(49/255, 50/255, 68/255, 0.64)
                        border.color: password.activeFocus ? Qt.rgba(203/255,166/255,247/255,0.75) : Qt.rgba(166/255,173/255,200/255,0.18)
                        TextField {
                            id: password
                            anchors.fill: parent
                            anchors.rightMargin: 49
                            leftPadding: 13
                            font.pixelSize: 14
                            color: "#cdd6f4"
                            echoMode: scene.secretPrompt ? TextInput.Password : TextInput.Normal
                            enabled: !scene.busy
                            background: Item {}
                            onAccepted: scene.sendResponse()
                            Accessible.name: scene.secretPrompt ? "Senha" : "Resposta"
                        }
                        Button {
                            id: submit
                            anchors.right: parent.right; anchors.rightMargin: 5
                            anchors.top: parent.top; anchors.topMargin: 4
                            anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                            width: 37
                            enabled: !scene.busy && scene.allowSubmit
                            onClicked: scene.sendResponse()
                            Accessible.name: "Entrar"
                            background: Rectangle { radius: 8; color: submit.hovered ? "#cba6f7" : Qt.rgba(203/255,166/255,247/255,0.1); border.color: Qt.rgba(203/255,166/255,247/255,0.26) }
                            contentItem: Text { text: "→"; font.pixelSize: 20; color: submit.hovered ? "#181825" : "#cba6f7"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                    Text {
                        width: parent.width
                        height: Math.max(18, implicitHeight)
                        text: scene.message
                        textFormat: Text.PlainText
                        color: scene.messageIsError ? "#f38ba8" : "#a6adc8"
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        Accessible.role: Accessible.AlertMessage
                    }
                }
            }
            Item { width: 1; height: scene.compact ? 11 : 17 }
            Row {
                x: scene.cardPadding
                spacing: 12
                Button {
                    id: restart
                    text: "Reiniciar"; visible: scene.canRestart
                    padding: 0; topPadding: 3; bottomPadding: 3
                    onClicked: scene.restartRequested()
                    background: Item {}
                    contentItem: Text { text: restart.text; color: restart.hovered ? "#cdd6f4" : "#a6adc8"; font.pixelSize: 12 }
                }
                Text { text: "·"; color: "#80a6adc8"; visible: scene.canRestart && scene.canShutdown; topPadding: 3 }
                Button {
                    id: shutdown
                    text: "Desligar"; visible: scene.canShutdown
                    padding: 0; topPadding: 3; bottomPadding: 3
                    onClicked: scene.shutdownRequested()
                    background: Item {}
                    contentItem: Text { text: shutdown.text; color: shutdown.hovered ? "#cdd6f4" : "#a6adc8"; font.pixelSize: 12 }
                }
            }
        }
    }
    Popup {
        id: userMenu
        x: accountButton.mapToItem(scene, 0, 0).x
        y: accountButton.mapToItem(scene, 0, accountButton.height).y + 6
        width: accountButton.width
        height: Math.min(userList.implicitHeight + 12, scene.height * 0.4)
        padding: 6; focus: true
        background: Rectangle { radius: 12; color: "#20202f"; border.color: "#45cdd6f4" }
        contentItem: Flickable {
            contentHeight: userList.height; clip: true
            Column {
                id: userList; width: parent.width; spacing: 3
                Repeater {
                    model: scene.accounts
                    delegate: Button {
                        required property var modelData
                        width: userList.width; height: 48
                        onClicked: { scene.accountSelected(modelData); userMenu.close(); password.forceActiveFocus() }
                        background: Rectangle { radius: 8; color: parent.hovered ? "#30cba6f7" : "transparent" }
                        contentItem: Row {
                            spacing: 11
                            Image { width: 34; height: 34; source: modelData.image || ""; fillMode: Image.PreserveAspectCrop }
                            Text { text: modelData.label || modelData.username; color: "#cdd6f4"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }
        }
    }
}
