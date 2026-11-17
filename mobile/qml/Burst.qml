// Короткая анимация-«вспышка»: расходящееся кольцо + мягкий поворот.
// Используется у кнопки «В любимое», когда трек лайкается.
import QtQuick

Item {
    id: burst

    property color color: theme.accentPink
    property bool fire: false

    width: 72
    height: 72
    visible: false

    onFireChanged: if (fire) play()

    function play() {
        visible = true
        ring1.scale = 0.35
        ring1.opacity = 1
        ring2.scale = 0.5
        ring2.opacity = 0.9
        anim.restart()
        hideTimer.restart()
    }

    Rectangle {
        id: ring1
        anchors.centerIn: parent
        width: parent.width * 0.78
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: burst.color
    }
    Rectangle {
        id: ring2
        anchors.centerIn: parent
        width: parent.width * 0.5
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 1.5
        border.color: Qt.rgba(burst.color.r, burst.color.g, burst.color.b, 0.7)
    }

    ParallelAnimation {
        id: anim
        NumberAnimation { target: ring1; property: "scale"; from: 0.35; to: 1.7; duration: 520; easing.type: Easing.OutCubic }
        NumberAnimation { target: ring1; property: "opacity"; from: 1; to: 0; duration: 520 }
        NumberAnimation { target: ring2; property: "scale"; from: 0.5; to: 1.35; duration: 520; easing.type: Easing.OutCubic }
        NumberAnimation { target: ring2; property: "opacity"; from: 0.9; to: 0; duration: 520 }
        NumberAnimation { target: burst; property: "rotation"; from: 0; to: 14; duration: 260; easing.type: Easing.OutQuad }
    }

    Timer {
        id: hideTimer
        interval: 560
        repeat: false
        onTriggered: {
            burst.visible = false
            burst.rotation = 0
            burst.fire = false
        }
    }
}
