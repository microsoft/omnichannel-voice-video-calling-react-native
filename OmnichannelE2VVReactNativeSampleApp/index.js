/**
 * @format
 */

import 'react-native-get-random-values';
import 'node-libs-react-native/globals';
import {AppRegistry} from 'react-native';
import App from './src/components/App';
import {name as appName} from './src/app.json';

AppRegistry.registerComponent(appName, () => App);
