import { DIDResolver, SecretsResolver } from 'didcomm'
import { NativeEventEmitter, NativeModules } from 'react-native'

const { ResolverProxyModule } = NativeModules
const { DID_STRING_KEY, KID_STRING_KEY, KIDS_STRING_KEY } = ResolverProxyModule.getConstants()

export enum ResolverProxyEvent {
    ResolveDid = 'resolve-did',
    FindKey = 'find-key',
    FindKeys = 'find-keys',
}

export class ResolversProxy {
    private static nativeEventEmitter?: NativeEventEmitter
    private static didDocResolver: DIDResolver | null = null
    private static secretsResolver: SecretsResolver | null = null

    public static setResolvers(didDocResolver: DIDResolver, secretsResolver: SecretsResolver) {
        this.didDocResolver = didDocResolver
        this.secretsResolver = secretsResolver
    }

    public static start(nativeEventEmitter: NativeEventEmitter) {
        this.nativeEventEmitter = nativeEventEmitter //new NativeEventEmitter(ResolverProxyModule)
        this.nativeEventEmitter.addListener(ResolverProxyEvent.ResolveDid, (event) => this.resolveDid(event[DID_STRING_KEY]))
        this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKey, (event) => this.findKey(event[KID_STRING_KEY]))
        this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKeys, (event) => this.findKeys(event[KIDS_STRING_KEY]))
    }

    public static stop() {
        Object.values(ResolverProxyEvent).forEach((eventType) => {
            this.nativeEventEmitter?.removeAllListeners(eventType)
        })
    }

    private static async findKeys(kids: string[]) {
        if (!this.secretsResolver) {
            console.log("Attempted to proxy 'findKeys' call, but secret resolver is not defined. Skipping...")
            return
        }
        const secretIds = await this.secretsResolver.find_secrets(kids)
        ResolverProxyModule.setFoundSecretIds(JSON.stringify(secretIds))
    }

    private static async findKey(kid: string) {
        if (!this.secretsResolver) {
            console.log("Attempted to proxy 'findKey' call, but secret resolver is not defined. Skipping...")
            return
        }
        const secret = await this.secretsResolver.get_secret(kid)
        ResolverProxyModule.setFoundSecret(JSON.stringify(secret))
    }

    private static async resolveDid(did: string) {
        if (!this.didDocResolver) {
            console.log("Attempted to proxy 'resolveDid' call, but DID doc resolver is not defined. Skipping...")
            return
        }
        const resolvedDid = await this.didDocResolver.resolve(did)
        ResolverProxyModule.setResolvedDid(JSON.stringify(resolvedDid))
    }
}
