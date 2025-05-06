import { AppRegistry } from 'react-native';
import App from './App';
import { name as appName } from './app.json'; // Ensure this matches the app name

import { registerRootComponent } from 'expo'; // Use this if using Expo
registerRootComponent(App);

// If you're **not** using Expo, then use the following instead:
AppRegistry.registerComponent(appName, () => App);
AppRegistry.runApplication(appName, {
  initialProps: {},
  rootTag: document.getElementById('app-root'), // This is the DOM element to mount the app
});
