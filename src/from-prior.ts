import { DIDResolver, SecretsResolver, IFromPrior, DIDCommFromPrior } from "./types"

export class FromPrior implements DIDCommFromPrior {
  public constructor(private value: IFromPrior) {}

  public as_value(): IFromPrior {
    return this.value
  }

  public pack(
    issuer_kid: string | null,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
  ): Promise<[string, string]> {
    throw new Error("'FromPrior.pack' is not implemented yet")
  }

  public static unpack(from_prior: string, did_resolver: DIDResolver): Promise<[FromPrior, string]> {
    throw new Error("'FromPrior.unpack' is not implemented yet")
  }

  public free(): void {}
}
