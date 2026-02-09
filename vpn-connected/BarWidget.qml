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

	readonly property var vpnHosts: pluginApi?.pluginSettings?.vpnHosts || []

	property bool vpnConnected: false

	icon: vpnConnectedIcon(root.vpnConnected)
	tooltipText: buildTooltip()
	tooltipDirection: BarService.getTooltipDirection()
	baseSize: Style.capsuleHeight
	applyUiScale: false
	customRadius: Style.radiusL
	colorBg: Style.capsuleColor
	colorFg: Color.mOnSurface
	colorBorder: Color.transparent
	colorBorderHover: Color.transparent

	function vpnConnectedIcon(isConnected = false) {
		if (isConnected)
			return "shield";

		return "shield-off";
	}

	function buildPingChain(hosts) {
		if (!hosts || !Array.isArray(hosts) || hosts.length === 0) {
			return "";
		}

		return hosts
			.map(h => `ping -c1 -W2 ${h} >/dev/null 2>&1`)
			.join(" || ");
	}

	function buildCommand() {
		var tmp = buildPingChain(root.vpnHosts);
		if (tmp === "")
			tmp = ["false"];

		return ["sh", "-c", buildPingChain(root.vpnHosts)];
	}

	Process {
		id: vpnCheckConnected
		running: false
		command: buildCommand()

		onExited: (exitCode, exitStatus) => {
			if (exitCode === 0) {
				vpnConnected = true;
				Logger.d("successfull command:", command);
			} else {
				vpnConnected = false
				Logger.d("failed command:", command);
			}
		}
	}

	Timer {
		interval: 2000
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: vpnCheckConnected.running = true
	}

	function buildTooltip() {
		if (!vpnConnected) return "Disconnected";

		return "Connected";
	}
}

