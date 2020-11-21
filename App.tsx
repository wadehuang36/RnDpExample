import React, { useEffect } from 'react';
import { Linking, StyleSheet, Text, View } from 'react-native';
import urlParse from 'url-parse';

import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import {
  NavigationContainer,
  NavigationContainerRef,
} from '@react-navigation/native';

function FirstScreen() {
  return (
    <View style={styles.centerTextContainer}>
      <Text>First</Text>
    </View>
  );
}

function SecondScreen() {
  return (
    <View style={styles.centerTextContainer}>
      <Text>Second</Text>
    </View>
  );
}

function ThirdScreen(props) {
  return (
    <View style={styles.centerTextContainer}>
      <Text>Third, Params:{JSON.stringify(props.route.params)}</Text>
    </View>
  );
}

const Tab = createBottomTabNavigator();

const App = () => {
  let navigationRef: NavigationContainerRef;

  function intiNavigation(ref: NavigationContainerRef) {
    if (ref) {
      navigationRef = ref;
      // handle deep link that app isn't launched
      Linking.getInitialURL().then(function (url) {
        handleDeepLink({url});
      });
    }
  }

  function handleDeepLink({url}) {
    if (url) {
      const parsedUrl = urlParse(url, true);

      // use host as route name and query as navigation params
      navigationRef.navigate({
        name: parsedUrl.host,
        params: parsedUrl.query,
      });
    }
  }

  useEffect(() => {
    // add deep link listener to handle deep link after app is launched
    Linking.addEventListener('url', handleDeepLink);

    return () => {
      Linking.removeEventListener('url', handleDeepLink);
    };
  });

  return (
    <NavigationContainer ref={intiNavigation}>
      <Tab.Navigator>
        <Tab.Screen name="first" component={FirstScreen} />
        <Tab.Screen name="second" component={SecondScreen} />
        <Tab.Screen name="third" component={ThirdScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
};

const styles = StyleSheet.create({
  centerTextContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default App;
