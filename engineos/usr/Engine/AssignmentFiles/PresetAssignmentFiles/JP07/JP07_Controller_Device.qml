import airAssignments 1.0
import InputAssignment 0.1
import OutputAssignment 0.1
import Device 0.1
import QtQuick 2.0

Device {
	id: device

	property real gamma: 3.5
	property real padGamma: 3.5
	
	property string deviceInfo: ""

	///////////////////////////////////////////////////////////////////////////
	// Setup

	function sendInitializationMessage() {
		Midi.sendSysEx("F0 00 02 0B 00 06 04 00 00 F7")
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
		currentColors = {}
		currentSimpleColors = {}
		
		Midi.sendSysEx("F0 7E 00 06 01 F7")
		
		Midi.sendNoteOn(0, 117, 0)

		isInitializing = true
		
		requestPowerOnButtonState();
		
		sendInitializationMessage();

		initTimer.start()
	}
	
	Component.onDestruction: {
		Midi.sendNoteOn(0, 117, 0) // Turns off all LEDs, after closing application
	}
	
	controls: []
	useGlobalShift: false
	numberOfLayers: 0
	
	property var currentColors
	property var currentSimpleColors
	
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
		var c = mapColor(color)
		return midiColorChannel(c.r, gamma)+ " " +  midiColorChannel(c.g, gamma) + " " +  midiColorChannel(c.b, gamma)
	}
	
	function sendNoteOn(channel, index, value) {
		Midi.sendNoteOn(channel, index, value);
	}

	function sendSimpleColor(channel, index, value) {
		if(!currentSimpleColors[channel]) {
			currentSimpleColors[channel] = {};
		}

		currentSimpleColors[channel][index] = value

		if(value === 0) {
			Midi.sendNoteOff(channel, index)
		} else {
			Midi.sendNoteOn(channel, index, value)
		}
	}
	
	//Color Send Function
	function sendColor(channel, index, color)
	{
		currentColors[index] = color;
		
		var g = device.gamma
		if(index >= 32 && index <= 39) {
			g = device.padGamma
		}
		
		var sysEx = "F0 00 02 0B 7F 06 03 00 04 "+d2h(index) + " " + midiColor(color, g)+" F7"
		Midi.sendSysEx(sysEx)
		
	}

	function requestPowerOnButtonState() {
		Midi.sendSysEx("F0 00 02 0B 01 06 42 00 00 F7");
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
		console.info("Received SysEx:", sysExString)
		var valueList = sysExToIntList(sysExString);
		var result = "";
		
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
			for(var i=0;i<4;i++) {
				result += parseInt(valueList[i + 11], 16);
				if(i == 1)
					result += ".";
			}
			deviceInfo = result;
		}
	}
}
