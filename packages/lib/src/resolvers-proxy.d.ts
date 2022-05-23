import { DIDResolver, SecretsResolver } from 'didcomm';
import { NativeEventEmitter } from 'react-native';
export declare class DIDCommResolversProxy {
    private static nativeEventEmitter?;
    private static didDocResolver;
    private static secretsResolver;
    static setResolvers(didDocResolver: DIDResolver, secretsResolver: SecretsResolver): void;
    static start(nativeEventEmitter: NativeEventEmitter): void;
    static stop(): void;
    private static findKeys;
    private static findKey;
    private static resolveDid;
}
