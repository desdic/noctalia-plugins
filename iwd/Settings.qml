import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  // Plugin API (injected by the settings dialog system)
  property var pluginApi: null

  property string wifiInterface: pluginApi?.pluginSettings?.wifiInterface || pluginApi?.manifest?.metadata?.defaultSettings?.interface || "wlan0"

  spacing: Style.marginM

  Component.onCompleted: {
    Logger.i("iwd", "Settings UI loaded");
  }

  NTextInput {
    Layout.fillWidth: true
    label: "WIFI interface"
    description: "Add WIFI interface"
    placeholderText: "wlan0"
    text: root.wifiInterface
    onTextChanged: root.wifiInterface = text
  }

  function saveSettings() {
    if (!pluginApi) {
      Logger.e("iwd", "Cannot save settings: pluginApi is null");
      return;
    }

    pluginApi.pluginSettings.wifiInterface = root.wifiInterface;

    // Save to disk
    pluginApi.saveSettings();

    Logger.i("iwd", "Settings saved successfully");
  }
}

