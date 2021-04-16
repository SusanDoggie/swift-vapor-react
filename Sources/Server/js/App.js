import _ from 'lodash';
import React from 'react';
import { Switch, Route, Redirect } from 'react-router-dom';
import { SafeAreaProvider } from 'react-native-safe-area-context';

// const Home = loadable(() => import('./pages/Home'));
// const About = loadable(() => import('./pages/About'));
// const NotFound = loadable(() => import('./pages/NotFound'));

import Home from './pages/Home';
import About from './pages/About';
import NotFound from './pages/NotFound';

function Page({ children, author, description, keywords, meta, ...props }) {
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
        <Page path='/redirect'><Redirect to='/about' /></Page>
        <Page path='*' title='404 Not Found' statusCode={404}><NotFound /></Page>
        </Switch>
      </SafeAreaProvider>
    );
  }
}
