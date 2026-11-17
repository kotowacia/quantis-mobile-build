// Визуализация «эквалайзера»: столбики плавно «дышат», пока трек играет.
// Это визуальный эффект (аудио-съёмка на Android через системный MediaPlayer
// недоступна), поэтому анимация — декоративная, в духе настольного Quantis.
// Уважает выбор «Спокойный» (theme.motion) и app.eq.
import QtQuick

Item {
    id: eq

    // Столбики играют, когда трек реально звучит.
    property bool active: false
    property color color: theme.accent
    property color color2: theme.accent2
    readonly property int n: 7
    property real barWidth: 4

    Repeater {
        model: eq.n
        delegate: Rectangle {
            required property int index
            readonly property real slot: eq.width / eq.n
            readonly property real mid: eq.width / 2
            readonly property bool rest: !eq.active || !theme.motion

            width: eq.barWidth
            height: target
            radius: width / 2
            color: index % 2 === 0 ? eq.color2 : eq.color
            opacity: rest ? 0.35 : 0.95
            x: mid + (index - (eq.n - 1) / 2) * slot - width / 2
            y: (eq.height - height) / 2

            property real base: 6
            property real target: base

            Behavior on height {
                NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
            }
            Behavior on opacity {
                NumberAnimation { duration: 220 }
            }
            onRestChanged: if (rest) target = base

            Timer {
                running: !parent.rest && eq.visible
                interval: 300 + index * 29
                repeat: true
                onTriggered: {
                    var maxH = eq.height - 10
                    parent.target = 6 + Math.random() * maxH
                }
            }
        }
    }
}
