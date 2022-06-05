import airAssignments 1.0
import ControlSurfaceModules 0.1
import QtQuick 2.12
import Planck 1.0

MidiAssignment {
	objectName: 'SCX-2 Controller Assignment'

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
		// micCC: 16
		cueMixCC: 18
		cueGainCC: 19
		masterCC: 20
		crossfaderContourCC: 26
	}

	Mics {
		mic1Note: 36
		mic1ClippingNote: 43
		softwareMic1Routing: true
	}

	MicLevels {
		mic1CC: 16
	}

	VUMeter {
		dBThresholds: [-41.43, -21.43, -7.93, -2.93, 0.07, 7.57, 20.0]
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
				deckMidiChannel: 2
				loadNote: 1
			}

			ListElement {
				deckName: 'Right'
				deckMidiChannel: 3
				loadNote: 2
			}
		}

		Item {
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
				}
			}

			Bank {
				note: 14
			}

			ActionPads {
				firstPadNote: 15
				ledType: LedType.Simple
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
		}
	}

	SweepFxSelect {
		midiChannel: globalConfig.midiChannel
		channelNames: ['1', '2']
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

			VUMeter {
				dBThresholds: [-45.65, -25.65, -12.15, -7.15, -4.15, 3.35, 20.0]
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
		channelNames: ['Channel1', 'Channel2', 'Main']
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
		velocities: [0, 1, 127]
	}
}
