import React from 'react';
import {StyleSheet, Text, View} from 'react-native';
import {NavigationContainer} from '@react-navigation/native';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';

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

function ThirdScreen() {
  return (
    <View style={styles.centerTextContainer}>
      <Text>Third</Text>
    </View>
  );
}

const Tab = createBottomTabNavigator();

const App = () => {
  return (
    <NavigationContainer>
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
