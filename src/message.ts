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
    DIDCommResolversProxy.setResolvers(did_resolver, secrets_resolver)
    return await DIDCommMessageHelpersModule.packEncrypted(
      this.payload,
      to,
      from,
      sign_by,
      options?.protect_sender ?? true,
    )
  }

  public async pack_plaintext(did_resolver: DIDResolver): Promise<string> {
    DIDCommResolversProxy.setResolvers(did_resolver, null)
    return await DIDCommMessageHelpersModule.packPlaintext(this.payload)
  }

  public async pack_signed(
    sign_by: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
  ): Promise<[string, PackSignedMetadata]> {
    DIDCommResolversProxy.setResolvers(did_resolver, secrets_resolver)
    return await DIDCommMessageHelpersModule.packSigned(this.payload, sign_by)
  }

  public static async unpack(
    msg: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
    _options: UnpackOptions,
  ): Promise<[Message, UnpackMetadata]> {
    DIDCommResolversProxy.setResolvers(did_resolver, secrets_resolver)
    const [unpackedMsgData, unpackMetadata] = await DIDCommMessageHelpersModule.unpack(msg)
    return [new Message(unpackedMsgData), unpackMetadata]
  }

  public static async wrap_in_forward(
    msg: string,
    headers: Record<string, string>,
    to: string,
    routing_keys: Array<string>,
    enc_alg_anon: string,
    did_resolver: DIDResolver,
  ): Promise<string> {
    DIDCommResolversProxy.setResolvers(did_resolver, null)
    return await DIDCommMessageHelpersModule.wrapInForward(msg, headers, to, routing_keys, enc_alg_anon)
  }

  public try_parse_forward(): ParsedForward {
    throw new Error("'Message.try_parse_forward' is not implemented yet")
  }

  public free(): void {}
}
