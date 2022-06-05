import airAssignments 1.0
import InputAssignment 0.1
import OutputAssignment 0.1
import Device 0.1
import QtQuick 2.0
import Planck 1.0

Device {
	id: device

	controls: []
	useGlobalShift: false
	numberOfLayers: 0
	property string deviceInfo: ""

	Component.onCompleted: {
		console.log("PRIME 4 Mixer Assignement")
		Midi.sendSysEx("F0 7E 00 06 01 F7")

		Midi.sendControlChange(0,0x48,0);
		Midi.sendControlChange(1,0x48,1);
		Midi.sendControlChange(2,0x48,2);
		Midi.sendControlChange(3,0x48,3);
		Midi.sendNoteOn(0,0x15,0);
		Midi.sendNoteOn(0,0x16,0);
		Midi.sendNoteOn(0,0x17,0);
		Midi.sendNoteOn(0,0x18,0);

	}

	Component.onDestruction: {
		if (Planck.quitReason() === QuitReasons.ControllerMode)
		{
			console.log("Setting external usb mode...")
			Midi.sendSysEx("F0 00 02 0B 00 08 63 00 01 01 F7")
		}
	}

	//issuing this cc in Component.onCompleted doesn't have any effect
	//it is stopped when we receive ACK for usb mode
	property Timer mixerModeDelayedSetup: Timer {
		interval: 2500
		repeat: true
		running: true
		onTriggered: {
			console.log("Enabling mixer LED control...")
			Midi.sendSysEx("F0 00 02 0B 00 08 65 00 01 01 F7")

			console.log("Setting normal usb mode...")
			Midi.sendSysEx("F0 00 02 0B 00 08 63 00 01 00 F7")

			console.log("Routing Mic into USB1/2 output...")
			Midi.sendControlChange(0x0F, 0x68, 1)

			console.log("PRIME 4 Query Cue State")
			Midi.sendSysEx("F0 00 02 0B 00 08 4D 00 00 F7")
		}
	}

	function sysExToIntList(sysExString)
	{
		var valueList = sysExString.split(" ");
		var result = [];
		
		for(var i=0;i<valueList.length;i++) {
			result.push(parseInt(valueList[i], 16))
		}
		
		return result;
	}

	function sysEx(sysExString) {
		var valueList = sysExToIntList(sysExString);
		var result = "";

		if(   Planck.quitReason() !== QuitReasons.ControllerMode
		   && valueList[1] === 0x00
		   && valueList[2] === 0x02
		   && valueList[3] === 0x0B
		   && valueList[6] === 0x63) {
			if(valueList[9] === 0x00) {
				console.log("Normal usb mode has been set.")
				mixerModeDelayedSetup.stop()
			}
			else {
				console.log("Re-Setting normal usb mode...")
				Midi.sendSysEx("F0 00 02 0B 00 08 63 00 01 00 F7")
			}
		}

		if(valueList[1] === 0x7E && valueList[2] === 0x00 && valueList[3] === 0x06 && valueList[4] === 0x02)
		{
			for(var i=0;i<4;i++) {
				result += valueList[i + 11];
				if(i == 1)
					result += ".";
			}
			deviceInfo = result;
		}

		const cueStateResponse = [0xF0, 0x00, 0x02, 0x0B, 0x00, 0x08, 0x4D]
		if(valueList[1] === cueStateResponse[1]
		   && valueList[2] === cueStateResponse[2]
		   && valueList[3] === cueStateResponse[3]
		   && valueList[6] === cueStateResponse[6])
		{
			let cueInfo = valueList[9]
			for(let j = 0; j < 4; j++) {
				let state = Boolean(cueInfo & (1 << j))
				Planck.getProperty("/Engine/Deck%1/PFL".arg(j + 1)).translator.state = state
			}
		}
	}
}

