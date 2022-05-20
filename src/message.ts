
import { NativeModules } from 'react-native'

import { ResolversProxy } from './resolvers-proxy'
import {
  DIDResolver,
  IMessage,
  DIDCommMessage,
  PackEncryptedMetadata,
  PackEncryptedOptions,
  PackSignedMetadata,
  ParsedForward,
  SecretsResolver,
  UnpackMetadata,
  UnpackOptions,
} from './types'

const { DIDCommMessageHelpersModule } = NativeModules

export class Message implements Omit<DIDCommMessage, 'free'> {
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
    options: PackEncryptedOptions
  ): Promise<[string, PackEncryptedMetadata]> {
    ResolversProxy.setResolvers(did_resolver, secrets_resolver)
    return await DIDCommMessageHelpersModule.pack_encrypted(this.payload, to, from, sign_by, options?.protect_sender ?? true)
  }

  public pack_plaintext(did_resolver: DIDResolver): Promise<string> {
    throw new Error("'Message.pack_plaintext' is not implemented yet")
  }

  public pack_signed(
    sign_by: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver
  ): Promise<[string, PackSignedMetadata]> {
    throw new Error("'Message.pack_signed' is not implemented yet")
  }

  public static async unpack(
    msg: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
    _options: UnpackOptions
  ): Promise<[Message, UnpackMetadata]> {
    ResolversProxy.setResolvers(did_resolver, secrets_resolver)
    const [unpackedMsgData, unpackMetadata] = await DIDCommMessageHelpersModule.unpack(msg)
    return [new Message(unpackedMsgData), unpackMetadata]
  }

  public try_parse_forward(): ParsedForward {
    throw new Error("'Message.try_parse_forward' is not implemented yet")
  }
}
