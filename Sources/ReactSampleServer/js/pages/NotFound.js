import _ from 'lodash';
import React from 'react';
import { Text, View } from 'react-native';

export default function NotFound() {
  return <View style={{ padding: 10 }}>
    <Text style={{ fontWeight: 'bold' }}>404 Not Found</Text>
  </View>;
}
