import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 1600
    height: 900
    property int selectedIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string selectedUser: userModel.lastUser || ""
    property string selectedDisplayName: ""
    property string selectedAvatar: ""
    property string statusText: ""
    property bool busy: false

    function updateClock() {
        const now = new Date();
        clock.text = Qt.formatTime(now, "HH:mm");
        date.text = Qt.locale("pt_BR").toString(now, "dddd, d 'de' MMMM 'de' yyyy");
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.updateClock()
    }
    Component.onCompleted: updateClock()

    Image {
        anchors.fill: parent
        source: "cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#e6171724" }
            GradientStop { position: 0.38; color: "#a6171724" }
            GradientStop { position: 0.72; color: "#30171724" }
            GradientStop { position: 1.0; color: "#14171724" }
        }
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#15111b27" }
            GradientStop { position: 1.0; color: "#3011111b" }
        }
    }

    Flickable {
        id: viewport
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: Math.max(height, column.implicitHeight + 60)
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            width: Math.min(400, viewport.width - Math.max(36, viewport.width * 0.14))
            x: Math.max(28, viewport.width * 0.09)
            y: Math.max(30, (viewport.height - implicitHeight) / 2)
            spacing: 0

            Text {
                id: clock
                color: "#cdd6f4"
                font.family: "JetBrains Mono, monospace"
                font.pixelSize: Math.min(82, Math.max(52, viewport.width * 0.055))
                font.weight: Font.Light
                font.letterSpacing: -4
                text: "--:--"
            }
            Text {
                id: date
                Layout.fillWidth: true
                width: column.width
                color: "#cdd6f4cc"
                font.family: "Noto Sans, sans-serif"
                font.pixelSize: 14
                wrapMode: Text.Wrap
                bottomPadding: 26
            }

            Rectangle {
                id: card
                width: column.width
                implicitHeight: cardLayout.implicitHeight + 46
                radius: 17
                color: "#d1181825"
                border.color: "#35cdd6f4"

                ColumnLayout {
                    id: cardLayout
                    anchors.fill: parent
                    anchors.margins: 23
                    spacing: 13

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Rectangle {
                            width: 8; height: 8; radius: 4
                            color: "#cba6f7"
                        }
                        Text {
                            text: "Entrar"
                            color: "#cdd6f4"
                            font.pixelSize: 17
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                        }
                    }

                    Button {
                        id: accountButton
                        visible: userModel.count > 1
                        Layout.fillWidth: true
                        implicitHeight: 52
                        text: root.selectedDisplayName || root.selectedUser || qsTr("Selecionar usuário")
                        display: AbstractButton.TextBesideIcon
                        icon.name: "user-identity"
                        onClicked: userMenu.open()
                        contentItem: RowLayout {
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 34; Layout.preferredHeight: 34
                                radius: 17; color: "#2fcba6f7"; border.color: "#55cba6f7"
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: root.selectedAvatar
                                    visible: source.toString().length > 0
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: (root.selectedDisplayName || root.selectedUser || "?").slice(0, 1).toUpperCase()
                                    color: "#cba6f7"
                                    visible: root.selectedAvatar.length === 0
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: accountButton.text
                                color: "#cdd6f4"
                                font.pixelSize: 14
                                elide: Text.ElideRight
                            }
                            Text { text: "⌄"; color: "#a6adc8"; font.pixelSize: 18 }
                        }
                        background: Rectangle {
                            radius: 9
                            color: "#57313244"
                            border.color: accountButton.activeFocus ? "#cba6f7" : "#25313244"
                        }
                        Accessible.name: qsTr("Selecionar usuário")
                    }

                    Item {
                        visible: userModel.count === 1
                        Layout.fillWidth: true
                        implicitHeight: 34
                        RowLayout {
                            anchors.fill: parent
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 34; Layout.preferredHeight: 34
                                radius: 17; color: "#2fcba6f7"; border.color: "#55cba6f7"
                                Image {
                                    anchors.fill: parent; anchors.margins: 1
                                    source: root.selectedAvatar
                                    visible: source.toString().length > 0
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: (root.selectedDisplayName || root.selectedUser || "?").slice(0, 1).toUpperCase()
                                    color: "#cba6f7"
                                    visible: root.selectedAvatar.length === 0
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.selectedDisplayName || root.selectedUser || qsTr("Usuário")
                                color: "#cdd6f4"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                        }
                    }

                    TextField {
                        id: usernameField
                        visible: userModel.count === 0
                        Layout.fillWidth: true
                        implicitHeight: 45
                        placeholderText: qsTr("Usuário")
                        color: "#cdd6f4"
                        placeholderTextColor: "#a6adc8"
                        background: Rectangle {
                            radius: 9
                            color: "#a8313244"
                            border.color: usernameField.activeFocus ? "#cba6f7" : "#40a6adc8"
                        }
                        Accessible.name: qsTr("Usuário")
                    }

                    Text {
                        text: qsTr("Senha")
                        color: "#a6adc8"
                        font.pixelSize: 12
                        Layout.topMargin: 2
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7
                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            implicitHeight: 45
                            placeholderText: qsTr("Digite sua senha")
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            enabled: !root.busy
                            focus: userModel.count <= 1
                            onAccepted: submitButton.clicked()
                            color: "#cdd6f4"
                            placeholderTextColor: "#a6adc8"
                            leftPadding: 13
                            background: Rectangle {
                                radius: 9
                                color: "#a8313244"
                                border.color: passwordField.activeFocus ? "#cba6f7" : "#40a6adc8"
                            }
                            Accessible.name: qsTr("Senha")
                        }
                        Button {
                            id: submitButton
                            implicitWidth: 45
                            implicitHeight: 45
                            enabled: !root.busy
                            text: "→"
                            font.pixelSize: 20
                            font.weight: Font.Medium
                            Accessible.name: qsTr("Entrar")
                            onClicked: {
                                const username = userModel.count > 0 ? root.selectedUser : usernameField.text.trim()
                                if (!username) {
                                    root.statusText = qsTr("O SDDM não informou a conta selecionada.")
                                    return
                                }
                                root.busy = true
                                root.statusText = qsTr("Verificando senha…")
                                const secret = passwordField.text
                                passwordField.clear()
                                const sessionIndex = (typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
                                sddm.login(username, secret, sessionIndex)
                            }
                            background: Rectangle {
                                radius: 8
                                color: submitButton.activeFocus ? "#cba6f7" : "#28cba6f7"
                                border.color: "#65cba6f7"
                            }
                            contentItem: Text {
                                text: submitButton.text
                                color: submitButton.activeFocus ? "#1e1e2e" : "#cba6f7"
                                font: submitButton.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.statusText
                        color: "#f38ba8"
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        visible: text.length > 0
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 2
                        Item { Layout.fillWidth: true }
                        Button {
                            text: qsTr("Reiniciar")
                            visible: sddm.canReboot
                            enabled: visible
                            onClicked: sddm.reboot()
                            background: Item {}
                            contentItem: Text { text: parent.text; color: "#a6adc8"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                            Accessible.name: qsTr("Reiniciar")
                        }
                        Text { text: "·"; color: "#80a6adc8"; visible: sddm.canReboot && sddm.canPowerOff }
                        Button {
                            text: qsTr("Desligar")
                            visible: sddm.canPowerOff
                            enabled: visible
                            onClicked: sddm.powerOff()
                            background: Item {}
                            contentItem: Text { text: parent.text; color: "#a6adc8"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                            Accessible.name: qsTr("Desligar")
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: userMenu
        x: accountButton.mapToItem(root, 0, 0).x
        y: accountButton.mapToItem(root, 0, accountButton.height).y + 5
        width: accountButton.width
        height: Math.min(userList.contentHeight + 12, root.height * 0.4)
        padding: 6
        modal: true
        focus: true
        background: Rectangle { radius: 11; color: "#f020202f"; border.color: "#45cdd6f4" }
        contentItem: ListView {
            id: userList
            clip: true
            model: userModel
            implicitHeight: contentHeight
            delegate: ItemDelegate {
                required property string name
                required property string realName
                required property string icon
                width: userList.width
                height: 48
                onClicked: {
                    root.selectedIndex = index
                    root.selectedUser = name
                    root.selectedDisplayName = realName || name
                    root.selectedAvatar = icon || ""
                    userMenu.close()
                    passwordField.forceActiveFocus()
                }
                contentItem: RowLayout {
                    spacing: 9
                    Rectangle {
                        Layout.preferredWidth: 32; Layout.preferredHeight: 32
                        radius: 16; color: "#2fcba6f7"
                        Image { anchors.fill: parent; anchors.margins: 1; source: icon; visible: source.toString().length > 0; fillMode: Image.PreserveAspectCrop }
                        Text { anchors.centerIn: parent; text: (realName || name).slice(0, 1).toUpperCase(); color: "#cba6f7"; visible: !icon || icon.length === 0 }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: realName || name
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }
                }
                background: Rectangle { radius: 7; color: parent.hovered ? "#40cba6f7" : "transparent" }
            }
        }
    }

    Repeater {
        model: userModel
        delegate: Item {
            required property string name
            required property string realName
            required property string icon
            Component.onCompleted: {
                if (index === root.selectedIndex) {
                    root.selectedUser = name
                    root.selectedDisplayName = realName || name
                    root.selectedAvatar = icon || ""
                }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            root.statusText = qsTr("Senha incorreta. Tente novamente.")
            passwordField.forceActiveFocus()
        }
    }
}
