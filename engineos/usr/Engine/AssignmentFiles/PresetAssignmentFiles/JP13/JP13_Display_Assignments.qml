import airAssignments 1.0
import InputAssignment 0.1
import OutputAssignment 0.1
import QtQuick 2.0

MidiAssignment {
	id: assignment
	objectName: "SE1000 Center Wheel Assignment"
	
	readonly property QObjProperty pActiveDeck: Planck.getProperty("/GUI/Decks/Deck/ActiveDeck")
	readonly property string activeDeckIndex: pActiveDeck.translator.string
	
	readonly property QObjProperty pCurrentDeviceArtwork: Planck.getProperty("/Client/Librarian/DevicesController/CurrentDeviceArtwork")
	readonly property bool hasCurrentDeviceArtwork: pCurrentDeviceArtwork && pCurrentDeviceArtwork.translator ? pCurrentDeviceArtwork.translator.size > 0 : false
	
	readonly property QObjProperty pSongLoaded: Planck.getProperty("/Engine/Deck%1/Track/SongLoaded".arg(activeDeckIndex))
	readonly property bool songLoaded: pSongLoaded && pSongLoaded.translator ? pSongLoaded.translator.state : false
	
	readonly property color jogColor: Planck.getProperty("/Engine/Deck%1/JogColor".arg(assignment.activeDeckIndex)).translator.color
	onJogColorChanged: device.deckColor = jogColor
	
	property bool isSwitchingLayer: false


	Repeater {
		model: 2
		
		Item {
			Painter {
				objectName: "Album Artwork Layer " + (index+1)
				height: 198
				width: 198
				format: Painter.AZ01_CENTER_WHEEL_DISPLAY
				
				readonly property QObjProperty pAlbumArt: Planck.getProperty("/Engine/Deck%1/AlbumArt".arg(index+1))
				readonly property var albumArt: pAlbumArt && pAlbumArt.translator ? pAlbumArt.translator.bytearray : ""
				
				readonly property var currentDeviceArtwork: index == 0 && assignment.pCurrentDeviceArtwork && assignment.pCurrentDeviceArtwork.translator ? assignment.pCurrentDeviceArtwork.translator.bytearray : ""
				
				property bool hasValidArtwork: false
				property string activeDeckIndex: assignment.activeDeckIndex
				
				onHasValidArtworkChanged: updateArtworkSettingsOnDevice()
				onActiveDeckIndexChanged: updateArtworkSettingsOnDevice()
				
				readonly property bool songLoaded: assignment.songLoaded
				onSongLoadedChanged: updateArtworkSettingsOnDevice()
				
				readonly property int deviceArtworkIndex: 3
				
				function updateArtworkSettingsOnDevice() {
					if(assignment.hasCurrentDeviceArtwork && index == 1) {
						return
					}
					
					if(parseInt(assignment.activeDeckIndex) === index + 1) {
						device.artwork.enabled = true
						
						if(assignment.hasCurrentDeviceArtwork) {
							device.artwork.index = deviceArtworkIndex
						}
						else if(hasValidArtwork && songLoaded) {
							device.artwork.index = index + 1
						}
						else {
							device.artwork.index = 0
						}
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
					if(assignment.hasCurrentDeviceArtwork && index == 1) {
						return
					}

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
					
					var data = imageToByteArrays(assignment.hasCurrentDeviceArtwork ? deviceArtworkIndex : 1 + index, 0x0D, 0x01)

					Midi.sendByteArrays(data)

					device.setElementARGB(0, Qt.rgba(1.0, 1.0, 1.0, device.artwork.alpha))
					
					hasValidArtwork = true
				}
			}
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
			
			readonly property real divider: 60.0 / (33.0 + (1.0/3.0))
			readonly property int mod: divider * 44100.0
			
			property var positionItems: [
				Planck.createPositionItem("/Private/Deck1/MidiSamplePosition"),
				Planck.createPositionItem("/Private/Deck2/MidiSamplePosition")
			]
			
			Component.onDestruction: {
				Planck.destroyPositionItem(positionItems[0])
				Planck.destroyPositionItem(positionItems[1])
				
				positionItems = [];
			}
			
			onTriggered: {
				var posItem = positionItems[parseInt(assignment.activeDeckIndex)-1]
				
				if(posItem)
				{
					posItem.update()
					var pos = posItem.currentPosition();
					var slipPos = posItem.currentSlipPosition();
					
					if(pos !== lastPos)
					{
						lastPos = pos;
						const modulo = (pos%mod + mod) % mod
						const angle = ( modulo / 44100.0) / divider;
						Midi.sendPitch(0, angle)
					}
					if(slipPos !== lastSlipPos)
					{
						lastSlipPos = slipPos;
						const modulo = (slipPos%mod + mod) % mod
						const slipAngle = (modulo / 44100.0) / divider;
						Midi.sendPitch(1, slipAngle)
					}
				}
			}
		}
	}
	
	Item {
		objectName: "Slip Position"
		
		readonly property QObjProperty pSlipModeActive: Planck.getProperty("/Engine/Deck%1/Track/SlipModeActive".arg(assignment.activeDeckIndex))
		readonly property bool slipModeActive: pSlipModeActive && pSlipModeActive.translator ? pSlipModeActive.translator.state : false
		
		readonly property bool slipModeEnabled: device.slipPosition.active = slipModeActive && assignment.songLoaded
		onSlipModeEnabledChanged: device.slipPosition.active = slipModeEnabled
	}
	
	Item {
		objectName: "Loop"
		id: loop
		
		readonly property QObjProperty pAutoLoopIndex: Planck.getProperty("/Engine/Deck%1/Track/AutoLoopIndex".arg(assignment.activeDeckIndex))
		readonly property int currentIndex: pAutoLoopIndex.translator ? pAutoLoopIndex.translator.index : 0
		readonly property bool editable: pAutoLoopIndex.translator ? pAutoLoopIndex.translator.editable : false

		readonly property QObjProperty pLoopEnableState: Planck.getProperty("/Engine/Deck%1/Track/LoopEnableState".arg(assignment.activeDeckIndex))
		readonly property bool loopEnableState: pLoopEnableState && pLoopEnableState.translator ? pLoopEnableState.translator.state : false
		
		readonly property bool loopEnabled: loopEnableState && !assignment.isSwitchingLayer
		onLoopEnabledChanged: {
			loopHideTimer.stop()
			if(loopEnabled) {
				show()
			}
			else {
				hide()
			}
		}
		
		readonly property bool isSwitchingLayer: assignment.isSwitchingLayer
		onIsSwitchingLayerChanged: {
			if(!isSwitchingLayer) {
				device.loopAndLayerText.text = loopText
			}
		}

		readonly property QObjProperty pAutoLoopLabel: Planck.getProperty("/Engine/Deck%1/Track/AutoLoopLabel%2".arg(assignment.activeDeckIndex).arg(currentIndex + 1))
		readonly property string loopText: editable ? pAutoLoopLabel.translator ? pAutoLoopLabel.translator.string : "" : "--"
		onLoopTextChanged: {
			if(!assignment.isSwitchingLayer) {
				device.loopAndLayerText.text = loopText
				show()
			}
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
	
	Item {
		objectName: "Layer"
		id: deckLayer

		readonly property QObjProperty pViewLayer: Planck.getProperty ("/GUI/Decks/Deck/Layer")
		readonly property int viewLayer: pViewLayer && pViewLayer.translator ? pViewLayer.translator.unnormalized : false
		
		onViewLayerChanged: {
			show()
			viewLayerHideTimer.restart()
		}
		
		function show() {
			assignment.isSwitchingLayer = true
			device.logo.enabled = false
			device.loopAndLayerText.text = viewLayer == 0 ? "A" : "B"
			device.loopAndLayerText.enabled = true
			device.artwork.alpha = 0.5
		}

		function hide() {
			device.logo.enabled = !assignment.hasCurrentDeviceArtwork && !assignment.songLoaded
			device.loopAndLayerText.enabled = false
			device.artwork.alpha = 0.85
			assignment.isSwitchingLayer = false
		}
		
		Timer {
			id: viewLayerHideTimer
			interval: 1000
			onTriggered: deckLayer.hide()
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

			Midi.sendSysEx("F0 00 02 0B 01 0D 7c 00 01 %1 F7".arg(device.d2h(brightness)))
		}
		
		Component.onCompleted: send()
	}
}
