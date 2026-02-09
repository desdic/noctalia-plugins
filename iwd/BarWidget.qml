import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

NIconButton {
	id: root

	property var pluginApi: null
	property ShellScreen screen
	property string widgetId: ""
	property string section: ""

	readonly property string wifiInterface: pluginApi?.pluginSettings?.wifiInterface || "wlan0"

	property bool wifiConnected: false
	property var wifiinfo: {}
	property int signalStrength: 0

	icon: signalIcon(root.signalStrength, root.wifiConnected)
	tooltipText: buildTooltip()
	tooltipDirection: BarService.getTooltipDirection()
	baseSize: Style.capsuleHeight
	applyUiScale: false
	customRadius: Style.radiusL
	colorBg: Style.capsuleColor
	colorFg: Color.mOnSurface
	colorBorder: Color.transparent
	colorBorderHover: Color.transparent

	function signalIcon(signal, isConnected = false) {
		if (!isConnected)
		return "wifi-off";

		if (signal <= -90)
		return "wifi-0";

		if (signal <= -80)
		return "wifi-1";

		if (signal <= -60)
		return "wifi-2";

		return "wifi";
	}

	Process {
		id: wifiCheckConnected
		running: false
		command: ["iwctl", "station", wifiInterface, "show"]

		stdout: StdioCollector {
			onStreamFinished: {
				const lines = text.split("\n");
				const startIndex = lines.findIndex(line => line.trim().startsWith("State"));
				const relevantLines = startIndex !== -1 ? lines.slice(startIndex) : [];

				const data = {};
				relevantLines.forEach(line => {
					const match = line.match(/^\s*(.+?)\s{2,}(.+)$/);
					if (match) {
						const key = match[1].trim();
						const value = match[2].trim();
						data[key] = value;
					}
				});

				wifiinfo = data;
				wifiConnected = data["State"] === "connected";

				if (wifiConnected && wifiinfo && wifiinfo["AverageRSSI"]) {
					const rssiString = wifiinfo["AverageRSSI"].toString();
					const rssiParts = rssiString.split(" ");
					
					if (rssiParts.length > 0) {
						const parsedValue = parseInt(rssiParts[0], 10);
						if (!isNaN(parsedValue)) {
							signalStrength = parsedValue;  // Note: fixed typo
							root.icon = signalIcon(signalStrength, root.wifiConnected);
						}
					}
				}
			}
		}
	}

	Timer {
		interval: 1000
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: wifiCheckConnected.running = true
	}

	function buildTooltip() {
		if (!wifiConnected) return "";

		return Object.keys(wifiinfo).map(k => `${k}: ${wifiinfo[k]}`).join("\n");
	}
}

