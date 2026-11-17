// Всплывающие уведомления (тосты) сверху: показываются после действий
// («Добавлено в плейлист», «Скачиваем…»), сами исчезают. Лёгкий аналог
// центра уведомлений настольного Quantis.
import QtQuick
import QtQuick.Layouts

Item {
    id: host

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    anchors.topMargin: 10
    z: 30

    property int maxVisible: 3

    ListModel { id: model }

    // Показ из QML (ручной) и из backend через сигнал notify.
    function show(text) {
        model.append({ text: text })
        while (model.count > maxVisible)
            model.remove(0)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Repeater {
            model: model
            delegate: Item {
                required property string text
                Layout.fillWidth: true
                height: Math.min(92, 26 + text.length * 0.55)

                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Component.onCompleted: opacity = 1

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: theme.surfaceHigh
                    border.color: theme.stroke
                    border.width: 1

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        verticalAlignment: Text.AlignVCenter
                        text: text
                        color: theme.text
                        font.family: theme.ui
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                // Автоскрытие: длинный текст висит дольше.
                Timer {
                    interval: text.length > 60 ? 3800 : 2600
                    running: true
                    repeat: false
                    onTriggered: {
                        opacity = 0
                        hideTimer.start()
                    }
                }
                Timer {
                    id: hideTimer
                    interval: 220
                    onTriggered: {
                        for (var i = 0; i < model.count; i++) {
                            if (model.get(i).text === text) {
                                model.remove(i)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}
