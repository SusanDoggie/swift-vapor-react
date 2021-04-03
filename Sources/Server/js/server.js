import React from 'react';
import { AppRegistry } from 'react-native';
import { StaticRouter } from 'react-router-dom';
import ReactDOMServer from 'react-dom/server';
import App from './App';

global.render = function(location) {
	
	class Main extends React.Component {
		render() {
			return <StaticRouter location={location}><App /></StaticRouter>;
		}
	}
	
	AppRegistry.registerComponent('App', () => Main);
	const { element, getStyleElement } = AppRegistry.getApplication('App');

	return {
		html: ReactDOMServer.renderToString(element),
		css: ReactDOMServer.renderToStaticMarkup(getStyleElement()),
	};
}