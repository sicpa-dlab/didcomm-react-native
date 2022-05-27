import { DIDResolver, SecretsResolver, IFromPrior, DIDCommFromPrior } from "./types"
import { NativeModules } from "react-native"
import { DIDCommResolversProxy } from "./resolvers-proxy"

const { DIDCommFromPriorHelpersModule } = NativeModules

export class FromPrior implements DIDCommFromPrior {
  public constructor(private value: IFromPrior) {}

  public as_value(): IFromPrior {
    return this.value
  }

  public async pack(
    issuer_kid: string | null,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
  ): Promise<[string, string]> {
    DIDCommResolversProxy.setResolvers(did_resolver, secrets_resolver)
    return await DIDCommFromPriorHelpersModule.pack(this.value, issuer_kid)
  }

  public static async unpack(from_prior: string, did_resolver: DIDResolver): Promise<[FromPrior, string]> {
    DIDCommResolversProxy.setResolvers(did_resolver, null)
    const [unpackedFromPriorData, issuerKid] = await DIDCommFromPriorHelpersModule.unpack(from_prior)
    return [new FromPrior(unpackedFromPriorData), issuerKid]
  }

  public free(): void {}
}
