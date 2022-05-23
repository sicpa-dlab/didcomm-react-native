# DIDComm React Native

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Basic [DIDComm v2](https://identity.foundation/didcomm-messaging/spec) support for React Native framework (Android only).

## Under the hood

This package is React Native wrapper for [DIDComm JVM](https://github.com/sicpa-dlab/didcomm-jvm) library. 
It contains native modules that are using [DIDComm JVM](https://github.com/sicpa-dlab/didcomm-jvm) API and exposes Javascript/Typescript API using React Native bridge.

## Usage

Add following DIDComm resolvers initialization code to your App (it's a workaround that will be removed later):

```typescript
import { NativeModules } from 'react-native'

const { DIDCommResolversProxyModule } = NativeModules

export default function App() {

    useEffect(() => {
        const nativeEventEmitter = new NativeEventEmitter(DIDCommResolversProxyModule)
        DIDCommResolversProxy.start(nativeEventEmitter)
        return () => DIDCommResolversProxy.stop()
    },[])
    

    return ...
}
```

## Run demo

```sh
cd ./demo
yarn install
yarn android
```

## Examples

A general usage of the API is the following:

- Sender Side:
    - Build a `Message` (plaintext, payload).
    - Convert a message to a DIDComm Message for further transporting by calling one of the following:
        - `Message.pack_encrypted` to build an Encrypted DIDComm message
        - **[To be implemented]** `Message.pack_signed` to build a Signed DIDComm message
        - **[To be implemented]** `Message.pack_plaintext` to build a Plaintext DIDComm message
- Receiver side:
    - Call `Message.unpack` on receiver side that will decrypt the message, verify signature if needed
      and return a `Message` for further processing on the application level.


## Publishing new version

If you have write access to the repo, you can publish new version using following steps:
- Create GitHub Personal access token with full `repo` and `write:packages` scopes if you don't have one
- Run `npm login --registry=https://npm.pkg.github.com` command and log-in using your access token as a password
- Run `npm publish` command from the repo root