import airAssignments 1.0
import InputAssignment 0.1
import OutputAssignment 0.1
import Device 0.1
import QtQuick 2.0

Device {
	id: device
	
	property color deckColor: "#01e771"
	
	property string deviceInfo: "";
	
	readonly property QtObject artwork: QtObject {
		property bool enabled: false
		property int index: 0
		property real alpha: 0.85
		
		onAlphaChanged: device.setElementARGB(0, Qt.rgba(1.0, 1.0, 1.0, alpha))
		onEnabledChanged: device.updateDisplayElements()
		onIndexChanged: {
			if(index == 0) {
				device.updateDisplayDelayTimer.start()
			}
			else {
				device.updateDisplayElements()
			}
		}
		
		Component.onCompleted: device.setElementARGB(0, Qt.rgba(1.0, 1.0, 1.0, alpha))
	}
	
	readonly property QtObject logo: QtObject {
		property bool enabled: false
		onEnabledChanged: {
			if(enabled) {
				device.updateDisplayDelayTimer.start()
			}
			else {
				device.updateDisplayElements()
			}
		}
		
		property color color: "#ffffff"
		onColorChanged: device.setElementARGB(1, color)
		
		Component.onCompleted: device.setElementARGB(1, color)
	}
	
	readonly property QtObject platterPosition: QtObject {
		property bool enabled: false
		
		onEnabledChanged: {
			if(!enabled) {
				device.updateDisplayDelayTimer.start()
			}
			else {
				device.updateDisplayElements()
			}
		}
		
		property color ringColor: "#ffffff"
		onRingColorChanged: device.setElementARGB(2, ringColor)
		
		property color indicatorColor: "#FFFFFF"
		onIndicatorColorChanged: device.setElementARGB(3, indicatorColor)
		
		Component.onCompleted: {
			device.setElementARGB(2, ringColor)
			device.setElementARGB(3, indicatorColor)
		}
	}
	
	readonly property QtObject slipPosition: QtObject {
		property bool enabled: true
		property bool active: false
		property real alphaValue: 0.6
		
		property color indicatorColor: device.deckColor
		onIndicatorColorChanged: device.setElementARGB(5, indicatorColor);
		
		onAlphaValueChanged: {
			device.setElementARGB(4, Qt.rgba(0.0, 0.0, 0.0, alphaValue));
		}
		
		onActiveChanged: {
			device.updateDisplayElements();
		}
		
		onEnabledChanged: {
			if(!enabled) {
				device.updateDisplayDelayTimer.start()
			}
			else {
				device.updateDisplayElements()
			}
		}
		
		Component.onCompleted: {
			device.setElementARGB(4, Qt.rgba(0.0, 0.0, 0.0, 0.6));
			device.setElementARGB(5, device.deckColor);
		}
	}
		
	readonly property QtObject loopAndLayerText: QtObject {
		property bool enabled: false
		onEnabledChanged: {
			if(enabled) {
				device.slipPosition.alphaValue = 0.25;
			}
			else {
				device.slipPosition.alphaValue = 0.6;
			}
			
			device.updateDisplayElements();
		}
		
		property string text: ""
		onTextChanged: device.updateDisplayElements()
		
		property color color: "#ffffff"
		onColorChanged: device.setElementARGB(8, color)
		
		Component.onCompleted: device.setElementARGB(8, color)
	}
	
	function d2h(d){
		return (+d).toString(16).toUpperCase()
	}
	
	function colorComponentToHex(component) {
		var result = ""
		
		var ci = Math.floor(component * 255)
		result = device.d2h((ci & 0xF0) >> 4)
		result += " "
		result += device.d2h(ci & 0x0F)
		
		return result
	}
	
	function colorToHex(color) {
		return colorComponentToHex(color.a) + " " + colorComponentToHex(color.r) + " " + colorComponentToHex(color.g) + " " + colorComponentToHex(color.b)
	}
	
	function setElementARGB(elementId, color) {
		// Available elementIds
		// 0 - Album Artwork (ignored)
		// 1 - Engine Logo
		// 2 - Platter Position Ring
		// 3 - Platter Position Indicator
		// 4 - Slip Position Ring
		// 5 - Slip Position Indicator
		// 6 - Track Progress Ring
		// 7 - Track Progress Indicator
		// 8 - Loop and Layer Text
		
		Midi.sendSysEx("F0 00 02 0B 01 06 0B 00 09 %1 %2 F7".arg(device.d2h(elementId)).arg(colorToHex(color)))
	}
	
	function loopTextToIndex(text) {
		switch(text) {
		case "1/64":
			return 0x0
		case "1/32":
			return 0x1
		case "1/16":
			return 0x2
		case "1/8":
			return 0x3
		case "1/4":
			return 0x4
		case "1/2":
			return 0x5
		case "1":
			return 0x6
		case "2":
			return 0x7
		case "4":
			return 0x8
		case "8":
			return 0x9
		case "16":
			return 0xA
		case "32":
			return 0xB
		case "64":
			return 0xC
		case "A":
			return 0xE
		case "B":
			return 0xF
		}
		return 0xD
	}
	
	property Timer updateDisplayDelayTimer: Timer {
		interval: 1000
		repeat: false
		onTriggered: {
			device.updateDisplayElements()
		}
	}
	
	function updateDisplayElements() {
		var enabledSections = [0, 0, 0, 0]
		
		// Element Enable/Disable 1
		//		Bit[0] - Album Artwork
		//		Bit[1] - Engine Logo
		//		Bit[2] - Platter Position Ring
		//		Bit[4] - Slip Position Ring
		//		Bit[5] - Slip Position Indicator
		enabledSections[0] |= artwork.enabled << 0
		enabledSections[0] |= logo.enabled << 1
		enabledSections[0] |= platterPosition.enabled << 2
		enabledSections[0] |= slipPosition.active << 4
		enabledSections[0] |= slipPosition.active << 5
		
		// Element Enable/Disable 2
		//		Bit[0] - Track Progress Indicator
		//		Bit[1] - Loop and Layer Text
		//		Bit[2] - Burst Image
		enabledSections[1] |= loopAndLayerText.enabled << 1
		
		// Current Album Artwork Index
		// ...
		enabledSections[2] = artwork.index
		
		// Loop and LayerText Display
		enabledSections[3] = loopTextToIndex(loopAndLayerText.text)
		
		var sysEx = "F0 00 02 0B 01 06 0A 00 04 "
		
		for(var i = 0; i < enabledSections.length; ++i) {
			sysEx += device.d2h(enabledSections[i]) + " "
		}
		
		sysEx += "F7"
		
		Midi.sendSysEx(sysEx)
	}

	function sysEx(sysExString) {
		var valueList = sysExString.split(" ");
		var result = "";
		
		for(var i=0;i<4;i++) {
			result += parseInt(valueList[i + 11], 16);
			if(i == 1) {
				result += ".";
			}
		}
		
		deviceInfo = result;
	}
	
	Component.onCompleted: {
		Midi.sendSysEx("F0 7E 00 06 01 F7")
		updateDisplayElements()
	}
	
	Component.onDestruction: {
		// Disable all 
		artwork.enabled = true
		logo.enabled = true
		platterPosition.enabled = false
		slipPosition.active = false
		loopAndLayerText.enabled = false
		artwork.index = 0
		loopAndLayerText.text = ""
	}
}

