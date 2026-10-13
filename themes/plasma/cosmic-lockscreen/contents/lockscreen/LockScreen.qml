// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick

Item {
    id: root
    property bool debug: false
    property bool viewVisible: false
    property string notification: ""
    signal clearPassword()
    signal notificationRepeated()
    implicitWidth: 1280
    implicitHeight: 720
    LockScreenUi { anchors.fill: parent }
}
