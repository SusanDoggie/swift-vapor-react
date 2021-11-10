import './polyfill';
import React from 'react';
import { AppRegistry } from 'react-native';
import { BrowserRouter } from 'react-router-dom';
import App from './App';

import './default.css';

function Main(props) {
	return <BrowserRouter><App /></BrowserRouter>;
}

AppRegistry.registerComponent('App', () => Main);
AppRegistry.runApplication('App', {
	rootTag: document.getElementById('root')
});