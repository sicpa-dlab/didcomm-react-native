import { NativeModules } from "react-native"

import { ParsedForward } from "./parsed-forward"
import { DIDCommResolversProxy } from "./resolvers-proxy"
import {
  DIDResolver,
  IMessage,
  DIDCommMessage,
  PackEncryptedMetadata,
  PackEncryptedOptions,
  PackSignedMetadata,
  SecretsResolver,
  UnpackMetadata,
  UnpackOptions,
} from "./types"

const { DIDCommMessageHelpersModule } = NativeModules

export class Message implements DIDCommMessage {
  public constructor(private payload: IMessage) {}

  public as_value(): IMessage {
    return this.payload
  }

  public async pack_encrypted(
    to: string,
    from: string | null,
    sign_by: string | null,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
    options: PackEncryptedOptions,
  ): Promise<[string, PackEncryptedMetadata]> {
    return await DIDCommResolversProxy.withResolvers(
      (resolversId) =>
        DIDCommMessageHelpersModule.packEncrypted(
          this.payload,
          to,
          from,
          sign_by,
          options?.protect_sender ?? true,
            resolversId,
        ),
      did_resolver,
      secrets_resolver,
    )
  }

  public async pack_plaintext(did_resolver: DIDResolver): Promise<string> {
    return await DIDCommResolversProxy.withResolvers(
      (resolversId) => DIDCommMessageHelpersModule.packPlaintext(this.payload, resolversId),
      did_resolver,
      null,
    )
  }

  public async pack_signed(
    sign_by: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
  ): Promise<[string, PackSignedMetadata]> {
    return await DIDCommResolversProxy.withResolvers(
      (resolversId) => DIDCommMessageHelpersModule.packSigned(this.payload, sign_by, resolversId),
      did_resolver,
      secrets_resolver,
    )
  }

  public static async unpack(
    msg: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
    _options: UnpackOptions,
  ): Promise<[Message, UnpackMetadata]> {
    return await DIDCommResolversProxy.withResolvers(
      async (resolversId) => {
        const [unpackedMsgData, unpackMetadata] = await DIDCommMessageHelpersModule.unpack(msg, resolversId)
        return [new Message(unpackedMsgData), unpackMetadata]
      },
      did_resolver,
      secrets_resolver,
    )
  }

  public static async wrap_in_forward(
    msg: string,
    headers: Record<string, string>,
    to: string,
    routing_keys: Array<string>,
    enc_alg_anon: string,
    did_resolver: DIDResolver,
  ): Promise<string> {
    return await DIDCommResolversProxy.withResolvers(
      (resolversId) => DIDCommMessageHelpersModule.wrapInForward(msg, headers, to, routing_keys, enc_alg_anon, resolversId),
      did_resolver,
      null,
    )
  }

  public try_parse_forward(): ParsedForward {
    throw new Error("'Message.try_parse_forward' is not implemented yet")
  }

  public free(): void {}
}
