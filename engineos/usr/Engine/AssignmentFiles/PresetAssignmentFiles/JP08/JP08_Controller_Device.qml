import airAssignments 1.0
import Device 0.1
import QtQuick 2.12

Device {
	id: device

	property real gamma: 3.5
	property real padGamma: 3.5
	
	property string deviceInfo: ""

	///////////////////////////////////////////////////////////////////////////
	// Setup

	function sendInitializationMessage() {
		Midi.sendSysEx("F0 00 02 0B 7f 0A 04 00 00 F7")
	}
	
	property Timer initTimer: Timer {
		interval: 1000
		repeat: false
		onTriggered: { 
			Midi.sendControlChange(2 , 69, 0); // Set to 33,3 rpm normal speed
			Midi.sendControlChange(2 , 71, 0); // Fastest start time
			device.isInitializing = false
		}
	}

	property bool isInitializing: false
	
	Component.onCompleted: {
		stopMotor();
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
		stopMotor();
		Midi.sendNoteOn(0, 117, 0) // Turns off all LEDs, after closing application
	}
	
	controls: []
	useGlobalShift: false
	numberOfLayers: 0
	
	property var currentColors
	property var currentSimpleColors

	function stopMotor()
	{
		Midi.sendControlChange(1, 66, 0); // Turn off
	}

	property var motors: [
		{ direction: 0, speed: 1.0},
		{ direction: 0, speed: 1.0},
		{ direction: 0, speed: 1.0},
		{ direction: 0, speed: 1.0}
	]

	property int _activeDeckIndex: 0
	property int motorDirection : 0;
	property real _speed : 0;

	function recoverMotorSettings() {
		Midi.sendControlChange(2 , 69, 0); // Set to 33,3 rpm normal speed
		Midi.sendControlChange(2 , 71, 0); // Fastest start time
		_speed = 1.0;
		motorDirection = 0;
		p_setMotorSpeed(_activeDeckIndex);
		p_setMotorDirection(_activeDeckIndex, true);
	}

	function setMotorDirection( deckIndex, direction, fast) {
		motors[deckIndex].direction = direction;
		p_setMotorDirection(deckIndex, fast);
	}

	function setMotorSpeed( deckIndex, speed ) {
		motors[deckIndex].speed = speed;
		p_setMotorSpeed(deckIndex)
	}

	function activeDeckChanged(deckIndex) {
		if(	_activeDeckIndex !== deckIndex) {
			var oldDeckIndex = _activeDeckIndex;
			_activeDeckIndex = deckIndex;
			if(motors[oldDeckIndex].direction === motors[deckIndex].direction) {
				p_setMotorSpeed(deckIndex);
			}
			else {
				if(motors[deckIndex].direction === 0) {
					p_setMotorSpeed(deckIndex);
					p_setMotorDirection(deckIndex,true);
				}
				else if(_speed >= motors[deckIndex].speed) {
					p_setMotorSpeed(deckIndex);
					p_setMotorDirection(deckIndex, true);
				}
				else {
					p_setMotorDirection(deckIndex, true);
					p_setMotorSpeed(deckIndex);
				}
			}
		}
	}

	function setStopTime(stopTime) {
		Midi.sendControlChange(1, 72, stopTime);
	}

	function motorStopped(direction) {
		return (direction === 0);
	}

	function p_setMotorDirection(deckIndex, fast)
	{
		var direction = motors[deckIndex].direction;
		if(deckIndex !== _activeDeckIndex) {
			return;
		}
		if(motors[deckIndex].direction !== motorDirection || fast) {
			if(motorStopped(motors[deckIndex].direction)) {
				Midi.sendControlChange(deckIndex +1, fast? 66 : 68, 0); // Turn off
			}
			else if(motors[deckIndex].direction === 1) {
				Midi.sendControlChange(deckIndex +1, 70, 0); // Not reversed
			}
			else if(motors[deckIndex].direction === -1) {
				Midi.sendControlChange(deckIndex +1, 70, 1); // Reverse
			}
			if(motorStopped(motorDirection) && !motorStopped(motors[deckIndex].direction)) {
				Midi.sendControlChange(deckIndex +1, fast? 65 : 67, 0); // Turn on
			}
		}
		motorDirection = direction;
	}

	function p_setMotorSpeed( deckIndex)
	{
		var speed = motors[deckIndex].speed;
		if(deckIndex !== _activeDeckIndex) {
			return;
		}
		if(speed !== _speed) {
			var intSpeed = Math.max(0.0, Math.min(16383.0, speed*8191.0));

			var msb = Math.floor(intSpeed/128);
			var lsb = Math.floor(intSpeed%128);

			//Midi.sendControlChange(deckIndex + 1 , 69, 0); // Set to 33,3 rpm normal speed
			Midi.sendControlChange(deckIndex + 1, 106, msb);
			Midi.sendControlChange(deckIndex + 1, 74, lsb);
			_speed = motors[deckIndex].speed;
		}
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
		return midiColorChannel(c.r, gamma) + " " +  midiColorChannel(c.g, gamma) + " " +  midiColorChannel(c.b, gamma)
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

	//Color Send Function
	function sendColor(channel, index, color)
	{
		currentColors[index] = color

		let g = device.gamma
		if(index >= 32 && index <= 39) {
			g = device.padGamma
		}
		
		const sysEx = "F0 00 02 0B 7F 0A 03 00 04 " + d2h(index) + " " + midiColor(color, g) + " F7"
		Midi.sendSysEx(sysEx)
		
	}

	function requestPowerOnButtonState() {
		Midi.sendSysEx("F0 00 02 0B 01 0A 42 00 00 F7");
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

