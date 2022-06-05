import airAssignments 1.0
import Device 0.1
import QtQuick 2.12

Device {
	id: device

	property real gamma: 3.5
	property real padGamma: 3.5

	property string deviceInfo: ""

	readonly property string deckName: {
		// `deviceName` is set in `airAssignments::Midi::Thread::run()`
		if(deviceName.endsWith('3')) {
			'Left'
		}
		else if(deviceName.endsWith('4')) {
			'Right'
		}
		else {
			''
		}
	}
	readonly property QObjProperty pControllerConnected: Planck.getProperty(`/GUI/Decks/Deck${deckName}/ControllerConnected`)

	///////////////////////////////////////////////////////////////////////////
	// Setup

	function sendInitializationMessage() {
		Midi.sendSysEx("F0 00 02 0B 00 10 04 00 00 F7")
	}

	property Timer initTimer: Timer {
		interval: 1000
		repeat: false
		onTriggered: {
			device.isInitializing = false
		}
	}

	property bool isInitializing: false

	Component.onCompleted: {
		engineOSMode(true)
		pControllerConnected.translator.state = true

		currentColors = {}
		currentSimpleColors = {}

		Midi.sendSysEx("F0 7E 00 06 01 F7")

		Midi.sendNoteOn(0, 117, 0)

		isInitializing = true

		requestPowerOnButtonState()

		sendInitializationMessage()

		initTimer.start()
	}

	Component.onDestruction: {
		engineOSMode(false)
		pControllerConnected.translator.state = false
		Midi.sendNoteOn(0, 117, 0) // Turns off all LEDs, after closing application
	}

	controls: []
	useGlobalShift: false
	numberOfLayers: 0

	property var currentColors
	property var currentSimpleColors

	// When JC20 is in "Engine OS Mode", "Deck Select" functionality is
	// disabled. Using "Deck Select" changes the MIDI channels JC20
	// communicates to be able to be used with Serato etc. We want the
	// MIDI channel to be `0` for all communication (as is for the rest
	// of the players) and never change.
	function engineOSMode(enter) {
		const bit = enter ? 1 : 0
		Midi.sendSysEx(`F0 00 02 0B 00 10 50 00 01 0${bit} F7`)
	}

	// Dec to Hex Conversion
	function d2h(d){
		return (+d).toString(16).toUpperCase()
	}

	function midiColorChannel(c, gamma){
		return d2h(Math.min(127, Math.max(0,Math.floor(Math.pow(c, gamma) * 127))))
	}

	function mapColor(color) {
		return Qt.rgba(color.r, color.g, color.b , color.a)
	}

	function midiColor(color, gamma) {
		const c = mapColor(color)
		return midiColorChannel(c.r, gamma)+ " " +  midiColorChannel(c.g, gamma) + " " +  midiColorChannel(c.b, gamma)
	}

	function sendNoteOn(channel, index, value) {
		Midi.sendNoteOn(channel, index, value)
	}

	function sendSimpleColor(channel, index, value) {
		if(!currentSimpleColors[channel]) {
			currentSimpleColors[channel] = {}
		}

		currentSimpleColors[channel][index] = value

		if(value === 0) {
			Midi.sendNoteOff(channel, index)
		} else {
			Midi.sendNoteOn(channel, index, value)
		}
	}

	function sendColor(channel, index, color)
	{
		currentColors[index] = color

		let g = device.gamma
		if(index >= 32 && index <= 39) {
			g = device.padGamma
		}

		const sysEx = "F0 00 02 0B 7F 10 03 00 04 "+d2h(index) + " " + midiColor(color, g)+" F7"
		Midi.sendSysEx(sysEx)

	}

	function requestPowerOnButtonState() {
		Midi.sendSysEx("F0 00 02 0B 01 10 42 00 00 F7")
	}

	function sysExToIntList(sysExString)
	{
		const valueList = sysExString.split(" ")
		let result = []

		for(let i = 0; i < valueList.length; ++i) {
			result.push(parseInt(valueList[i], 16))
		}

		return result
	}

	function sysEx(sysExString) {
		//console.info("Received SysEx:", sysExString)
		const valueList = sysExToIntList(sysExString)
		let result = ""

		// 0xf0 0x00 0x02 0x0b 0x00 0x06 0x42 0x00 0x01 0x01 0xf7
		if(valueList[1] === 0x00 && valueList[2] === 0x02 && valueList[3] === 0x0B && valueList[4] === 0x00 && valueList[6] === 0x42)
		{
			if(valueList[9] === 0x1)
			{
				quitToTestApp()
			}
		}
		else if(valueList[1] === 0x7E && valueList[2] === 0x00 && valueList[3] === 0x06 && valueList[4] === 0x02)
		{
			for(let i = 0; i < 4; ++i) {
				result += parseInt(valueList[i + 11], 16)
				if(i == 1) {
					result += "."
				}
			}
			deviceInfo = result
		}
	}
}

