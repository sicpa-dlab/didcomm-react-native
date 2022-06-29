import { DIDResolver, SecretsResolver } from "didcomm"
import { NativeEventEmitter, NativeModules } from "react-native"
import uuid from "react-native-uuid"

const { DIDCommResolversProxyModule } = NativeModules
const { DID_STRING_KEY, KID_STRING_KEY, KIDS_STRING_KEY, RESOLVERS_ID_STRING_KEY } =
  DIDCommResolversProxyModule.getConstants()

enum ResolverProxyEvent {
  ResolveDid = "resolve-did",
  FindKey = "find-key",
  FindKeys = "find-keys",
}

interface DIDCommResolvers {
  didDocResolver: DIDResolver | null
  secretsResolver: SecretsResolver | null
}

export class DIDCommResolversProxy {
  private static nativeEventEmitter?: NativeEventEmitter
  private static resolvers: Map<string, DIDCommResolvers> = new Map<string, DIDCommResolvers>()

  public static start(nativeEventEmitter: NativeEventEmitter) {
    this.nativeEventEmitter = nativeEventEmitter
    this.nativeEventEmitter.addListener(ResolverProxyEvent.ResolveDid, (event) =>
      this.resolveDid(event[DID_STRING_KEY], event[RESOLVERS_ID_STRING_KEY]),
    )
    this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKey, (event) =>
      this.findKey(event[KID_STRING_KEY], event[RESOLVERS_ID_STRING_KEY]),
    )
    this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKeys, (event) =>
      this.findKeys(event[KIDS_STRING_KEY], event[RESOLVERS_ID_STRING_KEY]),
    )
  }

  public static stop() {
    Object.values(ResolverProxyEvent).forEach((eventType) => {
      this.nativeEventEmitter?.removeAllListeners(eventType)
    })
  }

  public static async withResolvers(
    action: (resolversId: string) => Promise<any>,
    didDocResolver: DIDResolver | null,
    secretsResolver: SecretsResolver | null,
  ): Promise<any> {
    const resolversId = this.registerResolvers(didDocResolver, secretsResolver)
    return await action(resolversId).finally(() => this.unregisterResolvers(resolversId))
  }

  private static registerResolvers(didDocResolver: DIDResolver | null, secretsResolver: SecretsResolver | null) {
    const resolversId = uuid.v4() as string
    this.resolvers.set(resolversId, { didDocResolver, secretsResolver })
    console.log(`Resolvers registered: ${resolversId}`)
    return resolversId
  }

  private static unregisterResolvers(resolversId: string) {
    this.resolvers.delete(resolversId)
    console.log(`Resolvers unregistered: ${resolversId}`)
  }

  private static getResolvers(resolversId: string): DIDCommResolvers | undefined {
    return this.resolvers.get(resolversId)
  }

  private static async findKeys(kids: string[], resolversId: string) {
    const secretsResolver = this.getResolvers(resolversId)?.secretsResolver
    if (!secretsResolver) {
      console.log("Attempted to proxy 'findKeys' call, but secret resolver is not found. Sending empty result...")
      console.log(`Not found resolvers id: ${resolversId}`)
      DIDCommResolversProxyModule.setFoundSecretIds(null)
      return
    }

    const secretIds = await secretsResolver.find_secrets(kids)
    DIDCommResolversProxyModule.setFoundSecretIds(JSON.stringify(secretIds))
  }

  private static async findKey(kid: string, resolversId: string) {
    const secretsResolver = this.getResolvers(resolversId)?.secretsResolver
    if (!secretsResolver) {
      console.log("Attempted to proxy 'findKey' call, but secret resolver is not found. Sending empty result...")
      console.log(`Not found resolvers id: ${resolversId}`)
      DIDCommResolversProxyModule.setFoundSecret(null)
      return
    }

    const secret = await secretsResolver.get_secret(kid)
    DIDCommResolversProxyModule.setFoundSecret(JSON.stringify(secret))
  }

  private static async resolveDid(did: string, resolversId: string) {
    const didDocResolver = this.getResolvers(resolversId)?.didDocResolver
    if (!didDocResolver) {
      console.log("Attempted to proxy 'resolveDid' call, but DID doc resolver is not found. Sending empty result...")
      console.log(`Not found resolvers id: ${resolversId}`)
      DIDCommResolversProxyModule.setResolvedDid(null)
      return
    }

    const resolvedDid = await didDocResolver.resolve(did)
    DIDCommResolversProxyModule.setResolvedDid(JSON.stringify(resolvedDid))
  }
}
