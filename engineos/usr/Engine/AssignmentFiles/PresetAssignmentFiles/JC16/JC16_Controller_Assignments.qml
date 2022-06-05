import airAssignments 1.0
import ControlSurfaceModules 0.1
import QtQuick 2.12

MidiAssignment {
	objectName: 'PRIME 2 Controller Assignment'

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
		holdAction: Action.ToggleControlCenter
		shiftAction: Action.SwitchMainViewLayout
		ledType: LedType.Simple
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
			ListElement {   // SD
				slot: '1'
				note: 52
			}
			ListElement {   // USB
				slot: '5'
				note: 53
			}
		}
	}

	Mixer {
		cueMixCC: 12
		cueGainCC: 13
		crossfaderCC: 14
		crossfaderContourCC: 26
	}

	MicSettings {}

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
				ledType: LedType.Simple
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
				centreLedNote: 43
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

			Thru {
				note: 15
			}

			VUMeter {
				dBThresholds: [-34.0, -31.0, -27.0, -22.0, -21.0, -19.0, -15.0, -9.5, -4.9, 0.0, 15.0]
				ledCCValues: [0, 14, 27, 40, 53, 66, 79, 92, 105, 117, 127]
				vuMeterType: VUMeterType.Channel
				vuLedCCIndexing: VULedCCIndexing.Incremental
				model: ListModel {
					ListElement {
						cc: 10
					}
				}
			}
		}
	}

	Repeater {
		model: ListModel {
			ListElement {
				fxChannelName: 'Channel1'
				fxChannelMidiChannel: 4
			}
			ListElement {
				fxChannelName: 'Channel2'
				fxChannelMidiChannel: 5
			}
		}

		Item {
			objectName: 'DJFx Channel %1'.arg(model.fxChannelName)

			FxAssignmentConfig {
				id: fxConfig
				midiChannel: model.fxChannelMidiChannel
				channelNames: [model.fxChannelName]
			}

			DJFxActivate {
				fxActivateType: FxActivateType.Button
				activateControlsModel: ListModel {
					ListElement {
						note: 6
					}
				}
			}

			DJFxSelect {
				pushNote: 7
				touchNote: 9
				turnCC: 33
			}

			DJFxTime {
				pushNote: 8
				turnCC: 34
			}

			DJFxWetDry {
				cc: 4
			}
		}
	}
}
