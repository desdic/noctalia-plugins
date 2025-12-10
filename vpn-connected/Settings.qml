import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  // Plugin API (injected by the settings dialog system)
  property var pluginApi: null

  property var vpnHosts: pluginApi?.pluginSettings?.vpnHosts || []

  spacing: Style.marginM

  Component.onCompleted: {
    Logger.i("vpn-connected", "Settings UI loaded");
  }

  NTextInput {
    Layout.fillWidth: true
    label: "VPN connections"
    description: "Add one of more hosts where ping is available via VPN (comma seperated)"
    placeholderText: ""
    text: root.vpnHosts.join(",")
    onTextChanged: root.vpnHosts = text.split(",")
  }

  function saveSettings() {
    if (!pluginApi) {
      Logger.e("vpn-connected", "Cannot save settings: pluginApi is null");
      return;
    }

    pluginApi.pluginSettings.vpnHosts = root.vpnHosts;

    // Save to disk
    pluginApi.saveSettings();

    Logger.i("vpn-connected", "Settings saved successfully");
  }
}

