import { DIDCommResolversProxy } from "@sicpa-dlab/didcomm-react-native"
import * as React from "react"
import { useEffect } from "react"
import { StyleSheet, View, Text, Button, NativeEventEmitter, NativeModules, Platform } from "react-native"

import { runDemo } from "./demo"

const { DIDCommResolversProxyModule, RNEventEmitter } = NativeModules

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
})

export default function App() {
  const [isDemoRunning, setIsDemoRunning] = React.useState<boolean | undefined>()

  useEffect(() => {
    //Workaround for issue with non-working NativeEventEmitter if created from library code
    const emitter = Platform.OS === 'ios' ? new NativeEventEmitter(RNEventEmitter) : new  NativeEventEmitter(DIDCommResolversProxyModule)
    DIDCommResolversProxy.start(emitter)
    return () => DIDCommResolversProxy.stop()
  }, [])

  const handleRun = () => {
    setIsDemoRunning(true)
    runDemo()
      .catch((e) => console.log(e))
      .finally(() => setIsDemoRunning(false))
  }

  const handleRunMultiple = () => {
    Promise.all(new Array(10).fill(runDemo().catch((e) => console.log(e))))
  }

  return (
    <View style={styles.container}>
      <Button title={"Run DIDComm demo"} onPress={handleRun} disabled={isDemoRunning}></Button>
      <Button title={"Run multiple DIDComm demos"} onPress={handleRunMultiple}></Button>
      <Text>Please see logs for demo run results.</Text>
    </View>
  )
}
