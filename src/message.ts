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

import { NativeModules } from 'react-native'

import { ResolversProxy } from './resolvers-proxy'

const { DIDCommMessageHelpers } = NativeModules

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
    return await DIDCommMessageHelpers.pack_encrypted(this.payload, to, from, sign_by)
  }

  public pack_plaintext(did_resolver: DIDResolver): Promise<string> {
    throw new Error('Not implemented')
  }

  public pack_signed(
    sign_by: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver
  ): Promise<[string, PackSignedMetadata]> {
    throw new Error('Not implemented')
  }

  public static async unpack(
    msg: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
    _options: UnpackOptions
  ): Promise<[Message, UnpackMetadata]> {
    ResolversProxy.setResolvers(did_resolver, secrets_resolver)
    const [unpackedMsgData, unpackMetadata] = await DIDCommMessageHelpers.unpack(msg)
    return [new Message(unpackedMsgData), unpackMetadata]
  }

  public try_parse_forward(): ParsedForward {
    throw new Error('Not implemented')
  }
}
