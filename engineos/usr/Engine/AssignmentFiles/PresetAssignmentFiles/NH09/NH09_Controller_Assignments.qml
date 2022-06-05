import airAssignments 1.0
import ControlSurfaceModules 0.1
import QtQuick 2.12
import Planck 1.0

MidiAssignment {
	objectName: 'MIXSTREAM Controller Assignment'

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

	View {
		note: 7
		shiftAction: Action.SwitchMainViewLayout
		holdAction: Action.ToggleControlCenter
	}

	Shift {
		note: 28
	}

	Mixer {
		cueMixCC: 9
		cueGainCC: 10
		crossfaderCC: 14
		masterCC: 15
	}

	Repeater {
		model: ListModel {
			ListElement {
				deckName: 'Left'
				deckMidiChannel: 2
			}
			ListElement {
				deckName: 'Right'
				deckMidiChannel: 3
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

			Sync {
				syncNote: 8
				syncHoldAction: Action.InstantDouble
			}

			PlayCue {
				cueNote: 9
				playNote: 10
				cueShiftAction: Action.Backtrack
			}

			PerformanceModes {
				ledType: LedType.Simple
				modeNote: 19
				modeShiftAction: Action.GridEdit
				modesModel: ListModel {
					ListElement {
						note: 11
						view: 'CUES'
					}
					ListElement {
						note: 12
						view: 'AUTO'
					}
					ListElement {
						note: 13
						view: 'SIMPLE_ROLL'
					}
				}
			}

			ActionPads {
				firstPadNote: 15
				ledType: LedType.Simple
			}

			JogWheel {
				touchNote: 33
				ccUpper: 0x37
				ccLower: 0x4D
				jogSensitivity: 1638.7 * 3.6
				hasTrackSearch: true
			}

			SpeedSlider {
				ccUpper: 0x1F
				ccLower: 0x4B
			}
		}
	}

	SweepFxSelect {
		midiChannel: 4
		channelNames: ['1', '2']
		alwaysOn: true
		buttonsModel: ListModel {
			ListElement {
				note: 0
				fxIndex: SweepEffect.DualFilter
			}
			ListElement {
				note: 1
				fxIndex: SweepEffect.DubEcho
			}
			ListElement {
				note: 2
				fxIndex: SweepEffect.FilterRoll
			}
			ListElement {
				note: 3
				fxIndex: SweepEffect.Wash
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
				bassCC: 8
				faderCC: 14
			}

			SweepFxKnob {
				cc: 11
			}
		}
	}

	VUMeter {
		dBThresholds: [-35.0, -25.0, -21.0, -15.0, -3.0, 30.0]
		ledCCValues: [0, 14, 27, 40, 53, 66]
		vuMeterType: VUMeterType.Combo
		vuLedCCIndexing: VULedCCIndexing.Incremental
		model: ListModel {
			ListElement {
				channelName: '1'
				cc: 32
			}
			ListElement {
				channelName: '2'
				cc: 33
			}
		}
	}
}
