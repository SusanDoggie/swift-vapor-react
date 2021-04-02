import _ from 'lodash';
import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Switch, Route } from 'react-router-dom';
import loadable from '@loadable/component';

const Home = loadable(() => import('./pages/Home'));
const About = loadable(() => import('./pages/About'));

export default class App extends React.Component {
  render() {
    return (
      <SafeAreaProvider>
        <Switch>
        <Route exact path='/'><Home /></Route>
        <Route path='/about'><About /></Route>
        </Switch>
      </SafeAreaProvider>
    );
  }
}
