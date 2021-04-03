import _ from 'lodash';
import React from 'react';
import { Switch, Route } from 'react-router-dom';
import { SafeAreaProvider } from 'react-native-safe-area-context';

// const Home = loadable(() => import('./pages/Home'));
// const About = loadable(() => import('./pages/About'));

import Home from './pages/Home';
import About from './pages/About';

const Page = (props) => {
  React.useEffect(() => {
    document.title = props.title || "";
  }, [props.title]);
  return props.children;
};

export default class App extends React.Component {
  render() {
    return (
      <SafeAreaProvider
        initialMetrics={{
          frame: { x: 0, y: 0, width: 0, height: 0 },
          insets: { top: 0, left: 0, right: 0, bottom: 0 },
        }}>
        <Switch>
        <Route exact path='/'>
          <Page title="Home"><Home /></Page>
        </Route>
        <Route path='/about'>
          <Page title="About"><About /></Page>
        </Route>
        </Switch>
      </SafeAreaProvider>
    );
  }
}
