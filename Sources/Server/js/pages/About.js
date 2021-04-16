import _ from 'lodash';
import React from 'react';
import { Text, View, Image } from 'react-native';
import { Link } from 'react-router-dom';

import birdImg from '../../asserts/bird.jpeg';

export default function(props) {
  
  return (
    <View style={{ padding: 10 }}>
      <Image style={{ width: 96, height: 96 }} source={birdImg} />
      <Text style={{ fontWeight: 'bold' }}>About</Text>
      <Link to="/">Home</Link>
    </View>
  );
}
