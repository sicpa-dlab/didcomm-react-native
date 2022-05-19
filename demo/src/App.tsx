import * as React from 'react'

import { StyleSheet, View, Text, Button, NativeEventEmitter, NativeModules } from 'react-native'
import { runDemo } from './demo'

export default function App() {
    const [isDemoRunning, setIsDemoRunning] = React.useState<boolean | undefined>()

    const handleRun = () => {
        setIsDemoRunning(true)
        runDemo()
            .catch((e) =>
                console.log(e)
            ).finally(() => setIsDemoRunning(false))
    }

    return (
        <View style={styles.container}>
            <Button title={'Run DIDComm demo'} onPress={handleRun} disabled={isDemoRunning}></Button>
            <Text>Please see logs for demo run results.</Text>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
    },
    box: {
        width: 60,
        height: 60,
        marginVertical: 20,
    },
})
