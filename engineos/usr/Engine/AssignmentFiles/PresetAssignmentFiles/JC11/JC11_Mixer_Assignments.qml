import airAssignments 1.0
import InputAssignment 0.1
import QtQuick 2.12

MidiAssignment {
	id: assignment

	OutputAssignment {
		properties: { 'curve': '/Client/Preferences/FaderCurve' }
		function send() {
			Midi.sendControlChange(0x0F, 0x1B, propertyData.curve.unnormalized)
		}
	}

	OutputAssignment {
		properties: { 'micTalkoverLevel' : '/Client/Preferences/MicTalkoverLevel' }
		function send() {
			Midi.sendControlChange(0x0F, 0x58, propertyData.micTalkoverLevel.unnormalized + 40)
		}
	}

	OutputAssignment {
		properties: { 'micTalkoverResume' : '/Client/Preferences/MicTalkoverResume' }
		function send() {
			Midi.sendControlChange(0x0F, 0x59, propertyData.micTalkoverResume.state ? 1 : 0)
		}
	}

	OutputAssignment {
		properties: { 'micAttenuation' : '/Client/Preferences/Mic1Attenuation' }
		function send() {
			Midi.sendControlChange(0x0F, 0x5E, propertyData.micAttenuation.unnormalized + 15)
		}
	}

	OutputAssignment {
		properties: { 'micAttenuation' : '/Client/Preferences/Mic2Attenuation' }
		function send() {
			Midi.sendControlChange(0x0F, 0x63, propertyData.micAttenuation.unnormalized + 15)
		}
	}

	OutputAssignment {
		properties: { 'micThreshold' : '/Client/Preferences/Mic1Threshold' }
		function send() {
			Midi.sendControlChange(0x0F, 0x71, propertyData.micThreshold.unnormalized + 80)
		}
	}

	OutputAssignment {
		properties: { 'micThreshold' : '/Client/Preferences/Mic2Threshold' }
		function send() {
			Midi.sendControlChange(0x0F, 0x72, propertyData.micThreshold.unnormalized + 80)
		}
	}

	OutputAssignment {
		properties: { 'sendMicBooth' : '/Client/Preferences/SendMicBooth' }
		function send() {
			Midi.sendControlChange(0x0F, 0x42, propertyData.sendMicBooth.state ? 1 : 0)
		}
	}

	OutputAssignment {
		properties: { 'zoneOutActivated' : '/Engine/Mixer/Zone/Active' }
		function send() {
			Midi.sendControlChange(0x0F, 0x65, propertyData.zoneOutActivated.state ? 4 : 0)
		}
	}

	OutputAssignment {
		properties: { 'masterLimiter': '/Client/Preferences/MasterLimiter' }
		property int previousValue: -1
		function send() {
			var midiValue = 21 - propertyData.masterLimiter.unnormalized

			if(midiValue === 8) {
			// TODO: Remove this when DSP is fixed and works with full range of values.
				midiValue = 0
			}

			if(midiValue !== previousValue) {
				previousValue = midiValue
				Midi.sendControlChange(0x0F, 0x69, midiValue)
			}
		}
	}

	OutputAssignment {
		properties: { 'eqType' : '/Client/Preferences/EQType' }
		function send() {
			Midi.sendControlChange(0x0F, 0x3F, propertyData.eqType.state ? 1 : 0)
		}
	}

	OutputAssignment {
		properties: { 'eqHighXO' : '/Client/Preferences/EQHighXO' }
		function send() {
			Midi.sendControlChange(0x0F, 0x43, propertyData.eqHighXO.unnormalized)
		}
	}

	OutputAssignment {
		properties: { 'eqLowXO' : '/Client/Preferences/EQLowXO' }
		function send() {
			Midi.sendControlChange(0x0F, 0x44, propertyData.eqLowXO.unnormalized)
		}
	}

	OutputAssignment {
		properties: { 'dualFilterRes' : '/Client/Preferences/DualFilterRes' }
		function send() {
			Midi.sendControlChange(0x0F, 0x56, propertyData.dualFilterRes.unnormalized << 3)
		}
	}

	OutputAssignment {
		properties: { 'extremeType' : '/Client/Preferences/FilterExtremeType' }
		function send() {
			Midi.sendControlChange(0x0F, 0x64, propertyData.extremeType.state ? 1 : 0)
		}
	}

	OutputAssignment {
		properties: { 'cueSolo' : '/Client/Preferences/CueSolo' }
		function send() {
			Midi.sendControlChange(0x0F, 0x45, propertyData.cueSolo.state ? 1 : 0)
			Midi.sendSysEx("F0 00 02 0B 00 08 4D 00 00 F7")
		}
	}

	OutputAssignment {
		properties: { 'recordingGain' : '/Client/Preferences/RecordingGain' }
		function send() {
			Midi.sendControlChange(0x0F, 0x49, propertyData.recordingGain.unnormalized + 20)
		}
	}
	
	OutputAssignment {
		properties: { 'headphoneGain' : '/Client/Preferences/HeadphoneGain' }
		function send() {
			Midi.sendControlChange(0x0F, 0x5F, propertyData.headphoneGain.unnormalized + 10)
		}
	}
	
	OutputAssignment {
		properties: { 'noiseSweepLevel' : '/Client/Preferences/NoiseSweepLevel' }
		function send() {
			Midi.sendControlChange(0x0F, 0x67, propertyData.noiseSweepLevel.unnormalized + 20)
		}
	}

	OutputAssignment {
		properties: { 'invertSplit' : '/Client/Preferences/InvertSplit' }
		function send() {
			Midi.sendControlChange(0x0F, 0x6A, propertyData.invertSplit.state ? 1 : 0)
		}
	}

	OutputAssignment {
		properties: { 'sendMicToHeadphones' : '/Client/Preferences/SendMicToHeadphones' }
		function send() {
			Midi.sendControlChange(0x0F, 0x73, propertyData.sendMicToHeadphones.state ? 1 : 0)
		}
	}

	Repeater {
		id: pflRepeater
		model: 4

		ValueNoteAssignment {
			objectName: "Cue %1".arg(index + 1)
			note: 13
			channel: index
			output: QtObject {
				function setValue(channel, value, assignmentEnabled) {
					Planck.getProperty("/Engine/Deck%1/PFL".arg(index + 1)).translator.state = Boolean(value)
				}
			}
		}
	}

	Component.onCompleted: {
		// SendMainMixToZoneOut is always on
		Midi.sendSysEx('F0 00 02 0B 00 08 64 00 01 01 F7')
	}
}
