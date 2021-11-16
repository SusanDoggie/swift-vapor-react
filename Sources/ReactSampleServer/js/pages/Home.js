import _ from 'lodash';
import React from 'react';
import { Text, View, Image } from 'react-native';
import { Link } from 'react-router-dom';
import { useLocation } from 'react-router';
import { URLSearchParams } from 'url';

import birdImg from '../../asserts/bird.jpeg';

export default function Home() {

  const location = useLocation();

  const query = new URLSearchParams(location.search);

  return <View style={{ padding: 10 }}>
    <Image style={{ width: 96, height: 96 }} source={birdImg} />
    <Text style={{ fontWeight: 'bold' }}>Hello {query.get('name') ?? 'World'}</Text>
    <Link to="/about">About</Link>
  </View>;
}
