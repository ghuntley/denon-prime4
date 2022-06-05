import airAssignments 1.0
import ControlSurfaceModules 0.1
import QtQuick 2.12
import Planck 1.0

MidiAssignment {
	objectName: 'SCX-4 Controller Assignment'

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
	}

	Forward {
		note: 4
		shiftAction: Action.Quantize
	}

	BrowseEncoder {
		pushNote: 6
		turnCC: 5
		ledType: LedType.Simple
	}

	View {
		note: 14
		holdAction: Action.ToggleControlCenter
		doubleAction: Action.None
		shiftAction: Action.SwitchMainViewLayout
		ledType: LedType.Simple
	}

	Media {
		mediaButtonsModel: ListModel {
			ListElement {
				name: 'Source'
				shiftName: ''
				note: 13
				hasLed: true
			}
		}
	}

	Lighting {
		note: 39
	}

	Mixer {
		cueSplitNote: 11
		speakerNote: 41
		crossfaderCC: 14
		speakerCC: 15
		boothCC: 15
		cueMixCC: 18
		cueGainCC: 19
		masterCC: 20
		crossfaderContourCC: 26
	}

	Mics {
		mic1Note: 36
		auxMic2Note: 37
		mic1ClippingNote: 43
		auxMic2ClippingNote: 42
		softwareMic1Routing: true
	}

	MicLevels {
		mic1CC: 16
		auxMic2CC: 17
	}

	MicAuxToggle { }

	VUMeter {
		dBThresholds: [-50.16, -30.16, -16.66, -11.66, -8.66, -1.16, 20.0]
		ledCCValues: [0, 1, 3, 7, 15, 31, 63]
		vuMeterType: VUMeterType.Master
		vuLedCCIndexing: VULedCCIndexing.Bitwise
		model: ListModel {
			ListElement {
				cc: 32
			}
			ListElement {
				cc: 33
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
				ledType: LedType.Simple
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

			Shift {
				note: 28
				ledType: LedType.Simple
			}

			PitchBend {
				minusNote: 29
				plusNote: 30
			}

			Layer {
				note: 31
				midiChannel: deckConfig.midiChannel
			}

			JogWheel {
				touchNote: 33
				ccUpper: 0x11
				ccLower: 0x31
				jogSensitivity: 1638.7 * 3.6
			}

			KeyLock {
				note: 34
			}

			Vinyl {
				note: 35
			}

			Slip {
				note: 36
				holdAction: Action.GridCueEdit
			}

			ManualLoop {
				inNote: 37
				outNote: 38
			}

			AutoLoop {
				pushNote: 39
				turnCC: 32
			}

			StopTime {
				cc: 37
			}

			SpeedSlider {
				ccUpper: 0x1F
				ccLower: 0x4B
				centreLedNote: 42
				invert: true
			}
			LcdWheelDisplay {
				primaryDeckIndex: model.index + 1
			}
		}
	}

	SweepFxSelect {
		midiChannel: globalConfig.midiChannel
		channelNames: ['1', '2', '3', '4']
		flashOnActive: true
		buttonsModel: ListModel {
			Component.onCompleted: {
				const types = [
					{'note': 21, 'fxIndex': SweepEffect.DualFilter},
					{'note': 22, 'fxIndex': SweepEffect.DubEcho},
					{'note': 23, 'fxIndex': SweepEffect.NoiseSweep},
					{'note': 24, 'fxIndex': SweepEffect.Wash},
				]
				for(const type of types) {
					append({'note': type.note, 'fxIndex': type.fxIndex})
				}
			}
		}
	}

	Repeater {
		model: ListModel {
			ListElement {
				mixerChannelName: '1'
				mixerChannelMidiChannel: 0
			}
			ListElement {
				mixerChannelName: '2'
				mixerChannelMidiChannel: 1
			}
			ListElement {
				mixerChannelName: '3'
				mixerChannelMidiChannel: 2
			}
			ListElement {
				mixerChannelName: '4'
				mixerChannelMidiChannel: 3
			}
		}

		Item {
			objectName: 'Mixer Channel %1'.arg(model.mixerChannelName)

			MixerChannelAssignmentConfig {
				id: mixerChannelConfig
				name: model.mixerChannelName
				midiChannel: model.mixerChannelMidiChannel
			}

			MixerChannelCore {
				pflNote: 13
				trimCC: 3
				trebleCC: 4
				midCC: 6
				bassCC: 8
				faderCC: 14
			}

			SweepFxKnob {
				cc: 11
			}

			Thru {
				note: 15
			}

			VUMeter {
				dBThresholds: [-51.35, -31.35, -17.85, -12.85, -9.85, -2.35, 20.0]
				ledCCValues: [0, 1, 3, 7, 15, 31, 63]
				vuMeterType: VUMeterType.Channel
				vuLedCCIndexing: VULedCCIndexing.Bitwise
				model: ListModel {
					ListElement {
						cc: 10
					}
				}
			}
		}
	}

	FxAssignmentConfig {
		id: fxConfig
		midiChannel: globalConfig.midiChannel
		channelNames: ['Channel3', 'Channel1', 'Channel2', 'Channel4', 'Main']
	}

	DJFxSelect {
		pushNote: 30
		turnCC: 35
	}

	DJFxTime {
		pushNote: 25
		turnCC: 36
	}

	DJFxWetDry {
		cc: 4
	}

	DJFxActivate {
		fxActivateType: FxActivateType.Button
		activateControlsModel: ListModel {
			ListElement {
				midiChannel: 15
				note: 26
			}
		}
		flashOnActive: true
	}

	DJFxAssign {
		turnCC: 40
		velocities: [0, 1, 2, 3, 127]
	}
}
