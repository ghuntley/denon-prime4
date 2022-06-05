import airAssignments 1.0
import Device 0.1
import QtQuick 2.12

Device {
	id: device

	controls: []
	useGlobalShift: false
	numberOfLayers: 0

	property string deviceInfo: ""
	property string currentMixerFirmwareVersion

	///////////////////////////////////////////////////////////////////////////
	// Setup

	function queryAbsoluteControls() {
		Midi.sendSysEx("F0 00 02 0B 7F 11 04 00 00 F7")
	}

	function sendInitializationMessage() {
		Midi.sendSysEx("F0 00 02 0B 7F 11 60 00 04 04 01 02 00 F7")
	}

	property Timer initPhaseEndTimer: Timer {
		interval: 1000
		repeat: false
		onTriggered: {
			device.isInitializing = false

			// Channel Meter reset
			Midi.sendControlChange(0, 10, 0)
			Midi.sendControlChange(1, 10, 0)

			// Master Meter reset
			Midi.sendControlChange(15, 32, 0)
			Midi.sendControlChange(15, 33, 0)

			queryAbsoluteControls()
		}
	}

	property bool isInitializing: false

	Component.onCompleted: {
		currentSimpleColors = {}

		Midi.sendSysEx("F0 7E 00 06 01 F7")

		isInitializing = true

		requestPowerOnButtonState()

		sendInitializationMessage();

		initPhaseEndTimer.start()
	}

	Component.onDestruction: {
		Midi.sendNoteOff(0, 118)
	}

	property var currentSimpleColors

	// Dec to Hex Conversion
	function d2h(d){
		return (+d).toString(16).toUpperCase()
	}

	function sendNoteOn(channel, index, value) {
		Midi.sendNoteOn(channel, index, value)
	}

	function sendSimpleColor(channel, index, value) {
		currentSimpleColors[index] = value

		if (value === 0) {
			Midi.sendNoteOff(channel, index)
		}
		else {
			Midi.sendNoteOn(channel, index, value)
		}
	}

	function requestPowerOnButtonState() {
		Midi.sendSysEx("F0 00 02 0B 7F 11 42 00 00 F7")
	}

	function sysExToIntList(sysExString)
	{
		var valueList = sysExString.split(" ")
		var result = []

		for(var i = 0; i < valueList.length; ++i) {
			result.push(parseInt(valueList[i], 16))
		}
		return result
	}

	function sysEx(sysExString) {
		var valueList = sysExToIntList(sysExString)
		var result = ""

		// 0xf0 0x00 0x01 0x3f 0x00 0x3f 0x42 0x00 0x01 0x01 0xf7
		if(valueList[1] === 0x00 && valueList[2] === 0x02 && valueList[3] === 0x0B && valueList[6] === 0x42)
		{
			if(valueList[9] === 0x0) {
				console.log("No special power on request")
			}
			else if(valueList[9] === 0x1) {
				console.log("Request test-mode entry")
				quitToTestApp()
			}
		}
		else if(valueList[1] === 0x7E && valueList[2] === 0x00 && valueList[3] === 0x06 && valueList[4] === 0x02)
		{
			let i
			let length = 4
			for(i = 0; i < length; ++i) {
				result += valueList[i + 11]
				if(i < (length - 1)) {
					result += "."
				}
			}
			deviceInfo = result
		}
	}
}
