/*------------------------------
--- Lockscreen.qml by andrel ---
------------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style

Singleton { id: root
	readonly property Component content: Item {
		anchors.fill: parent

		SystemClock { id: clock
			precision: SystemClock.Minutes
		}

		// ── Word Clock logic ──────────────────────────────────────────
		QtObject { id: wordClock
			readonly property int h: parseInt(Qt.formatDateTime(clock.date, "h"))  // 1-12
			readonly property int m: parseInt(Qt.formatDateTime(clock.date, "m"))  // 0-59

			// minute bucket:
			//  0 = o'clock          (xx:00-xx:02)
			//  1 = five past        (xx:03-xx:07)
			//  2 = ten past         (xx:08-xx:12)
			//  3 = quarter past     (xx:13-xx:17)
			//  4 = twenty past      (xx:18-xx:22)
			//  5 = twenty five past (xx:23-xx:27)
			//  6 = half past        (xx:28-xx:32)
			//  7 = twenty five to   (xx:33-xx:37)
			//  8 = twenty to        (xx:38-xx:42)
			//  9 = quarter to       (xx:43-xx:47)
			// 10 = ten to           (xx:48-xx:52)
			// 11 = five to          (xx:53-xx:57)
			//  0 = o'clock (next)   (xx:58-xx:59)
			readonly property int bucket: {
				if      (m <  3) return 0;
				else if (m <  8) return 1;
				else if (m < 13) return 2;
				else if (m < 18) return 3;
				else if (m < 23) return 4;
				else if (m < 28) return 5;
				else if (m < 33) return 6;
				else if (m < 38) return 7;
				else if (m < 43) return 8;
				else if (m < 48) return 9;
				else if (m < 53) return 10;
				else if (m < 58) return 11;
				else             return 0;
			}

			// hour to display (advance when past the half)
			readonly property int displayHour: {
				let base = (m >= 33) ? (h % 12) + 1 : h;
				if (base > 12) base = 1;
				if (base < 1)  base = 12;
				return base;
			}

			// active words
			readonly property bool showHalf:     bucket === 6
			readonly property bool showQuarter:  bucket === 3 || bucket === 9
			readonly property bool showTwenty:   bucket === 4 || bucket === 5 || bucket === 7 || bucket === 8
			readonly property bool showFiveMins: bucket === 1 || bucket === 5 || bucket === 7 || bucket === 11
			readonly property bool showTenMins:  bucket === 2 || bucket === 10
			readonly property bool showPast:     bucket >= 1 && bucket <= 6
			readonly property bool showTo:       bucket >= 7 && bucket <= 11
			readonly property bool showOClock:   bucket === 0
			readonly property bool showOne:      displayHour === 1
			readonly property bool showTwo:      displayHour === 2
			readonly property bool showThree:    displayHour === 3
			readonly property bool showFour:     displayHour === 4
			readonly property bool showFiveHour: displayHour === 5
			readonly property bool showSix:      displayHour === 6
			readonly property bool showSeven:    displayHour === 7
			readonly property bool showEight:    displayHour === 8
			readonly property bool showNine:     displayHour === 9
			readonly property bool showTen:      displayHour === 10
			readonly property bool showEleven:   displayHour === 11
			readonly property bool showTwelve:   displayHour === 12
		}

		// ── Word Clock grid ───────────────────────────────────────────
		// Layout mirrors the image: letter grid where words light up.
		// Inactive letters shown at low opacity. Active ones are bright + bold.
		Column {
			id: wordGrid
			anchors.centerIn: parent
			anchors.verticalCenterOffset: -50
			spacing: 4

			readonly property int sz: 22
			readonly property color on:  GlobalVariables.colours.text
			readonly property color off: Qt.rgba(
				GlobalVariables.colours.text.r,
				GlobalVariables.colours.text.g,
				GlobalVariables.colours.text.b,
				0.18
			)

			component CC: Text {
				property bool lit: false
				width:  wordGrid.sz
				height: wordGrid.sz
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment:   Text.AlignVCenter
				font.family:  GlobalVariables.font.sans
				font.pixelSize: wordGrid.sz - 4
				font.weight: lit ? Font.Bold : Font.Normal
				color: lit ? wordGrid.on : wordGrid.off
				Behavior on color { ColorAnimation { duration: 300 } }
			}

			// Row 1:  I T · I S · A S A M P M
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "I"; lit: true }
				CC { text: "T"; lit: true }
				CC { text: " "; lit: false }
				CC { text: "I"; lit: true }
				CC { text: "S"; lit: true }
				CC { text: " "; lit: false }
				CC { text: "A"; lit: false }
				CC { text: "S"; lit: false }
				CC { text: "A"; lit: false }
				CC { text: "M"; lit: false }
				CC { text: "P"; lit: false }
				CC { text: "M"; lit: false }
			}

			// Row 2:  A C Q U A R T E R D C
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "A"; lit: false }
				CC { text: "C"; lit: false }
				CC { text: "Q"; lit: wordClock.showQuarter }
				CC { text: "U"; lit: wordClock.showQuarter }
				CC { text: "A"; lit: wordClock.showQuarter }
				CC { text: "R"; lit: wordClock.showQuarter }
				CC { text: "T"; lit: wordClock.showQuarter }
				CC { text: "E"; lit: wordClock.showQuarter }
				CC { text: "R"; lit: wordClock.showQuarter }
				CC { text: "D"; lit: false }
				CC { text: "C"; lit: false }
			}

			// Row 3:  T W E N T Y F I V E X
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "T"; lit: wordClock.showTwenty }
				CC { text: "W"; lit: wordClock.showTwenty }
				CC { text: "E"; lit: wordClock.showTwenty }
				CC { text: "N"; lit: wordClock.showTwenty }
				CC { text: "T"; lit: wordClock.showTwenty }
				CC { text: "Y"; lit: wordClock.showTwenty }
				CC { text: "F"; lit: wordClock.showFiveMins }
				CC { text: "I"; lit: wordClock.showFiveMins }
				CC { text: "V"; lit: wordClock.showFiveMins }
				CC { text: "E"; lit: wordClock.showFiveMins }
				CC { text: "X"; lit: false }
			}

			// Row 4:  H A L F B T E N T O
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "H"; lit: wordClock.showHalf }
				CC { text: "A"; lit: wordClock.showHalf }
				CC { text: "L"; lit: wordClock.showHalf }
				CC { text: "F"; lit: wordClock.showHalf }
				CC { text: "B"; lit: false }
				CC { text: "T"; lit: wordClock.showTenMins }
				CC { text: "E"; lit: wordClock.showTenMins }
				CC { text: "N"; lit: wordClock.showTenMins }
				CC { text: "T"; lit: wordClock.showTo }
				CC { text: "O"; lit: wordClock.showTo }
			}

			// Row 5:  P A S T B R U N I N E
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "P"; lit: wordClock.showPast }
				CC { text: "A"; lit: wordClock.showPast }
				CC { text: "S"; lit: wordClock.showPast }
				CC { text: "T"; lit: wordClock.showPast }
				CC { text: "B"; lit: false }
				CC { text: "R"; lit: false }
				CC { text: "U"; lit: false }
				CC { text: "N"; lit: wordClock.showNine }
				CC { text: "I"; lit: wordClock.showNine }
				CC { text: "N"; lit: wordClock.showNine }
				CC { text: "E"; lit: wordClock.showNine }
			}

			// Row 6:  O N E S I X T H R E E
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "O"; lit: wordClock.showOne }
				CC { text: "N"; lit: wordClock.showOne }
				CC { text: "E"; lit: wordClock.showOne }
				CC { text: "S"; lit: wordClock.showSix }
				CC { text: "I"; lit: wordClock.showSix }
				CC { text: "X"; lit: wordClock.showSix }
				CC { text: "T"; lit: wordClock.showThree }
				CC { text: "H"; lit: wordClock.showThree }
				CC { text: "R"; lit: wordClock.showThree }
				CC { text: "E"; lit: wordClock.showThree }
				CC { text: "E"; lit: wordClock.showThree }
			}

			// Row 7:  F O U R F I V E T W O
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "F"; lit: wordClock.showFour }
				CC { text: "O"; lit: wordClock.showFour }
				CC { text: "U"; lit: wordClock.showFour }
				CC { text: "R"; lit: wordClock.showFour }
				CC { text: "F"; lit: wordClock.showFiveHour }
				CC { text: "I"; lit: wordClock.showFiveHour }
				CC { text: "V"; lit: wordClock.showFiveHour }
				CC { text: "E"; lit: wordClock.showFiveHour }
				CC { text: "T"; lit: wordClock.showTwo }
				CC { text: "W"; lit: wordClock.showTwo }
				CC { text: "O"; lit: wordClock.showTwo }
			}

			// Row 8:  E I G H T E L E V E N
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "E"; lit: wordClock.showEight }
				CC { text: "I"; lit: wordClock.showEight }
				CC { text: "G"; lit: wordClock.showEight }
				CC { text: "H"; lit: wordClock.showEight }
				CC { text: "T"; lit: wordClock.showEight }
				CC { text: "E"; lit: wordClock.showEleven }
				CC { text: "L"; lit: wordClock.showEleven }
				CC { text: "E"; lit: wordClock.showEleven }
				CC { text: "V"; lit: wordClock.showEleven }
				CC { text: "E"; lit: wordClock.showEleven }
				CC { text: "N"; lit: wordClock.showEleven }
			}

			// Row 9:  S E V E N T W E L V E
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "S"; lit: wordClock.showSeven }
				CC { text: "E"; lit: wordClock.showSeven }
				CC { text: "V"; lit: wordClock.showSeven }
				CC { text: "E"; lit: wordClock.showSeven }
				CC { text: "N"; lit: wordClock.showSeven }
				CC { text: "T"; lit: wordClock.showTwelve }
				CC { text: "W"; lit: wordClock.showTwelve }
				CC { text: "E"; lit: wordClock.showTwelve }
				CC { text: "L"; lit: wordClock.showTwelve }
				CC { text: "V"; lit: wordClock.showTwelve }
				CC { text: "E"; lit: wordClock.showTwelve }
			}

			// Row 10:  T E N S E O C L O C K
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 2
				CC { text: "T"; lit: wordClock.showTen }
				CC { text: "E"; lit: wordClock.showTen }
				CC { text: "N"; lit: wordClock.showTen }
				CC { text: "S"; lit: false }
				CC { text: "E"; lit: false }
				CC { text: "O"; lit: wordClock.showOClock }
				CC { text: "C"; lit: wordClock.showOClock }
				CC { text: "L"; lit: wordClock.showOClock }
				CC { text: "O"; lit: wordClock.showOClock }
				CC { text: "C"; lit: wordClock.showOClock }
				CC { text: "K"; lit: wordClock.showOClock }
			}
		}

		// ── Password entry + lock icon ────────────────────────────────
		Column {
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: parent.height * 0.10
			}
			spacing: GlobalVariables.controls.spacing * 2

			// lock icon (decorative, matches the image bottom)
			IconImage {
				anchors.horizontalCenter: parent.horizontalCenter
				implicitSize: 28
				source: Quickshell.iconPath("system-lock-screen")
				layer.enabled: true
				layer.effect: ColorOverlay {
					color: GlobalVariables.colours.text
				}
			}

			// password row
			Row { id: passwd
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: GlobalVariables.controls.spacing

				Rectangle {
					width: 280
					height: textInput.height + GlobalVariables.controls.padding
					radius: GlobalVariables.controls.radius
					color: GlobalVariables.colours.base
					opacity: 0.90

					Style.Borders { opacity: 0.4; }

					TextInput { id: textInput
						anchors.centerIn: parent
						width: parent.width - 8
						focus: true
						cursorDelegate: Item {}
						font: GlobalVariables.font.monolarge
						horizontalAlignment: Text.AlignHCenter
						color: lockContext.unlockInProgress ? GlobalVariables.colours.windowText : GlobalVariables.colours.text
						echoMode: TextInput.Password
						passwordCharacter: ""
						inputMethodHints: Qt.ImhSensitiveData
						enabled: !lockContext.unlockInProgress
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: textInput.width
								height: textInput.height
								radius: GlobalVariables.controls.radius
							}
						}
						onTextChanged: { lockContext.passwd = this.text; lockContext.showFailure = false; }
						onAccepted: if (!lockContext.unlockInProgress) lockContext.tryUnlock();
					}

					Connections {
						target: lockContext
						function onFailed() { textInput.clear(); lockContext.showFailure = true; }
					}

					Text {
						anchors.centerIn: parent
						visible: lockContext.showFailure
						text: "Incorrect password"
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.italic
					}
				}

				Ctrl.QsButton { id: btn
					readonly property bool enabled: !lockContext.unlockInProgress && textInput.text

					shade: enabled
					anim: enabled
					onClicked: if (enabled) textInput.accepted();
					content: Rectangle {
						width: textInput.height + GlobalVariables.controls.padding
						height: width
						radius: GlobalVariables.controls.radius
						color: GlobalVariables.colours.base
						opacity: 0.90
						layer.enabled: true
						layer.effect: ColorOverlay {
							property color baseColor: GlobalVariables.colours.shadow
							property color semiTransparent: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.5)
							color: btn.enabled ? "transparent" : semiTransparent
						}

						Style.Borders { opacity: 0.4; }

						IconImage {
							anchors.centerIn: parent
							implicitSize: parent.height - GlobalVariables.controls.spacing / 2
							source: Quickshell.iconPath("draw-arrow-forward")
						}
					}
				}
			}

			// music player (optional, only shown when active)
			RowLayout {
				visible: Service.MusicPlayer.active
				spacing: GlobalVariables.controls.spacing
				clip: false

				Ctrl.QsButton {
					onClicked: Service.MusicPlayer.activePlayer.togglePlaying();
					content: Image { id: coverArt
						height: Math.min(64, sourceSize.height)
						source: Service.MusicPlayer.track.art
						fillMode: Image.PreserveAspectFit
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: coverArt.width
								height: coverArt.height
								radius: GlobalVariables.controls.radius
							}
						}
					}

					IconImage {
						anchors.centerIn: parent
						visible: parent.containsMouse
						implicitSize: 32
						source: Service.MusicPlayer.activePlayer.isPlaying ? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
						layer.enabled: true
						layer.effect: ColorOverlay { color: GlobalVariables.colours.text; }
					}
				}

				ColumnLayout { id: trackInfo
					Layout.alignment: Qt.AlignTop
					spacing: GlobalVariables.controls.spacing / 2

					Text { id: nowPlaying
						text: "Now Playing"
						color: Service.MusicPlayer.track.accentColour
						font.family: GlobalVariables.font.sans
						font.pointSize: 10
						font.weight: 600
						font.letterSpacing: 1.2
						layer.enabled: true
						layer.effect: Glow {
							samples: 48
							color: {
								if (nowPlaying.color.hslLightness > 0.5) return Qt.darker(nowPlaying.color, 1.5);
								else return Qt.darker(nowPlaying.color, 0.8);
							}
						}
					}

					Ctrl.Marquee {
						Layout.fillWidth: true
						leftAlign: true
						content: Row {
							spacing: GlobalVariables.controls.spacing / 2

							Text {
								text: Service.MusicPlayer.track.title
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.semibold
							}

							Text {
								text: `by ${Service.MusicPlayer.track.artist}`
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.italic
							}
						}
						layer.enabled: true
						layer.effect: DropShadow {
							samples: 48
							color: GlobalVariables.colours.shadow
						}
					}
				}
			}
		}

		// for debug purposes
		// Ctrl.QsButton {
		// 	// anchors.centerIn: parent
		// 	onClicked: lockContext.unlocked();
		// 	content: Text {
		// 		text: "Unlock me now"
		// 		color: GlobalVariables.colours.text
		// 		font: GlobalVariables.font.regular
		// 	}
		// }
	}

	property list<var> wallpaper

	function init() {}
	function lock(transition = true) {
		if (transition) transitionScreens.start();
		else {
			getWallpaper.running = true;
			lock.locked = true;
		}
	}

	Service.LockContext { id: lockContext
		onUnlocked: lock.locked = false;
	}

	WlSessionLock { id: lock
		surface: WlSessionLockSurface { id: surface
			color: GlobalVariables.colours.dark

			Image {
				anchors.fill: parent
				source: root.wallpaper.find(w => w.display === surface.screen.name).path
				fillMode: Image.PreserveAspectCrop
				layer.enabled: true
				layer.effect: GaussianBlur { samples: 128; }
			}

			Loader {
				anchors.fill: parent
				focus: true
				active: parent.visible
				sourceComponent: content
			}
		}
	}

	Variants { id: transitionScreens
		signal start()

		model: Quickshell.screens
		delegate: PanelWindow { id: window
			required property var modelData

			screen: modelData
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			WlrLayershell.layer: WlrLayershell.Overlay
			WlrLayershell.exclusiveZone: -1
			mask: Region {}
			// color: "#10ff0000"
			color: "transparent"

			Loader { id: transitionContainer
				anchors.fill: parent
				active: false
				sourceComponent: content
				opacity: 0.0
				transform: Translate { id: transitionTrans; y: -height; }

				Image {
					anchors.fill: parent
					source: root.wallpaper.find(w => w.display === window.modelData.name).path
					fillMode: Image.PreserveAspectCrop
					layer.enabled: true
					layer.effect: GaussianBlur { samples: 128; }
				}
			}

			ParallelAnimation { id: transitionAnim
				property int duration: 250

				onStarted: getWallpaper.running = true;
				onFinished: { lock.locked = true; }

				NumberAnimation {
					target: transitionContainer
					property: "opacity"
					to: 1.0
					duration: transitionAnim.duration
					easing.type: Easing.OutCirc
				}

				NumberAnimation {
					target: transitionTrans
					property: "y"
					to: 0
					duration: transitionAnim.duration
					easing.type: Easing.OutSine
				}
			}

			Connections {
				target: transitionScreens
				function onStart() {
					transitionContainer.active = true;
					transitionAnim.restart();
				}
			}

			Connections {
				target: lockContext
				function onUnlocked() {
					transitionContainer.opacity = 0.0;
					transitionTrans.y = -height;
					transitionContainer.active = false;
				}
			}
		}
	}

	Process { id: getWallpaper
		running: true
		command: ['swww', 'query']
		stdout: StdioCollector {
			onStreamFinished: {
				var ws = text.trim().split('\n');

				root.wallpaper = [];

				for (let w of ws) {
					const parts = w.match(/^:\s*(\S+):\s*([^,]+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)$/);

					if (!parts) continue;

					root.wallpaper.push({
						display: parts[1],
						resolution: parts[2],
						scale: parts[3],
						type: parts[4],
						path: parts[5]
					});
				}
			}
		}
	}

	IpcHandler {
		target: "lock"
		function lockScreen(transition: bool): void { if (!lock.locked) { root.lock(transition); }}
	}
}
