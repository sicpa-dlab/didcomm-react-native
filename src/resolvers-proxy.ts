import { DIDResolver, SecretsResolver } from 'didcomm'
import { NativeEventEmitter, NativeModules } from 'react-native'

const { ResolverProxyModule } = NativeModules

export enum ResolverProxyEvent {
  ResolveDid = 'resolve-did',
  FindKey = 'find-key',
  FindKeys = 'find-keys',
}

export class ResolversProxy {
  private nativeEventEmitter: NativeEventEmitter

  constructor(private didDocResolver: DIDResolver, private secretsResolver: SecretsResolver) {
    this.nativeEventEmitter = new NativeEventEmitter(ResolverProxyModule)
  }

  start() {
    this.nativeEventEmitter.addListener(ResolverProxyEvent.ResolveDid, (event) => {
      console.log("Got ResolveDid event")
      this.resolveDid(event.did)
    })
    this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKey, (event) => this.findKey(event.kid))
    this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKeys, (event) => this.findKeys(event.kids))
  }

  stop() {
    Object.values(ResolverProxyEvent).forEach((eventType) => {
      this.nativeEventEmitter.removeAllListeners(eventType)
    })
  }

  private async findKeys(kids: string[]) {
    const secretIds = await this.secretsResolver.find_secrets(kids)
    ResolverProxyModule.setFoundSecretIds(secretIds)
  }

  private async findKey(kid: string) {
    const secret = await this.secretsResolver.get_secret(kid)
    ResolverProxyModule.setFoundSecret(secret)
  }

  private async resolveDid(did: string) {
    console.log(`Resolve DID called on proxy ${did}`)
    const resolvedDid = await this.didDocResolver.resolve(did)
    ResolverProxyModule.setResolvedDid(resolvedDid)
  }
}
