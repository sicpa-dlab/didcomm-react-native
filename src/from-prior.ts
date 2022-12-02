import { NativeModules } from "react-native"

import { DIDCommResolversProxy } from "./resolvers-proxy"
import { DIDResolver, SecretsResolver, IFromPrior, DIDCommFromPrior } from "./types"

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
    return await DIDCommResolversProxy.withResolvers(
      (resolversId) => DIDCommFromPriorHelpersModule.pack(this.value, issuer_kid, resolversId),
      did_resolver,
      secrets_resolver,
    )
  }

  public static async unpack(from_prior: string, did_resolver: DIDResolver): Promise<[FromPrior, string]> {
    return await DIDCommResolversProxy.withResolvers(
      async (resolversId) => {
        const [unpackedFromPriorData, issuerKid] = await DIDCommFromPriorHelpersModule.unpack(from_prior, resolversId)
        return [new FromPrior(unpackedFromPriorData), issuerKid]
      },
      did_resolver,
      null,
    )
  }

  public free(): void {}
}
