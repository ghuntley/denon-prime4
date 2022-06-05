import airAssignments 1.0
import InputAssignment 0.1
import OutputAssignment 0.1
import ControlSurfaceModules 0.1
import QtQuick 2.12

MidiAssignment {
	objectName: 'PRIME 4 Controller Assignment'
	id: assignment

	Utility {
		id: util
	}

	GlobalAssignmentConfig {
		id: globalConfig
		midiChannel: 15
	}

	GlobalAction {
		id: globalAction
	}

	Back {
		note: 3
		ledType: LedType.Simple
	}

	Forward {
		note: 4
		shiftAction: Action.Quantize
		ledType: LedType.Simple
	}

	BrowseEncoder {
		pushNote: 6
		turnCC: 5
		ledType: LedType.Simple
	}

	View {
		note: 7
		shiftAction: Action.SwitchMainViewLayout
		holdAction: Action.ToggleControlCenter
		ledType: LedType.Simple
	}

	ZoneOut {
		note: 16
	}

	Media {
		mediaButtonsModel: ListModel {
			ListElement {
				name: 'Eject'
				shiftName: 'Source'
				note: 20
				hasLed: true
			}
		}
		removableDeviceModel: ListModel {
			ListElement {	// SD
				slot: '1'
				note: 52
			}
			ListElement {	// USB 1
				slot: '6'
				note: 53
			}
			ListElement {	// USB 2
				slot: '5'
				note: 54
			}
		}
	}

	Repeater {
		model: ListModel {
			ListElement {
				deckName: 'Left'
				deckMidiChannel: 4
				loadNote: 1
			}
			ListElement {
				deckName: 'Right'
				deckMidiChannel: 5
				loadNote: 2
			}
		}

		Item {
			objectName: 'Deck %1'.arg(model.deckName)

			DeckAssignmentConfig {
				id: deckConfig
				name: model.deckName
				midiChannel: model.deckMidiChannel
			}

			DeckAction {
				id: deckAction
			}

			Load {
				note: model.loadNote
				ledType: LedType.RGB
			}

			Censor {
				note: 1
			}

			TrackSkip {
				prevNote: 4
				nextNote: 5
			}

			BeatJump {
				prevNote: 6
				nextNote: 7
			}

			Sync {
				syncNote: 8
				syncHoldAction: Action.InstantDouble
			}

			PlayCue {
				cueNote: 9
				cueShiftAction: Action.SetCuePoint
				playNote: 10
			}

			PerformanceModes {
				ledType: LedType.RGB
				modesModel: ListModel {
					ListElement {
						note: 11
						view: 'CUES'
					}
					ListElement {
						note: 12
						view: 'LOOPS'
						altView: 'AUTO'
					}
					ListElement {
						note: 13
						view: 'ROLL'
					}
					ListElement {
						note: 14
						view: 'SLICER'
						altView: 'FIXED'
					}
				}
			}

			ActionPads {
				firstPadNote: 15
				ledType: LedType.RGB
			}

			Parameter {
				leftNote: 23
				rightNote: 24
			}

			BeatGrid {
				leftNote: 25
				rightNote: 26
				editGridNote: 27
			}

			Shift {
				note: 28
				ledType: LedType.Simple
			}

			PitchBend {
				minusNote: 29
				plusNote: 30
			}

			JogWheel {
				touchNote: 33
				ccUpper: 0x37
				ccLower: 0x4D
				jogSensitivity: 1638.7 * 3.6
				ledType: LedType.RGB
			}

			KeyLock {
				note: 34
			}

			Vinyl {
				note: 35
			}

			Slip {
				note: 36
			}

			ManualLoop {
				inNote: 37
				outNote: 38
			}

			AutoLoop {
				pushNote: 39
				turnCC: 32
				ledType: LedType.Simple
			}

			SpeedSlider {
				ccUpper: 0x1F
				ccLower: 0x4B
				downLedNote: 42
				centreLedNote: 43
				upLedNote: 44
			}

			DeckSelect {
				primaryDeckIndex: 1 + model.index
				primaryDeckNote: 28 + model.index
			}
		}
	}

	// Numbers of channels arranged from left to right:
	readonly property var mixerChannelOrder: [3,1,2,4]
	Repeater {
		model: mixerChannelOrder

		ValueNoteAssignment {
			objectName: "Channel%1 Line".arg(modelData)
			note: 21 + index
			channel: 15
			output: QtObject {
				readonly property QObjProperty pLine: Planck.getProperty("/Engine/Mixer/Channel%1/Line".arg(modelData))
				function setValue(channel, value, assignmentEnabled) {
					if(assignmentEnabled) {
						pLine.translator.value = value
					}
				}
			}
		}
	}

	Repeater {
		model: 4
		Item {
			ColorOutputAssignment {
				objectName: "Mixer Cue color for deck %1".arg(index + 1)
				idx: 13
				channel: index
				
				readonly property color deckColor: Planck.getProperty("/Client/Preferences/Profile/Application/PlayerColor%1".arg(index + 1)).translator.color
				onColor: deckColor
			}
		}
		Component.onCompleted: {
			device.sendSimpleColor(15, 11, 1) //Split
			device.sendSimpleColor(15, 12, 1) //Dub Echo
			device.sendSimpleColor(15, 13, 1) //Noise
			device.sendSimpleColor(15, 14, 1) //Wash Out
			device.sendSimpleColor(15, 15, 1) //Gate

			device.sendSimpleColor(15, 35, 1) //Mic Talkover
			device.sendSimpleColor(15, 36, 1) //Mic 1 On/Off
			device.sendSimpleColor(15, 37, 1) //Mic 2 On/Off
			device.sendSimpleColor(15, 38, 1) //Mic 1 Echo On/Off
			device.sendSimpleColor(15, 39, 1) //Mic 2 Echo On/Off
		}
	}

	/////// FX

	Repeater {
		model: ListModel {
			ListElement {
				deck: "1"
				controlChannel: 8
				ccIndex: 11
			}
			ListElement {
				deck: "2"
				controlChannel: 9
				ccIndex: 11
			}
			ListElement {
				deck: "3"
				controlChannel: 8
				ccIndex: 13
			}
			ListElement {
				deck: "4"
				controlChannel: 9
				ccIndex: 13
			}
		}
		OutputAssignment {
			properties: { 'currentBpm' : '' }

			readonly property QObjProperty pCurrentBPM: Planck.getProperty("/Engine/Deck%1/CurrentBPM".arg(deck))
			readonly property int currentBpm: pCurrentBPM && pCurrentBPM.translator ? Math.round(pCurrentBPM.translator.unnormalized * 10) : 1200
			readonly property int minMixerTempo: 60 * 10
			readonly property int maxMixerTempo: 300 * 10

			function send() {
				if(currentBpm === 0) {
					return
				}
				var bpm = currentBpm
				Math.log2 = Math.log2 || function(x){return Math.log(x)*Math.LOG2E;};
				if(currentBpm < minMixerTempo) {
					var wrapPower = Math.ceil(Math.log2(minMixerTempo / currentBpm))
					bpm = currentBpm * Math.pow(2, wrapPower)
				}
				else if(currentBpm > maxMixerTempo) {
					var wrapPower = Math.ceil(Math.log2(currentBpm / maxMixerTempo))
					bpm = currentBpm / Math.pow(2, wrapPower)
				}
				Midi.sendControlChange(controlChannel, ccIndex, (bpm - minMixerTempo) & 0x7F)
				Midi.sendControlChange(controlChannel, ccIndex + 1, (bpm - minMixerTempo) >> 7)
			}
		}
	}

	property bool displaysActive : false
	onDisplaysActiveChanged: {
		if(!displaysActive) {
			clearPainter.draw();
		}
	}

	ValueNoteAssignment {
		objectName: "MIDI Note Activity"
		note: -1
		channel: -1
		output: QtObject {
			function setValue(channel, value, assignmentEnabled) {
				activityTimer.restart()
			}
		}
	}
	ValueCCAssignment {
		objectName: "MIDI CC Activity"
		cc: -1
		channel: -1
		output: QtObject {
			function setValue(channel, value, assignmentEnabled) {
				activityTimer.restart()
			}
		}
	}

	Connections {
		target: globalConfig
		onCurrentFocusAreaChanged: {
			activityTimer.restart()
		}
	}

	Timer {
		id: activityTimer
		interval: 10 * 60 * 1000
		running: true
		onRunningChanged: {
			if(running) {
				displaysActive = true
			}
		}

		onTriggered: displaysActive = false
	}

	Painter {
		id: clearPainter
		width: 128
		height: 64
		format: Painter.AK01_DISPLAY

		function draw()
		{
			setCompositionMode(Painter.SourceOver);

			clear("black")
			setColor("white")

			for (var displayIndex = 0; displayIndex < device.oleds.length; displayIndex++) {
				device.oleds[displayIndex].update(clearPainter)
			}
		}

		Component.onDestruction: clearPainter.draw()
	}


	Repeater {
		model: ListModel {
			ListElement {
				sideChannel: 6
				controlChannel: 8
				displayIndex: 3
				slotName: "FXSlot1"
			}
			ListElement {
				sideChannel: 7
				controlChannel: 9
				displayIndex: 7
				slotName: "FXSlot2"
			}
		}

		Item {
			id: beatSlot
			readonly property QObjProperty pEffectType: Planck.getProperty("/Client/Mixer/%1/EffectList".arg(slotName))
			readonly property string effectType: pEffectType && pEffectType.translator ? pEffectType.translator.string : ""

			readonly property bool hasBeatLengths: Planck.getProperty("/Client/Mixer/%1/BeatLength".arg(slotName)).translator.numEntries > 0

			ValueCCAssignment {
				objectName: "%1 Knob FX WET/DRY".arg(slotName)
				cc: 4
				channel: sideChannel
				enabled: true
				output: JogOutput {
					jogAcceleration: 1.0
					jogSensitivity: 0.5
					roundRobin: false

					type: 0
					target: PropertyTarget {
						path: "/Client/Mixer/%1/WetDry".arg(slotName)
					}
				}
			}

			ValueNoteAssignment {
				objectName: "%1 Beat Decrease Button".arg(slotName)
				note: 9
				channel: sideChannel
				enabled: beatSlot.hasBeatLengths
				output: IncDecValueOutput {
					target: PropertyTarget {
						path: "/Client/Mixer/%1/BeatLength".arg(slotName)
					}
					increaseValue: false
					roundRobin: false
				}
			}
			ValueNoteAssignment {
				objectName: "%1 Beat Increase Button".arg(slotName)
				note: 10
				channel: sideChannel
				enabled: beatSlot.hasBeatLengths
				output: IncDecValueOutput {
					target: PropertyTarget {
						path: "/Client/Mixer/%1/BeatLength".arg(slotName)
					}
					increaseValue: true
					roundRobin: false
				}
			}
			ValueNoteAssignment {
				objectName: "%1 Beat Decrease Button LED".arg(slotName)
				note: 9
				channel: sideChannel
				initialValue: 0.0
				enabled: beatSlot.hasBeatLengths
				resendValueOnEnabledChanged: true

				output: QtObject {
					function setValue(channel, value, assignmentEnabled) {
						device.sendSimpleColor(sideChannel, 9, assignmentEnabled ? (value ? 127 : 1) : 0)
					}
				}
				Component.onCompleted: output.setValue(channel, initialValue, enabled)
			}
			ValueNoteAssignment {
				objectName: "%1 Beat Increase Button LED".arg(slotName)
				note: 10
				channel: sideChannel
				initialValue: 0.0
				enabled: beatSlot.hasBeatLengths
				resendValueOnEnabledChanged: true

				output: QtObject {
					function setValue(channel, value, assignmentEnabled) {
						device.sendSimpleColor(sideChannel, 10, assignmentEnabled ? (value ? 127 : 1) : 0)
					}
				}
				Component.onCompleted: output.setValue(channel, initialValue, enabled)
			}
			
			OutputAssignment {
				properties: { 'beatLength' : '/Client/Mixer/%1/BeatLength'.arg(slotName) }
				function send() {
					if(effectType === 'Bit Crush') {
						Midi.sendControlChange(controlChannel, 0x13, propertyData.beatLength.string)
					}
					else {
						Midi.sendControlChange(controlChannel, 9, propertyData.beatLength.index)
					}
				}
			}
			OutputAssignment {
				properties: { 'wetDry' : '/Client/Mixer/%1/WetDry'.arg(slotName) }
				function send() {
					Midi.sendControlChange(controlChannel, 7, propertyData.wetDry.value * 127)
				}
				readonly property bool fxEnable: Planck.getProperty("/Client/Mixer/%1/Enable".arg(slotName)).translator.state
				onFxEnableChanged: {
					if (fxEnable) {
						send()
					}
				}
			}

			Item {
				Connections {
					target: assignment
					onDisplaysActiveChanged: {
						if(assignment.displaysActive) {
							beatDrawTimer.start()
						}
					}
				}

				Timer {
					id: beatDrawTimer
					interval: 50
					onTriggered: beatDisplayPainter.draw()
				}

				Painter {
					id: beatDisplayPainter
					width: 128
					height: 64
					font.family: "NimbusSanD"
					font.weight: Font.Bold
					font.pixelSize: 14
					font.capitalization: Font.AllUppercase
					format: Painter.AK01_DISPLAY

					property QObjProperty pBeatLength: Planck.getProperty("/Client/Mixer/%1/BeatLength".arg(slotName))
					property string beatLength: pBeatLength && pBeatLength.translator ? pBeatLength.translator.string : ""
					property int beatLengthIndex: pBeatLength && pBeatLength.translator ? pBeatLength.translator.index : 0

					property QObjProperty pValue: Planck.getProperty("/Client/Mixer/%1/WetDry".arg(slotName))
					property real value: pValue && pValue.translator ? pValue.translator.value : 0.25
					property int iValue: Math.round(value * 124)

					property string effectType: beatSlot.effectType

					function draw()
					{
						setCompositionMode(Painter.SourceOver);

						clear("black")
						setColor("white")

						if(effectType === 'Bit Crush') {
							drawTextInRect(0,18, 128, 16, Painter.AlignCenter, "Bits: " + beatLength)
						}
						else if(beatSlot.hasBeatLengths) {
							drawTextInRect(0,18, 128, 16, Painter.AlignCenter, beatLength + (beatLengthIndex > 6 ? " Beats" : " Beat"))
						}

						drawRect(0, 0, 127, 13)
						fillRect(2, 2, value * 124, 10, "white")

						if(value !== 0.5) {
							if(value > 0.5)
								setColor("black")
							drawLine(62, 1, 62, 12)
						}

						device.oleds[displayIndex].update(beatDisplayPainter)
					}

					onEffectTypeChanged: beatDrawTimer.start()
					onBeatLengthChanged: beatDrawTimer.start()
					onIValueChanged: beatDrawTimer.start()

				}
			}
		}
	}

	Repeater {
		model: ListModel {
			ListElement {
				sideChannel: 6
				controlChannel: 8
				displayIndex: 0
				slotName: "FXSlot1"
			}
			ListElement {
				sideChannel: 7
				controlChannel: 9
				displayIndex: 4
				slotName: "FXSlot2"
			}
		}

		Item {
			id: fxBank
			ValueCCAssignment {
				objectName: "%1 Knob FX SELECT".arg(slotName)
				cc: 1
				channel: sideChannel
				enabled: true
				output: JogOutput {
					jogAcceleration: 1.0
					jogSensitivity: 1.0

					type: 0
					target: PropertyTarget {
						path: "/Client/Mixer/%1/EffectJogWrapper".arg(slotName)
					}
				}
			}

			ValueCCAssignment {
				objectName: "%1 Knob FX PARAMETER".arg(slotName)
				cc: 2
				channel: sideChannel
				enabled: true
				output: JogOutput {
					jogAcceleration: 1.0
					jogSensitivity: 0.5
					roundRobin: false

					type: 0
					target: PropertyTarget {
						path: "/Client/Mixer/%1/ParamValueJogWrapper".arg(slotName)
					}
				}
			}
			ValueCCAssignment {
				objectName: "%1 Knob FX FREQUENCY".arg(slotName)
				cc: 3
				channel: sideChannel
				enabled: true
				output: JogOutput {
					jogAcceleration: 1.0
					jogSensitivity: 0.25
					roundRobin: false

					type: 0
					target: PropertyTarget {
						path: "/Client/Mixer/%1/FrequencyJogWrapper".arg(slotName)
					}
				}
			}

			ValueNoteAssignment {
				note: 6
				channel: sideChannel
				enabled: device.shift
				output: IncDecValueOutput {
					target: PropertyTarget {
						path: "/Client/Mixer/%1/EffectList".arg(slotName)
					}
					changeAmount: 1
					increaseValue: true
					roundRobin: true
				}
			}
			ValueNoteAssignment {
				objectName: '%1 Button ON'.arg(slotName)
				note: 6
				channel: sideChannel
				output: QtObject {
					function setValue(channel, value, assignmentEnabled) {
						if(value<0.5) {
							return
						}
						var pEnable = Planck.getProperty("/Client/Mixer/%1/Enable".arg(slotName))
						if(!device.shift) {
							pEnable.translator.state = !pEnable.translator.state
						} else if(pEnable.translator.state) {
							pEnable.translator.state = false
						}
					}
				}
			}
			ValueNoteAssignment {
				objectName: '%1 Button PARAM'.arg(slotName)
				note: 7
				channel: sideChannel
				enabled: true
				output: QtObject {
					function setValue(channel, value, assignmentEnabled) {
						if(value<0.5) {
							return
						}
						var pTwoStateParam = Planck.getProperty("/Client/Mixer/%1/TwoStateParam".arg(slotName))
						pTwoStateParam.translator.state = !pTwoStateParam.translator.state
					}
				}
			}
			ValueNoteAssignment {
				objectName: '%1 Button RESET'.arg(slotName)
				note: 8
				channel: sideChannel
				enabled: true
				output: QtObject {
					function setValue(channel, value, assignmentEnabled) {
						Midi.sendNoteOn(sideChannel, 8, value<0.5 ? 1 : 127)
						if(value<0.5) {
							return
						}
						Planck.getProperty("/Client/Mixer/%1/FrequencyJogWrapper".arg(slotName)).translator.value = 0.5

						var pTwoStateParam = Planck.getProperty("/Client/Mixer/%1/Reset".arg(slotName))
						pTwoStateParam.translator.state = true
					}
				}
			}

			OutputAssignment {
				properties: { 'type' : '/Client/Mixer/%1/EffectList'.arg(slotName) }
				function send() {
					Midi.sendControlChange(controlChannel, 1, propertyData.type.unnormalized)
					if(propertyData.type.string === 'Bit Crush') {
						Midi.sendControlChange(controlChannel, 0x13, Planck.getProperty("/Client/Mixer/%1/BeatLength".arg(slotName)).translator.string)
					}
					else {
						Midi.sendControlChange(controlChannel, 9, Planck.getProperty("/Client/Mixer/%1/BeatLength".arg(slotName)).translator.index)
					}
				}
			}
			OutputAssignment {
				properties: { 'fxValue' : "/Client/Mixer/%1/ParamValue".arg(slotName) }
				function send() {
					Midi.sendControlChange(controlChannel, 5, propertyData.fxValue.value * 127)
				}
			}
			OutputAssignment {
				properties: { 'fxValue' : "/Client/Mixer/%1/Frequency".arg(slotName) }
				function send() {
					Midi.sendControlChange(controlChannel, 6, propertyData.fxValue.value * 127)
				}
			}
			OutputAssignment {
				properties: { 'fxEnable' : "/Client/Mixer/%1/Enable".arg(slotName) }
				function send() {
					if(propertyData.fxEnable.state) {
						Midi.sendNoteOn(sideChannel, 6, 127) //color
						Midi.sendNoteOn(controlChannel, 1, 127) //inform dsp
					} else {
						Midi.sendNoteOn(sideChannel, 6, 1) //color
						Midi.sendNoteOn(controlChannel, 1, 0) //inform dsp
						Midi.sendNoteOff(controlChannel, 1) //inform dsp

						var pTwoStateParam = Planck.getProperty("/Client/Mixer/%1/TwoStateParam".arg(slotName))
						if (pTwoStateParam.translator.state === true) {
							pTwoStateParam.translator.state = false
						}
					}
				}
			}
			OutputAssignment {

				properties: {
					'fxTwoState' : "/Client/Mixer/%1/TwoStateParam".arg(slotName),
					'fxTwoStateParamName' : "/Client/Mixer/%1/TwoStateParamName".arg(slotName)
				}

				property var flashStates: ({})

				Timer {
					id: freezeTimer
					repeat: true
					interval: 500
					running: false
					property bool isOn: false

					onTriggered: {
						isOn = !isOn
						for(var x = 0; x < Object.keys(parent.flashStates).length; ++x) {
							var channelNumber = parent.flashStates[Object.keys(parent.flashStates)[x]]
							if(channelNumber !== 0){
								if(isOn) {
									Midi.sendNoteOn(channelNumber, 7, 127)
								} else {
									Midi.sendNoteOff(channelNumber, 7)
								}
							}
						}
					}
				}

				function stopTimer() {
					delete flashStates[slotName]
					if(Object.keys(flashStates).length === 0)
						freezeTimer.stop()
				}

				function send() {
					const dspNote = 2
					const colourNote = 7

					const full = 127
					const dim = 1

					if(propertyData.fxTwoStateParamName.string === "") {
						// No param
						Midi.sendNoteOff(sideChannel, colourNote)
						Midi.sendNoteOff(controlChannel, dspNote)
						stopTimer()
					}
					else if(propertyData.fxTwoState.state){
						// Param present and on
						var effectEnabled = Planck.getProperty("/Client/Mixer/%1/Enable".arg(slotName)).translator.state;
						var effectName =  Planck.getProperty("/Client/Mixer/%1/EffectList".arg(slotName)).translator.string
						if(effectEnabled) {
							Midi.sendNoteOn(sideChannel, colourNote, full)
							Midi.sendNoteOn(controlChannel, dspNote, full)
							if(effectName === "Reverb" || effectName === "Echo" || effectName === "Hall Echo") {
								freezeTimer.start()
								flashStates[slotName] = sideChannel
							}
						}
						else {
							propertyData.fxTwoState.state = false
							if(effectName === "Reverb" || effectName === "Echo" || effectName === "Hall Echo") {
								stopTimer()
							}
						}
					}
					else {
						// Param present and off
						Midi.sendNoteOn(sideChannel, colourNote, dim)
						Midi.sendNoteOff(controlChannel, dspNote)
						stopTimer()
					}
				}
			}
			OutputAssignment {
				properties: { 'fxTwoState' : "/Client/Mixer/%1/Reset".arg(slotName) }
				function send() {
					if(propertyData.fxTwoState.state) {
						Midi.sendNoteOn(sideChannel, 8, 127) //color
					} else {
						Midi.sendNoteOn(sideChannel, 8, 1) //color
					}
				}
			}

			Item {

				Timer {
					id: fxSelectDrawTimer
					repeat: false
					interval: 50
					running: false
					onTriggered: fxSelectDisplayPainter.draw()
				}

				Painter {
					id: fxSelectDisplayPainter
					width: 128
					height: 64
					font.family: "NimbusSanD"
					font.pixelSize: 20
					font.capitalization: Font.AllUppercase
					format: Painter.AK01_DISPLAY

					property QObjProperty pType: Planck.getProperty("/Client/Mixer/%1/EffectList".arg(slotName))
					property string type: pType && pType.translator ? pType.translator.string : ""

					function draw()
					{
						setCompositionMode(Painter.SourceOver);
						clear("black");
						setColor("white");

						drawTextInRect(0,0, 128, 32, Painter.AlignCenter, type);
						device.oleds[displayIndex].update(fxSelectDisplayPainter)
					}

					onTypeChanged: fxSelectDrawTimer.start()
				}
			}
			Item {
				Timer {
					id: drawTimer
					repeat: false
					interval: 50
					running: false
					onTriggered: fxDisplayPainter.draw()
				}

				Painter {
					id: fxDisplayPainter
					width: 128
					height: 64
					font.family: "NimbusSanD"
					font.weight: Font.Bold
					font.pixelSize: 14
					font.capitalization: Font.AllUppercase
					format: Painter.AK01_DISPLAY

					property QObjProperty pType: Planck.getProperty("/Client/Mixer/%1/EffectList".arg(slotName))
					property string type: pType && pType.translator ? pType.translator.string : ""

					property QObjProperty pParamName: Planck.getProperty("/Client/Mixer/%1/ParamName".arg(slotName))
					property string paramName: pParamName && pParamName.translator ? pParamName.translator.string : ""

					property QObjProperty pValue: Planck.getProperty("/Client/Mixer/%1/ParamValue".arg(slotName))
					property real value: pValue && pValue.translator ? pValue.translator.value : 0.25
					property int iValue: Math.round(value * 124)
					property string lastPattern: ""

					readonly property var patterns: [
						"xxx xxx xxx xxx ",
						"x x x x x x x x ",
						"x  xx  xx  xx  x",
						"xxxxx x x xxx x ",
						"xxx xx xxxx x x ",
						"xx xx xxxx xx xx",
						"x x xx xx xxx x ",
						"x xxx  xxx xx x ",
						"x xxxx xxx xx x ",
						"xxxxxxxxxxxxxxxx",
						"xxxxxxxxxxxxxxxx",
						"xxxxxxxxxxxxxxxx",
						"xxxxxxxxxxxxxxxx",
						"xxxxxxxxxxxxxxxx",
						"xxxxxxxxxxxxxxxx",
						"xxxxxxxxxxxxxxxx",
						"xxxxxxxxxxxxxxxx",
					]

					function draw()
					{
						setCompositionMode(Painter.SourceOver);

						clear("black");
						setColor("white");

						if(paramName !== 'Pattern') {
							lastPattern = ""
						}
						if(paramName === 'Pattern') {
							drawTextInRect(0,0, 128, 16, Painter.AlignCenter, paramName);

							var patternNumber = (value * 127) >> 3
							var ptn = patterns[patternNumber]
							if(lastPattern === ptn) {
								return
							}
							lastPattern = ptn

							var x = 3
							for (var i = 0; i < ptn.length; i++) {
								if (ptn[i] == 'x') {
									fillRect(x, 20, 6, 10, "white")
								}
								x = x + 7
								if ((i + 1) % 4 === 0) {
									x = x + 3
								}
							}
						}
						else if(paramName !== '') {
							drawTextInRect(0,0, 128, 16, Painter.AlignCenter, paramName);
							if(type === 'Ping Pong') {
								var newValue = (2 * value) - 1
								drawRect(0, 18, 127, 13)
								fillRect(2, 20, 124, 10, "white")
								fillRect(64, 20, -newValue * 62, 10, "black")
								fillRect(64, 20, newValue * 62, 10, "black")
								fillRect(64, 20, 1, 10, "black")
							}
							else {
								drawRect(0, 18, 127, 13)
								fillRect(2, 20, value * 124, 10, "white")
							}
						}

						device.oleds[displayIndex+1].update(fxDisplayPainter)
					}

					onParamNameChanged: drawTimer.start()
					onIValueChanged: drawTimer.start()
				}
			}
			Item {
				Timer {
					id: fqDrawTimer
					repeat: false
					interval: 50
					running: false
					onTriggered: fqDisplayPainter.draw()
				}

				Timer {
					id: waitTimer
					repeat: false
					interval: 2000
					running: false
					onTriggered: fqDisplayPainter.drawFrequencyTitle()
				}

				Painter {
					id: fqDisplayPainter
					width: 128
					height: 64
					font.family: "NimbusSanD"
					font.weight: Font.Bold
					font.pixelSize: 14
					font.capitalization: Font.MixedCase
					format: Painter.AK01_DISPLAY

					property QObjProperty pValue: Planck.getProperty("/Client/Mixer/%1/Frequency".arg(slotName))
					property real value: pValue && pValue.translator ? pValue.translator.value : 0.25
					property int iValue: Math.round(value * 124)
					property bool drawTitle: false

					property var freqencyArray: [
						60,72,79,86,94,103,113,
						124,136,149,163,178,195,214,234,
						256,281,307,336,368,403,442,484,
						554,607,664,727,796,872,955,1046,
						1145,1254,1373,1503,1646,1802,1973,2161,
						2366,2591,2837,3106,3401,3724,4078,4465,
						4889,5354,5862,6419,7028,7696,8427,9227,
						10103,11063,12114,13880,15198,16641,18222]

					function drawFrequencyTitle()
					{
						drawTitle = true
						draw()
					}

					function draw()
					{
						setCompositionMode(Painter.SourceOver);

						clear("black");
						setColor("white");

						waitTimer.restart()

						if(iValue === 62){
							drawTextInRect(0,0, 128, 16, Painter.AlignCenter, "ALL BANDS")
							fillRect(2, 20, 124, 10, "white")
						}
						else if(value < 0.5) {
							var msg = freqencyArray[iValue] + "Hz"
							if(freqencyArray[iValue] >= 1000) {
								msg = (freqencyArray[iValue]/1000).toFixed(1) + "kHz"
							}
							drawTextInRect(0,0, 128, 16, Painter.AlignCenter, "< " + msg)
							fillRect(2, 20, value * 2 * 124, 10, "white")
						} else {
							var val = iValue-63
							var msg = freqencyArray[val] + "Hz"
							if(freqencyArray[val] >= 1000) {
								msg = (freqencyArray[val]/1000).toFixed(1) + "kHz"
							}
							drawTextInRect(0,0, 128, 16, Painter.AlignCenter, "> " + msg)
							fillRect(2 + (value - 0.5) * 2 * 125, 20, 124, 10, "white")
						}
						drawRect(0, 18, 127, 13)

						if(drawTitle === true){
							setCompositionMode(Painter.SourceOver);
							fillRect(0,0, 128, 16, "black")
							drawTextInRect(0,0, 128, 16, Painter.AlignCenter, "FREQUENCY")
							drawTitle = false
							waitTimer.stop()
						}

						device.oleds[displayIndex+2].update(fqDisplayPainter)
					}

					onIValueChanged: fqDrawTimer.start()
				}
			}

			Connections {
				target: assignment
				onDisplaysActiveChanged: {
					if(assignment.displaysActive) {
						fxSelectDrawTimer.start()
						drawTimer.start()
						fqDrawTimer.start()
					}
				}
			}
		}
	}

	readonly property var activeDecks: Planck.getProperty("/GUI/Decks/ActiveDecks").translator.entries
	property var deckThru: [0, 0, 0, 0]
	property bool xFaderStartLeft: false
	property bool xFaderStartRight: false
	
	ValueNoteAssignment {
		note: 25
		channel: 15
		output: QtObject {
			function setValue(channel, value, assignmentEnabled) {
				xFaderStartLeft = value !== 0
			}
		}
	}
	ValueNoteAssignment {
		note: 27
		channel: 15
		output: QtObject {
			function setValue(channel, value, assignmentEnabled) {
				xFaderStartRight = value !== 0
			}
		}
	}

	property var crossFaderTable: [
		0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,0.00005623,0.00010000,0.00017783,0.00031623,0.00056234,0.00074989,0.00100000,0.00115478,0.00133352,0.00153993,0.00177828,
		0.00205353,0.00237137,0.00273842,0.00316228,0.00354813,0.00398107,0.00446684,0.00501187,0.00546387,0.00595662,0.00649382,0.00707946,0.00771792,0.00841395,0.00917276,0.01000000,
		0.01090184,0.01188502,0.01295687,0.01412538,0.01539927,0.01678804,0.01830206,0.01995262,0.02175204,0.02371374,0.02585235,0.02818383,0.03072557,0.03349654,0.03651741,0.03981072,
		0.04340103,0.04731513,0.05158222,0.05623413,0.05956621,0.06309573,0.06683439,0.07079458,0.07391796,0.07717915,0.08058422,0.08413951,0.08785167,0.09172759,0.09577452,0.10000000,
		0.10441190,0.10901845,0.11382823,0.11885022,0.12409378,0.12956867,0.13528511,0.14125375,0.14748573,0.15399265,0.16078665,0.16788040,0.17528712,0.18302061,0.19109530,0.19952623,
		0.20832913,0.21752040,0.22711719,0.23713737,0.24759963,0.25852348,0.26992928,0.28183829,0.29006812,0.29853826,0.30725574,0.31622777,0.32546178,0.33496544,0.34474661,0.35481339,
		0.35995648,0.36517413,0.37046740,0.37583740,0.38128525,0.38681205,0.39241898,0.39810717,0.40387782,0.40973211,0.41567126,0.42169650,0.42780908,0.43401026,0.44030133,0.44668359,
		0.44990933,0.45315836,0.45643086,0.45972699,0.46304692,0.46639083,0.46975888,0.47315126,0.47656813,0.48000968,0.48347609,0.48696753,0.49048418,0.49402622,0.49759385,0.50118723,
		0.50626161,0.51138737,0.51359998,0.51582217,0.51954719,0.52329911,0.52707813,0.53088444,0.53471824,0.53857972,0.54246909,0.54638655,0.55033230,0.55430654,0.55830948,0.56234133,
		0.56640229,0.57049258,0.57461241,0.57876199,0.58294153,0.58715126,0.59139139,0.59566214,0.59996373,0.60429639,0.60866033,0.61305579,0.61748299,0.62194216,0.62643354,0.63095734,
		0.63551382,0.64010320,0.64472573,0.64938163,0.65219130,0.65501312,0.66164495,0.66834392,0.67511071,0.68194602,0.68489658,0.68785991,0.69282731,0.69783058,0.70286999,0.70794578,
		0.71511354,0.72235386,0.72547926,0.72861817,0.73387991,0.73917965,0.74451765,0.74989421,0.75530959,0.76076408,0.76625796,0.77179152,0.77736503,0.78297879,0.78863310,0.79432823,
		0.79719121,0.80006450,0.80294815,0.80584219,0.80874666,0.81166160,0.81458705,0.81752304,0.82046961,0.82342680,0.82639466,0.82937320,0.83236249,0.83536255,0.83837342,0.84139514,
		0.84442776,0.84747130,0.85052582,0.85359134,0.85666791,0.85975557,0.86285436,0.86596432,0.86908549,0.87221791,0.87536162,0.87851666,0.88168307,0.88486089,0.88805017,0.89125094,
		0.89446325,0.89768713,0.90092264,0.90416981,0.90742868,0.91069929,0.91398170,0.91727594,0.92058204,0.92390007,0.92723005,0.93057204,0.93392607,0.93729219,0.94067045,0.94406088,
		0.94746353,0.95087844,0.95430566,0.95774524,0.96119721,0.96466162,0.96813852,0.97162795,0.97512996,0.97864459,0.98217189,0.98571190,0.98926467,0.99283025,0.99640868,1.00000000
	];

	function calculateExternalMixerVolume(deckIndex)
	{
		var crossFader = Planck.getProperty("/Engine/Mixer/CrossfaderPosition").translator.value;
		var deckVolume = Planck.getProperty("/Engine/Deck%1/DeckFaderVolume".arg(deckIndex)).translator.value;
		var externalVolume

		if(deckThru[deckIndex - 1] === 1) {
			externalVolume = deckVolume
		} else {
			var deckIdx = parseInt(deckIndex, 10)
			if(deckIdx === 1 || deckIdx === 3) {
				if(deckThru[deckIdx - 1] === 2) {
					crossFader = 1 - crossFader
				}
			} else if(deckIdx === 2 || deckIdx === 4) {
				if(deckThru[deckIdx - 1] === 0) {
					crossFader = 1 - crossFader
				}
			}
			var faderIndex = crossFader * 511;

			if (deckIdx === 1 || deckIdx === 3)
			{
				faderIndex = 511 - faderIndex;
			}
			if (faderIndex > 255)
			{
				faderIndex = 255;
			}

			var crossFaderLow = crossFaderTable[Math.floor(faderIndex)]
			var crossFaderHigh = crossFaderTable[Math.ceil(faderIndex)]

			var interpolatedTableValue = crossFaderLow + ((crossFaderHigh - crossFaderLow) * (crossFader - Math.floor(crossFader)));
			externalVolume = deckVolume * interpolatedTableValue;
		}

		Planck.getProperty("/Engine/Deck%1/ExternalMixerVolume".arg(deckIndex)).translator.setValue(externalVolume);

	}

	ValueCCAssignment {
		id: xfaderStartStop
		objectName: "Cross Fader Start/Stop"
		cc: 14
		channel: 15
		enabled: xFaderStartLeft || xFaderStartRight

		property QObjProperty pCrossFaderPosition: Planck.getProperty("/Engine/Mixer/CrossfaderPosition")

		output: QtObject {
			function setValue(channel, value, assignmentEnabled) {
				xfaderStartStop.pCrossFaderPosition.translator.value = value
				if(assignmentEnabled) {
					for (var i = 0; i < deckThru.length; i++) {
						calculateExternalMixerVolume(i+1);
						var deckIndex = "%1".arg(i+1)
						var deckIsActive = activeDecks.indexOf(deckIndex) !== -1
						if(xFaderStartLeft && deckIsActive && deckThru[i] === 0) {
							if (value === 1)
								Planck.getProperty("/Engine/Deck%1/RemoteStop".arg(deckIndex)).translator.state = true
							else
								Planck.getProperty("/Engine/Deck%1/RemoteStart".arg(deckIndex)).translator.state = true
						}
						if (xFaderStartRight && deckIsActive && deckThru[i] === 2) {
							if (value === 0)
								Planck.getProperty("/Engine/Deck%1/RemoteStop".arg(deckIndex)).translator.state = true
							else
								Planck.getProperty("/Engine/Deck%1/RemoteStart".arg(deckIndex)).translator.state = true
						}
					}
				} else {
					for (var index = 1;  index < deckThru.length + 1; index++) {
						calculateExternalMixerVolume(index);
					}
				}
			}
		}
	}


	Repeater {
		model: parseInt(Planck.getProperty("/Configuration/NumberOfDecks").translator.string)
		Item {
			property string deckIndex: "%1".arg(index+1)

			ValueCCAssignment {
				objectName: "Channel Fader %1".arg(deckIndex)
				cc: 14
				channel: index
				output: QtObject {
					function setValue(channel, value, assignmentEnabled) {
						Planck.getProperty("/Engine/Deck%1/DeckFaderVolume".arg(deckIndex)).translator.setValue(value);
						calculateExternalMixerVolume(deckIndex);
					}
				}
			}

			ValueNoteAssignment {
				objectName: "Thru %1".arg(deckIndex)
				note: 15
				channel: index
				normalizeValue: false
				output: QtObject {
					function setValue(channel, value, assignmentEnabled) {
						deckThru[channel] = value
						calculateExternalMixerVolume(deckIndex)
					}
				}
			}
		}
	}
}
