import airAssignments 1.0
import InputAssignment 0.1
import OutputAssignment 0.1
import QtQuick 2.0

MidiAssignment {
	id: assignment
	objectName: "LC6000 Center Wheel Assignment"

	readonly property string deckIndex: {
		// `deviceName` is set in `airAssignments::Midi::Thread::run()`
		if(deviceName.endsWith('3') || deviceName.endsWith('4')) {
			deviceName.slice(-1)
		}
		else {
			'2'
		}
	}

	readonly property QObjProperty pCurrentDeviceArtwork: Planck.getProperty("/Client/Librarian/DevicesController/CurrentDeviceArtwork")
	readonly property bool hasCurrentDeviceArtwork: pCurrentDeviceArtwork && pCurrentDeviceArtwork.translator ? pCurrentDeviceArtwork.translator.size > 0 : false

	readonly property QObjProperty pSongLoaded: Planck.getProperty("/Engine/Deck%1/Track/SongLoaded".arg(deckIndex))
	readonly property bool songLoaded: pSongLoaded && pSongLoaded.translator ? pSongLoaded.translator.state : false

	readonly property QObjProperty pDeckColor: Planck.getProperty("/Engine/Deck%1/JogColor".arg(deckIndex))
	property color deckColor: pDeckColor && pDeckColor.translator ? pDeckColor.translator.color : Qt.rgba(1,1,1,1)
	onDeckColorChanged: device.deckColor = deckColor

	Painter {
		id: pantr
		objectName: "Album Artwork"
		height: 198
		width: 198
		format: Painter.AZ01_CENTER_WHEEL_DISPLAY

		readonly property QObjProperty pAlbumArt: Planck.getProperty("/Engine/Deck%1/AlbumArt".arg(assignment.deckIndex))
		readonly property var albumArt: pAlbumArt && pAlbumArt.translator ? pAlbumArt.translator.bytearray : ""

		readonly property var currentDeviceArtwork: assignment.pCurrentDeviceArtwork && assignment.pCurrentDeviceArtwork.translator ? assignment.pCurrentDeviceArtwork.translator.bytearray : ""

		property bool hasValidArtwork: false

		onHasValidArtworkChanged: updateArtworkSettingsOnDevice()

		readonly property bool songLoaded: assignment.songLoaded
		onSongLoadedChanged: updateArtworkSettingsOnDevice()

		readonly property int deviceArtworkIndex: 2

		function updateArtworkSettingsOnDevice() {
			device.artwork.enabled = true

			if(assignment.hasCurrentDeviceArtwork) {
				device.artwork.index = deviceArtworkIndex
			}
			else if(hasValidArtwork && assignment.songLoaded) {
				device.artwork.index = 1
			}
			else {
				device.artwork.index = 0
			}
		}

		Component.onCompleted: {
			draw()
			updateArtworkSettingsOnDevice()
		}

		onAlbumArtChanged: {
			if(!assignment.hasCurrentDeviceArtwork) {
				draw()
				updateArtworkSettingsOnDevice()
			}
		}

		onCurrentDeviceArtworkChanged: {
			draw()
			updateArtworkSettingsOnDevice()
		}

		function draw() {
			begin()

			clear("white")
			translate(width, height)
			rotate(180)

			if(!drawByteArray(assignment.hasCurrentDeviceArtwork ? currentDeviceArtwork : albumArt, 0, 0, width, height))
			{
				hasValidArtwork = false
				return
			}

			drawHole("black", Qt.rect(0, 0, width, height), Qt.point(width / 2, height / 2), (width / 2) - 4)

			var data = imageToByteArrays(assignment.hasCurrentDeviceArtwork ? deviceArtworkIndex : 1, 0x10, 0x01)

			Midi.sendByteArrays(data)

			device.setElementARGB(0, Qt.rgba(1.0, 1.0, 1.0, device.artwork.alpha))

			hasValidArtwork = true
		}
	}


	Item {
		objectName: "Logo"

		readonly property bool logoEnabled: !assignment.hasCurrentDeviceArtwork && !assignment.songLoaded
		onLogoEnabledChanged: device.logo.enabled = logoEnabled
		Component.onCompleted: device.logo.enabled = logoEnabled
	}

	Item {
		id: platterPosition
		objectName: "Platter Position"

		readonly property bool platterPositionEnabled: assignment.songLoaded
		onPlatterPositionEnabledChanged: device.platterPosition.enabled = platterPositionEnabled

		Timer {
			interval: 12
			running: platterPosition.platterPositionEnabled
			repeat: true

			property int lastPos: 0
			property int lastSlipPos: 0
			readonly property real sampleRate: 44100.0
			readonly property real divider: 60.0 / (33.0 + (1.0/3.0))
			readonly property int mod: divider * sampleRate

			property var positionItems: [
				Planck.createPositionItem("/Private/Deck%1/MidiSamplePosition".arg(assignment.deckIndex)),
			]

			Component.onDestruction: {
				Planck.destroyPositionItem(positionItems[0])

				positionItems = [];
			}

			onTriggered: {
				var posItem = positionItems[0]

				if(posItem)
				{
					posItem.update()
					var pos = posItem.currentPosition();
					var slipPos = posItem.currentSlipPosition();

					if(pos !== lastPos)
					{
						lastPos = pos
						const modulo = (pos % mod + mod) % mod
						const angle = (modulo / sampleRate) / divider
						Midi.sendPitch(0, angle)
					}
					if(slipPos !== lastSlipPos)
					{
						lastSlipPos = slipPos
						const modulo = (slipPos % mod + mod) % mod
						const slipAngle = (modulo / sampleRate) / divider
						Midi.sendPitch(1, slipAngle)
					}
				}
			}
		}
	}

	Item {
		objectName: "Slip Position"

		readonly property QObjProperty pSlipModeActive: Planck.getProperty("/Engine/Deck%1/Track/SlipModeActive".arg(assignment.deckIndex))
		readonly property bool slipModeActive: pSlipModeActive && pSlipModeActive.translator ? pSlipModeActive.translator.state : false

		readonly property bool slipModeEnabled: device.slipPosition.active = slipModeActive && assignment.songLoaded
		onSlipModeEnabledChanged: device.slipPosition.active = slipModeEnabled
	}

	Item {
		id: loop
		objectName: "Loop"

		readonly property QObjProperty pAutoLoopIndex: Planck.getProperty("/Engine/Deck%1/Track/AutoLoopIndex".arg(assignment.deckIndex))
		readonly property int currentIndex: pAutoLoopIndex.translator ? pAutoLoopIndex.translator.index : 0
		readonly property bool editable: pAutoLoopIndex.translator ? pAutoLoopIndex.translator.editable : false

		readonly property QObjProperty pLoopEnableState: Planck.getProperty("/Engine/Deck%1/Track/LoopEnableState".arg(assignment.deckIndex))
		readonly property bool loopEnableState: pLoopEnableState && pLoopEnableState.translator ? pLoopEnableState.translator.state : false

		readonly property bool loopEnabled: loopEnableState
		onLoopEnabledChanged: {
			loopHideTimer.stop()
			if(loopEnabled) {
				show()
			}
			else {
				hide()
			}
		}

		readonly property QObjProperty pAutoLoopLabel: Planck.getProperty("/Engine/Deck%1/Track/AutoLoopLabel%2".arg(assignment.deckIndex).arg(currentIndex + 1))
		readonly property string loopText: editable ? pAutoLoopLabel.translator ? pAutoLoopLabel.translator.string : "" : "--"
		onLoopTextChanged: {
			device.loopAndLayerText.text = loopText
			show()
		}

		function show() {
			if(assignment.songLoaded) {
				device.loopAndLayerText.enabled = true
				device.artwork.alpha = 0.5

				if(!loopEnabled) {
					loopHideTimer.start()
				}
			}
		}

		function hide() {
			device.loopAndLayerText.enabled = false
			device.artwork.alpha = 0.85
		}

		Timer {
			id: loopHideTimer
			interval: 1000
			repeat: false
			onTriggered: loop.hide()
		}
	}

	OutputAssignment {
		objectName: "Screen Brightness"

		readonly property string screenBrightness: Planck.getProperty("/Client/Preferences/ScreenBrightnessPluggedIn").translator.string
		onScreenBrightnessChanged: send()

		function send() {
			var brightness = 0
			if(screenBrightness === "Low") {
				brightness = 15
			}
			else if(screenBrightness === "Mid") {
				brightness = 70
			}
			else if(screenBrightness === "High") {
				brightness = 105
			}
			else if(screenBrightness === "Max") {
				brightness = 127
			}

			Midi.sendSysEx("F0 00 02 0B 01 10 7c 00 01 %1 F7".arg(device.d2h(brightness)))
		}

		Component.onCompleted: send()
	}
}
