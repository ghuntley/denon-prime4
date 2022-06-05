import airAssignments 1.0
import InputAssignment 0.1
import OutputAssignment 0.1
import Device 0.1
import QtQuick 2.0
import Planck 1.0

Device {
	id: device

	property real gamma: 3.5
	property real padGamma: 3.5
	
	controls: []
	useGlobalShift: false
	numberOfLayers: 0

	property string deviceInfo: ""

	property QObjProperty pRunningDark: Planck.getProperty("/GUI/Scripted/RunningDark");
	property bool isRunningDark: pRunningDark && pRunningDark.translator ? pRunningDark.translator.state : false
	onIsRunningDarkChanged: {
		if(isRunningDark) {
			Midi.sendNoteOn(0, 117, 0)
		} 
		else {
			for(var channel in currentColors) {
				for(var key in currentColors[channel]) {
					sendColor(channel, key, currentColors[channel][key]);
				}
			}
			for(var channel in currentSimpleColors) {
				for(var simpleKey in currentSimpleColors[channel]) {
					sendSimpleColor(channel, simpleKey, currentSimpleColors[channel][simpleKey]);
				}
			}
		}
	}
	
	property QObjProperty pCalibratePlatter: Planck.getProperty("/GUI/Scripted/CalibratePlatter");
	property bool calibratePlatter: pCalibratePlatter && pCalibratePlatter.translator && pCalibratePlatter.translator.state
	onCalibratePlatterChanged: {
		if(calibratePlatter) {
			Midi.sendSysEx("F0 00 02 0B 7F 08 7D 00 02 10 7F F7")
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Setup

	function sendInitializationMessage() {
		Midi.sendSysEx("F0 00 02 0B 7f 08 60 00 04 04 01 01 03 F7")
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
		
		isInitializing = true
		
		requestPowerOnButtonState();

		sendInitializationMessage();

		initTimer.start()
	}
	
	Component.onDestruction: {
		if(Planck.quitReason() === QuitReasons.ControllerMode) {
			Midi.sendNoteOn(0, 117, 1) // Dim all LEDs
		}
		else {
			Midi.sendNoteOff(0, 117) // Turn all LEDs off
		}
	}
	
	property var currentColors
	property var currentSimpleColors
	
	function dec2hex(d){
		return (+d).toString(16).toUpperCase()
	}
	
	function midiColorChannel(c, gamma){
		return dec2hex(Math.min(127, Math.max(0,Math.floor(Math.pow(c, gamma) * 127))))
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

		if(isRunningDark)
			return;
		
		if(value === 0) {
			Midi.sendNoteOff(channel, index)
		} else {
			Midi.sendNoteOn(channel, index, value)
		}
	}
	
	//Color Send Function
	function sendColor(channel, index, color)
	{
		if(!currentColors[channel]) {
			currentColors[channel] = {};
		}
		currentColors[channel][index] = color;

		if(isRunningDark) {
			return;
		}
		
		var g = device.gamma
		if(index >= 15 && index <= 23) {
			g = device.padGamma
		}
		
		var sysEx = "F0 00 02 0B 7F 08 03 00 05 " + dec2hex(channel) + " " + dec2hex(index) + " " + midiColor(color, g)+" F7"
		Midi.sendSysEx(sysEx)
	}

	property list<Item> oleds
	property bool enablePartialOledUpdates: false

	Repeater {
		model: 8
		Item {
			id: self
			property var buffer

			function numberToHex( num )
			{
				var result = "0x";
				if(num < 0x10)
				{
					result += "0"
				}
				result += num.toString(16);
				return result;
			}

			function buildSysEx(painter, x,y,w,h) {
				var result = "00 02 0B 7F 08 0B"

				var imageData = painter.imageToString(x, y, w, h);
				var dataLen = ((imageData.length+1) / 3) + 5;

				result += " " + numberToHex((dataLen  >> 7) & 0x7F)
				result += " " + numberToHex( dataLen   & 0x7F )
				result += " " + index.toString(16);
				result += " " + numberToHex(y/8) ;
				result += " " + numberToHex((y/8)+(h/8));
				result += " " + numberToHex(x) + " ";
				result += " " + numberToHex(x+w-1);
				result += " " + imageData

				return result;
			}

			function update(painter) {
				if(device.enablePartialOledUpdates) {
					var i = 0
					var bufToSend = []
					for(var y = 0; y < 4; y++) {
						for(var x = 0; x < 16; x++) {
							var result = buildSysEx(painter, x*8, y*8, 8, 8)
							if(buffer[i] !== result) {
								//Midi.sendSysEx(result);
								buffer[i] = result;
								bufToSend.push(result);
							}
							i++
						}
					}

					if(bufToSend.length < 20) {
						for(var i = 0; i < bufToSend.length; i++) {
							Midi.sendSysEx(bufToSend[i])
						}
					} else {
						var fullSysEx = buildSysEx(painter, 0, 0, 128, 32)
						Midi.sendSysEx(fullSysEx);
					}
				} else {
					var fullSysEx = buildSysEx(painter, 0, 0, 128, 32)
					Midi.sendSysEx(fullSysEx);
				}
			}

			Component.onCompleted: {
				var b = [];
				for(var i = 0; i < 4 * 16; i++)
				{
					b.push( "" );
				}

				buffer = b;
				device.oleds.push(self)
			}
		}
	}

	function requestPowerOnButtonState() {
		Midi.sendSysEx("F0 00 02 0B 7F 08 42 00 00 F7");
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
		//console.info("Received SysEx:", sysExString)
		var valueList = sysExToIntList(sysExString);
		var result = "";

		// 0xf0 0x00 0x02 0x0b 0x00 0x06 0x42 0x00 0x01 0x01 0xf7
		if(valueList[1] === 0x00 && valueList[2] === 0x02 && valueList[3] === 0x0B && valueList[6] === 0x42)
		{
			if(valueList[9] === 0x0) {
				console.log("Power on self request: No special power on request")
			}
			else if(valueList[9] === 0x1) {
				console.log("Power on self request: Request test-mode entry")
				quitToTestApp()
			}
		}
		else if(valueList[1] === 0x7E && valueList[2] === 0x00 && valueList[3] === 0x06 && valueList[4] === 0x02)
		{
			for(var i=0;i<4;i++) {
				result += valueList[i + 11];
				if(i == 1)
					result += ".";
			}
			deviceInfo = result;
		}
	}
}

