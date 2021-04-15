import _ from 'lodash';
import React from 'react';
import { Switch, Route } from 'react-router-dom';
import { SafeAreaProvider } from 'react-native-safe-area-context';

// const Home = loadable(() => import('./pages/Home'));
// const About = loadable(() => import('./pages/About'));

import Home from './pages/Home';
import About from './pages/About';

class Page extends React.Component {

  render() {
    const { children, author, description, keywords, meta, ...props } = this.props;
    return (
      <Route render={({ staticContext }) => {
        if (staticContext) {
          for (const [key, value] of Object.entries(props)) {
            staticContext[key] = value;
          }
          staticContext.meta = { author, description, keywords, ...meta };
        }
        return children;
      }} {...props} />
    );
  }
}

export default class App extends React.Component {
  render() {
    return (
      <SafeAreaProvider
        initialMetrics={{
          frame: { x: 0, y: 0, width: 0, height: 0 },
          insets: { top: 0, left: 0, right: 0, bottom: 0 },
        }}>
        <Switch>
        <Page exact path='/' title='Home'><Home /></Page>
        <Page path='/about' title='About'><About /></Page>
        </Switch>
      </SafeAreaProvider>
    );
  }
}
