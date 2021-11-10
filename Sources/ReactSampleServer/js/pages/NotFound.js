import _ from 'lodash';
import React from 'react';
import { Text, View } from 'react-native';

export default class NotFound extends React.Component {
  render() {
    return <View style={{ padding: 10 }}>
      <Text style={{ fontWeight: 'bold' }}>404 Not Found</Text>
    </View>;
  }
}
