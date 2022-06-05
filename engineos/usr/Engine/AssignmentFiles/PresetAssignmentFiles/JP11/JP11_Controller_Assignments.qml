import airAssignments 1.0
import ControlSurfaceModules 0.1
import Planck 1.0
import QtQuick 2.12

MidiAssignment {
	objectName: 'PRIME GO Controller Assignment'

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

	Shift {
		note: 8
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
	}

	Mixer {
		cueMixCC: 12
		cueGainCC: 13
		crossfaderCC: 14
	}

	MicSettings {}

	Mics {
		mic1Note: 36
		auxMic2Note: 37
		mic1ShiftAction: Action.ToggleMicTalkover
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

			Bank {}

			Load {
				note: model.loadNote
				ledType: LedType.Simple
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
				}
			}

			ActionPads {
				firstPadNote: 15
				ledType: LedType.RGB
			}

			Sync {
				syncNote: 8
				syncHoldAction: Action.KeySync
			}

			PlayCue {
				cueNote: 9
				cueShiftAction: Action.SetCuePoint
				playNote: 10
			}

			PitchBend {
				minusNote: 29
				plusNote: 30
			}

			JogWheel {
				touchNote: 33
				ccUpper: 0x37
				ccLower: 0x4D
				jogSensitivity: 1638.7 * 10.08
				hasTrackSearch: true
			}

			Vinyl {
				note: 35
				holdAction: Action.GridCueEdit
			}

			AutoLoop {
				pushNote: 39
				turnCC: 32
				loopInactiveShiftTurnAction: Action.BeatJump
				ledType: LedType.Simple
			}

			SpeedSlider {
				ccUpper: 0x1F
				ccLower: 0x4B
				invert: true
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

			SweepFxSelect {
				channelNames: [model.mixerChannelName]
				buttonsModel: ListModel {
					Component.onCompleted: {
						const types = [
							{'note': 14, 'fxIndex': SweepEffect.DualFilter},
							{'note': 15, 'fxIndex': SweepEffect.Wash},
						]
						for(const type of types) {
							append({'note': type.note, 'fxIndex': type.fxIndex})
						}
					}
				}
			}
		}
	}

	FxAssignmentConfig {
		id: fxConfig
		midiChannel: 4
		channelNames: ['Channel1', 'Channel2']
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

	DJFxActivate {
		fxActivateType: FxActivateType.Button
		activateControlsModel: ListModel {
			ListElement {
				midiChannel: 4
				note: 6
			}
		}
	}

	DJFxAssign {
		notes: [11, 12]
	}
}
