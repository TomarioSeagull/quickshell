//@ pragma IconTheme Adwaita
//@ pragma ComponentBehavior Bound

import Quickshell
import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls

import "components"

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow { // qmllint disable uncreatable-type
            id: root
            required property ShellScreen modelData
            screen: modelData

            property color col_bg0: "#282828"
            property color col_bg1: "#3c3836"
            property color col_bg2: "#504945"
            property color col_fg0: "#fbf1c7"

            property bool extended: false

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: extended ? 300 : 48
            color: "transparent"

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuart
                }
            }

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            PwObjectTracker {
                objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 5
                radius: 14
                color: root.col_bg0

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.bottomMargin: 5
                        Layout.minimumWidth: 38

                        Button {
                            id: volumeButton
                            Layout.alignment: Qt.AlignHCenter
                            Layout.minimumHeight: 35
                            Layout.minimumWidth: 38
                            checkable: true
                            onClicked: root.extended = !root.extended
                            icon {
                                color: root.col_fg0
                                width: 18
                                height: 18
                                source: Quickshell.iconPath(Pipewire.defaultAudioSink?.audio.muted //
                                ? "audio-volume-muted-symbolic" //
                                : ["audio-volume-low-symbolic", "audio-volume-medium-symbolic", "audio-volume-high-symbolic"] //
                                [Math.min(2, Math.floor(Pipewire.defaultAudioSink?.audio.volume * 3))])
                            }

                            background: Rectangle {
                                color: volumeButton.checked ? root.col_bg2 : volumeHover.hovered ? root.col_bg1 : "transparent"
                                topLeftRadius: 14
                                topRightRadius: root.extended ? 0 : 14

                                HoverHandler {
                                    id: volumeHover
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                Behavior on topRightRadius {
                                    NumberAnimation {
                                        duration: root.extended ? 200 : 0
                                        easing.type: Easing.InQuint
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDateTime(clock.date, "hh\nmm")
                            color: root.col_fg0
                            lineHeight: 0.6
                            font {
                                pixelSize: 15
                                weight: 600
                                family: "SpaceMono Nerd Font Mono"
                            }
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.minimumWidth: 1
                        Layout.minimumHeight: root.extended ? parent.height - 2 : 0
                        color: root.col_fg0

                        Behavior on Layout.minimumHeight {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    CircularSlider {
                        id: slider
						visible: root.extended
						trackWidth: 23
						progressWidth: 23
						trackColor: "#ffffff"
						capStyle: Qt.SquareCap
						startAngle: 180
						endAngle: 270
						handleVerticalOffset: -23
                        handle: Item {
							id: item
							width: 15
							height: 15
                            Shape {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                rotation: 180
                                ShapePath {
                                    strokeWidth: 1
                                    strokeColor: "#ffffff"
                                    fillColor: "#ffffff"
                                    startX: item.width / 2
                                    startY: 0
                                    PathLine {
                                        x: 0
                                        y: item.height
                                    }
                                    PathLine {
                                        x: item.width
                                        y: item.height
                                    }
                                    PathLine {
                                        x: item.width / 2
                                        y: 0
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
