import _ from 'lodash';
import React from 'react';
import URLSearchParams from '@ungap/url-search-params'
import { Text, View, Image } from 'react-native';
import { Link, useLocation } from 'react-router-dom';

import birdImg from '../../asserts/bird.jpeg';

export default function(props) {
  
  const query = new URLSearchParams(useLocation().search);

  return (
    <View style={{ padding: 10 }}>
      <Image style={{ width: 96, height: 96 }} source={birdImg} />
      <Text style={{ fontWeight: 'bold' }}>Hello {query.get('name') ?? 'World'}</Text>
      <Link to="/about">About</Link>
    </View>
  );
}
