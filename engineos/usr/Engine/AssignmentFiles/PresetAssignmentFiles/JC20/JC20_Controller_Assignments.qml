import airAssignments 1.0
import ControlSurfaceModules 0.1
import QtQuick 2.12

MidiAssignment {
	objectName: 'LC6000 Controller Assignment'

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

	Back {
		note: 16
	}

	Forward {
		note: 17
	}

	BrowseEncoder {
		pushNote: 18
		turnCC: 6
		doubleTapAction: Action.InstantDouble
		holdAction: Action.GridCueEdit
		ledType: LedType.Simple
	}

	DeckAssignmentConfig {
		id: deckConfig
		name: device.deckName
		midiChannel: globalConfig.midiChannel
		controllerMode: ControllerMode.Secondary
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

	Vinyl {
		note: 19
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

	JogWheel {
		touchNote: 40
		ccUpper: 17
		ccLower: 49
		jogSensitivity: 1638.7
		ledType: LedType.RGB
	}

	Parameter {
		leftNote: 68
		rightNote: 69
	}

	SpeedSlider {
		ccUpper: 8
		ccLower: 40
		upLedNote: 41
		centreLedNote: 42
		downLedNote: 43
	}

	NeedleDrop {
		touchNote: 70
		ccUpper: 0x40
		ccLower: 0x41
	}
}
