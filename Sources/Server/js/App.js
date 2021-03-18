import _ from 'lodash';
import React from 'react';
import { View, Text, Button } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import loadable from '@loadable/component';

const TableScreen = loadable(() => import('./pages/TableScreen'));

const Drawer = createDrawerNavigator();

const linking = {
  prefixes: [
  ],
  config: {
    screens: {
      Table: 'table',
      Table2: 'table2',
    },
  },
};

class SideMenu extends React.PureComponent {

  render() {
    console.log(this.props)
    return (
      <View style={{ width: 96 }}>
        <Button title='Table' onPress={() => this.props.navigation.navigate({ name: "Table" })} />
        <Button title='Table2' onPress={() => this.props.navigation.navigate({ name: "Table2" })} />
      </View>
    );
  }
}

export default class App extends React.Component {
  render() {
    return (
      <SafeAreaProvider>
        <NavigationContainer linking={linking} fallback={<Text>Loading...</Text>}>
          <Drawer.Navigator
            openByDefault
            drawerType='permanent'
            overlayColor='transparent'
            drawerContent={(props) => <SideMenu {...props} />}>
            <Drawer.Screen name="Table" component={TableScreen} />
            <Drawer.Screen name="Table2" component={TableScreen} />
          </Drawer.Navigator>
        </NavigationContainer>
      </SafeAreaProvider>
    );
  }
}
