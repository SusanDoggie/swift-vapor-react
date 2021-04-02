import React from 'react';
import { AppRegistry } from 'react-native';
import { BrowserRouter } from 'react-router-dom';
import App from './App';

class Main extends React.Component {
	render() {
		return <BrowserRouter><App /></BrowserRouter>;
	}
}

AppRegistry.registerComponent('App', () => Main);
AppRegistry.runApplication('App', {
	rootTag: document.getElementById('root')
});