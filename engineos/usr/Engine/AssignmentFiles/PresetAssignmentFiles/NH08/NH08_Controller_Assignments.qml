import airAssignments 1.0
import ControlSurfaceModules 0.1
import QtQuick 2.12
import Planck 1.0

MidiAssignment {
	objectName: 'MIXSTREAM PRO Controller Assignment'

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

	BrowseEncoder {
		pushNote: 6
		turnCC: 5
	}

	Menu {
		note: 7
	}

	View {
		note: 16
		shiftAction: Action.SwitchMainViewLayout
		doubleAction: Action.None
	}

	Media {
		mediaButtonsModel: ListModel {
			ListElement {
				name: 'SoundSwitch'
				shiftName: 'SoundSwitch'
				note: 34
				hasLed: false
			}
		}
		mediaButtonsShiftEnabled: globalConfig.soundSwitchViewEnabled
	}

	Mixer {
		cueMixCC: 9
		cueGainCC: 10
		crossfaderCC: 14
		masterCC: 15
		speakerCC: 17
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

			Sync {
				syncNote: 8
			}

			PlayCue {
				cueNote: 9
				playNote: 10
				cueShiftAction: Action.Backtrack
			}

			PerformanceModes {
				ledType: LedType.Simple
				modesModel: ListModel {
					ListElement {
						note: 11
						view: 'CUES'
						hasBank: true
					}
					ListElement {
						note: 12
						view: 'LOOPS'
						hasBank: true
					}
					ListElement {
						view: 'AUTO'
						note: 14
						hasBank: true
					}
					ListElement {
						note: 13
						view: 'ROLL'
						hasBank: true
					}
				}
			}

			ActionPads {
				firstPadNote: 15
				ledType: LedType.Simple
			}

			Shift {
				note: 28
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
				hasTrackSearch: true
			}

			Wheel {
				note: 35
				shiftAction: Action.Scratch
				holdAction: Action.GridEdit
			}

			SpeedSlider {
				ccUpper: 0x1F
				ccLower: 0x4B
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
		}
	}

	FxAssignmentConfig {
		id: fxConfig
		midiChannel: 4
		channelNames: ['Channel1', 'Channel2']
	}

	DJFxSelect {
		buttonsModel: ListModel {
			Component.onCompleted: {
				const types = [
					{'note': 0, 'fxIndex': DJFxType.Echo},
					{'note': 1, 'fxIndex': DJFxType.Flanger},
					{'note': 2, 'fxIndex': DJFxType.Delay},
					{'note': 3, 'fxIndex': DJFxType.Phaser},
				]
				for(const type of types) {
					append({'note': type.note, 'fxIndex': type.fxIndex})
				}
			}
		}
	}

	DJFxActivate {
		fxActivateType: FxActivateType.Paddle
		activateControlsModel: ListModel {
			ListElement {
				midiChannel: 4
				note: 4
			}
			ListElement {
				midiChannel: 5
				note: 4
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
