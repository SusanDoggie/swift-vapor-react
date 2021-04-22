import _ from 'lodash';
import React from 'react';
import { Text, View, Image } from 'react-native';
import { Link } from 'react-router-dom';
import { withRouter } from "react-router";
import URLSearchParams from '@ungap/url-search-params';

import birdImg from '../../asserts/bird.jpeg';

class Home extends React.Component {

  render() {

    const query = new URLSearchParams(this.props.location.search);

    return (
      <View style={{ padding: 10 }}>
        <Image style={{ width: 96, height: 96 }} source={birdImg} />
        <Text style={{ fontWeight: 'bold' }}>Hello {query.get('name') ?? 'World'}</Text>
        <Link to="/about">About</Link>
      </View>
    );
  }
}

export default withRouter(Home);