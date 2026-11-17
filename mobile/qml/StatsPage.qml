// Статистика — порт настольной StatsPage: итоги (полные прослушивания,
// треки в истории, время в эфире), топ треков и артистов, ритм по часам
// и дням недели. Данные собираются в backend.py из дослушанных треков.
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: page
    signal back()

    readonly property var snap: app.stats
    readonly property int listens: snap ? snap.listens : 0

    function formatSpan(ms) {
        var totalMin = Math.max(0, Math.floor(ms / 60000))
        if (totalMin < 60)
            return totalMin + " мин"
        var hours = Math.floor(totalMin / 60)
        var minutes = totalMin % 60
        if (hours < 48)
            return minutes ? hours + " ч " + minutes + " мин" : hours + " ч"
        var days = Math.floor(hours / 24)
        var rest = hours % 24
        return rest ? days + " д " + rest + " ч" : days + " д"
    }

    function listensWord(n) {
        var tail = n % 10, tens = n % 100
        return tail === 1 && tens !== 11 ? "прослушивание"
             : tail >= 2 && tail <= 4 && (tens < 12 || tens > 14) ? "прослушивания"
             : "прослушиваний"
    }

    RowLayout {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.leftMargin: theme.gutter - 12
        IconButton { iconName: "chevron-left"; label: "Назад"; onClicked: page.back() }
        Text {
            text: "Статистика"
            color: theme.text
            font.family: theme.display
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }
    }

    Flickable {
        id: scroller
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentWidth: width
        contentHeight: column.implicitHeight + 32
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: column
            x: theme.gutter
            width: scroller.width - 2 * theme.gutter
            spacing: 14

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: listens === 0
                    ? "Дослушай трек до конца — он попадёт в топ"
                    : "Прослушивание засчитывается, когда трек дослушан до конца"
                color: theme.textDim
                font.family: theme.ui
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }

            // --- Метрики -----------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                component Metric: Rectangle {
                    id: card
                    property string valueText: "—"
                    property string labelText: ""
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    radius: 16
                    color: theme.surface
                    border.color: theme.stroke
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        anchors.topMargin: 12
                        anchors.bottomMargin: 10
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: card.valueText
                            color: theme.text
                            font.family: theme.ui
                            font.pixelSize: 19
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: card.labelText
                            color: theme.textDim
                            font.family: theme.ui
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                        }
                    }
                }
                Metric { valueText: String(listens); labelText: "Полных" }
                Metric { valueText: String(snap ? snap.tracks : 0); labelText: "Треков" }
                Metric { valueText: formatSpan(snap ? snap.ms : 0); labelText: "В эфире" }
            }

            // --- Вкладки -----------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                component Tab: ItemDelegate {
                    id: tab
                    required property int tabIndex
                    property bool selected: stack.current === tabIndex
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Accessible.role: Accessible.PageTab
                    onClicked: stack.current = tabIndex
                    background: Rectangle {
                        radius: 12
                        color: tab.down ? theme.surfaceHigh : theme.surface
                        border.color: tab.selected ? theme.accent : theme.stroke
                        Behavior on border.color { ColorAnimation { duration: theme.fast } }
                    }
                    contentItem: Text {
                        text: tab.text
                        color: tab.selected ? theme.text : theme.textDim
                        font.family: theme.ui
                        font.pixelSize: 14
                        font.weight: tab.selected ? Font.Bold : Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Tab { text: "Треки"; tabIndex: 0 }
                Tab { text: "Артисты"; tabIndex: 1 }
                Tab { text: "Время"; tabIndex: 2 }
            }

            // --- Содержимое вкладок ------------------------------------------
            StackLayout {
                id: stack
                Layout.fillWidth: true
                currentIndex: 0

                // Треки: топ и «реже всего» не делаем — только топ.
                ColumnLayout {
                    spacing: 10
                    Text {
                        Layout.fillWidth: true
                        visible: page.listens === 0
                        text: "Пока пусто — слушай музыку, и здесь появится топ"
                        color: theme.textDim
                        font.family: theme.ui
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                    Repeater {
                        model: page.snap ? page.snap.topTracks : []
                        delegate: Item {
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 66
                            Rectangle {
                                anchors.fill: parent
                                radius: 16
                                color: theme.surface
                                border.color: theme.stroke
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    anchors.topMargin: 10
                                    anchors.bottomMargin: 10
                                    spacing: 4
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        Text {
                                            text: index + 1
                                            color: index < 3 ? theme.accent : theme.textDim
                                            font.family: theme.ui
                                            font.pixelSize: 15
                                            font.weight: Font.Bold
                                        }
                                        CoverArt {
                                            Layout.preferredWidth: 38
                                            Layout.preferredHeight: 38
                                            seed: modelData.title
                                            cover: modelData.cover ? encodeURIComponent(modelData.cover) : ""
                                            radius: 8
                                            glyph: 0.4
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1
                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.title
                                                color: theme.text
                                                font.family: theme.ui
                                                font.pixelSize: 14
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                visible: text.length > 0
                                                text: modelData.artist
                                                color: theme.textDim
                                                font.family: theme.ui
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                            }
                                        }
                                        Text {
                                            text: modelData.count
                                            color: theme.accent
                                            font.family: theme.ui
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 3
                                        radius: 1.5
                                        color: theme.stroke
                                        Rectangle {
                                            width: parent.width * Math.min(1, modelData.count / Math.max(1, page.snap.topTracks[0].count))
                                            height: parent.height
                                            radius: 1.5
                                            color: theme.accent
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Артисты.
                ColumnLayout {
                    spacing: 10
                    Repeater {
                        model: page.snap ? page.snap.topArtists : []
                        delegate: Item {
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            Rectangle {
                                anchors.fill: parent
                                radius: 16
                                color: theme.surface
                                border.color: theme.stroke
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12
                                    CoverArt {
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38
                                        seed: modelData.name
                                        cover: modelData.cover ? encodeURIComponent(modelData.cover) : ""
                                        radius: 19
                                        glyph: 0.4
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: theme.text
                                        font.family: theme.ui
                                        font.pixelSize: 15
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: modelData.count
                                        color: theme.accent
                                        font.family: theme.ui
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                    }
                                }
                            }
                        }
                    }
                }

                // Время: часы и дни недели.
                ColumnLayout {
                    spacing: 18
                    Text {
                        Layout.fillWidth: true
                        text: "Когда ты слушаешь"
                        color: theme.textDim
                        font.family: theme.ui
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 0.8
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        Repeater {
                            model: 24
                            delegate: Item {
                                required property int index
                                readonly property real slot: parent.width / 24
                                x: index * slot
                                width: slot
                                height: parent.height
                                readonly property int value: page.snap ? page.snap.hours[index] : 0
                                readonly property int maxVal: page.snap ? Math.max(1, Math.max.apply(null, page.snap.hours)) : 1
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.slot - 3
                                    height: parent.height * (value / maxVal)
                                    radius: 2
                                    color: (index >= 7 && index <= 22) ? theme.accent : theme.accent2
                                    opacity: 0.45 + 0.55 * (value / maxVal)
                                }
                            }
                        }
                    }
                    Row {
                        width: parent.width
                        Text { width: parent.width / 2; text: "0 ч"; color: theme.textDim; font.pixelSize: 11; font.family: theme.ui }
                        Text { width: parent.width / 2; horizontalAlignment: Text.AlignRight; text: "23 ч"; color: theme.textDim; font.pixelSize: 11; font.family: theme.ui }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "По дням недели"
                        color: theme.textDim
                        font.family: theme.ui
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 0.8
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 96
                        Repeater {
                            model: 7
                            delegate: Item {
                                required property int index
                                readonly property var names: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                                readonly property real slot: parent.width / 7
                                x: index * slot
                                width: slot
                                height: parent.height
                                readonly property int value: page.snap ? page.snap.days[index] : 0
                                readonly property int maxVal: page.snap ? Math.max(1, Math.max.apply(null, page.snap.days)) : 1
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 22
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.slot * 0.5
                                    height: (parent.height - 22) * (value / maxVal)
                                    radius: 3
                                    color: theme.accent
                                    opacity: 0.5 + 0.5 * (value / maxVal)
                                }
                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: names[index]
                                    color: theme.textDim
                                    font.family: theme.ui
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
