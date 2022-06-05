import airAssignments 1.0
import ControlSurfaceModules 0.1
import QtQuick 2.12

MidiAssignment {
	objectName: 'SC5000M Controller Assignment'

	Utility {
		id: util
	}

	GlobalAssignmentConfig {
		id: globalConfig
		midiChannel: 0
	}

	GlobalAction {
		id: globalAction
	}

	Layer {
		note: 11
		midiChannel: globalConfig.midiChannel
		ledType: LedType.RGB
	}

	Shortcuts {
		note: 12
	}

	View {
		note: 14
		holdAction: Action.ToggleUserProfile
		shiftAction: Action.SwitchMainViewLayout
		shiftHoldAction: Action.SwapDeckInfos
		ledType: LedType.Simple
	}

	Back {
		note: 16
		ledType: LedType.Simple
	}

	Forward {
		note: 17
		ledType: LedType.Simple
	}

	BrowseEncoder {
		pushNote: 18
		turnCC: 6
		doubleTapAction: Action.InstantDouble
		holdAction: Action.GridCueEdit
		ledType: LedType.Simple
	}

	Media {
		mediaButtonsModel: ListModel {
			ListElement {
				name: 'Source'
				shiftName: 'Quick Browser Source'
				note: 13
				hasLed: true
			}
			ListElement {
				name: 'Eject'
				shiftName: ''
				note: 15
				hasLed: false
			}
		}
		networkLedNote: 47
		removableDeviceModel: ListModel {
			ListElement {
				type: 'USB'
				note: 45
			}
			ListElement {
				type: 'SD'
				note: 46
			}
		}
	}

	DeckAssignmentConfig {
		id: deckConfig
		midiChannel: globalConfig.midiChannel
	}

	DeckAction {
		id: deckAction
	}

	PlayCue {
		playNote: 1
		cueNote: 2
		cueShiftAction: Action.SetCuePoint
	}

	BeatJump {
		prevNote: 3
		nextNote: 4
	}

	TrackSkip {
		prevNote: 5
		nextNote: 6
	}

	Censor {
		note: 7
	}

	ManualLoop {
		inNote: 8
		outNote: 9
	}

	AutoLoop {
		pushNote: 10
		turnCC: 3
		ledType: LedType.Simple
	}

	Motorized {
		motorNote: 19
		platterLedNote: 40
		platterCC: 54
	}

	Sync {
		syncNote: 20
		syncHoldAction: Action.InstantDouble
		masterNote: 21
	}

	KeyLock {
		note: 22
	}

	Slip {
		note: 23
	}

	PitchBend {
		minusNote: 24
		plusNote: 25
	}

	Shift {
		note: 26
		ledType: LedType.Simple
	}

	PerformanceModes {
		ledType: LedType.RGB
		modesModel: ListModel {
			ListElement {
				note: 27
				view: 'CUES'
			}
			ListElement {
				note: 30
				view: 'LOOPS'
				altView: 'AUTO'
			}
			ListElement {
				note: 28
				view: 'ROLL'
			}
			ListElement {
				note: 29
				view: 'SLICER'
				altView: 'FIXED'
			}
		}
	}

	ActionPads {
		firstPadNote: 32
		ledType: LedType.RGB
	}

	StopTime {
		cc: 7
	}

	RemotePlaybackControl {
		startNote: 50
		stopNote: 51
	}

	Parameter {
		leftNote: 52
		rightNote: 53
	}

	SpeedSlider {
		ccUpper: 8
		ccLower: 40
		upLedNote: 43
		centreLedNote: 42
		downLedNote: 41
	}

	Component.onCompleted: {
		// Set front light pipe to dim
		Midi.sendNoteOn(globalConfig.midiChannel, 48, 1)
	}
}
