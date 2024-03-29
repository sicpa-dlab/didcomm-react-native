# DIDComm React Native

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Basic [DIDComm v2](https://identity.foundation/didcomm-messaging/spec) support for React Native framework (Android and iOS).

## Under the hood

This package is React Native wrapper using [DIDComm JVM](https://github.com/sicpa-dlab/didcomm-jvm) library for Android and [DIDComm Swift](https://github.com/sicpa-dlab/didcomm-rust/tree/main/wrappers/swift) for iOS.
It contains native modules that are using native libraries API and exposes Javascript/Typescript API using React Native bridge.

Design documentation for complex parts of implementation can be found in [docs folder](./docs).

## Usage

Install from npm:

```bash
npm install @sicpa_open_source/didcomm-react-native
```

If you need to use this package in another RN library:

- Please see: https://github.com/callstack/react-native-builder-bob#how-do-i-add-a-react-native-library-containing-native-code-as-a-dependency-in-my-library
- Note that you need to add this package as end application dependency in order to make native modules work

Add following DIDComm resolvers initialization code to your App (it's a workaround that will be removed later):

```typescript
import { NativeModules, NativeEventEmitter } from 'react-native'
import { useEffect } from 'react'
import { DIDCommResolversProxy } from "@sicpa_open_source/didcomm-react-native"

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

A general usage of the API is the following:

- Sender Side:
  - Build a `Message` (plaintext, payload).
  - Convert a message to a DIDComm Message for further transporting by calling one of the following:
    - `Message.pack_encrypted` to build an Encrypted DIDComm message
    - `Message.pack_signed` to build a Signed DIDComm message
    - `Message.pack_plaintext` to build a Plaintext DIDComm message
- Receiver side:
  - Call `Message.unpack` on receiver side that will decrypt the message, verify signature if needed
    and return a `Message` for further processing on the application level.

## Run demo

### Android

```sh
yarn bootstrap
yarn demo android
```

### iOS

On Intel Mac:

```sh
yarn bootstrap
cd ./demo/ios && pod install && cd ./../..
yarn demo ios
```

On M1 Mac:

```sh
yarn bootstrap
cd ./demo/ios && arch -x86_64 pod install && cd ./../..
arch -x86_64 yarn demo ios
```

## Publishing new version

Manually bump package version in `package.json` file.
The package will be published automatically from `main` branch by GitHub Actions.

## Common issues

### Duplicate class errors related to `com.google.crypto.tink`

- Error message:

  ```
  > A failure occurred while executing com.android.build.gradle.internal.tasks.CheckDuplicatesRunnable
  > Duplicate class com.google.crypto.tink.Aead found in modules jetified-tink-1.6.1 (com.google.crypto.tink:tink:1.6.1) and jetified-tink-android-1.5.0 (com.google.crypto.tink:tink-android:1.5.0)
   Duplicate class com.google.crypto.tink.BinaryKeysetReader found in modules jetified-tink-1.6.1 (com.google.crypto.tink:tink:1.6.1) and jetified-tink-android-1.5.0 (com.google.crypto.tink:tink-android:1.5.0)
   Duplicate class com.google.crypto.tink.BinaryKeysetWriter found in modules jetified-tink-1.6.1 (com.google.crypto.tink:tink:1.6.1) and jetified-tink-android-1.5.0 (com.google.crypto.tink:tink-android:1.5.0)
  ```

- Solution: Exclude `com.google.crypto.tink:tink` module from library native package using gradle configuration
  ```
  implementation (project(":sicpa-dlab_didcomm-react-native")) {
      exclude(group: "com.google.crypto.tink", module: "tink")
  }
  ```
