import { NativeModules } from 'react-native'
import {
  DIDResolver,
  IMessage,
  Message as DIDCommMessage,
  PackEncryptedMetadata,
  PackEncryptedOptions,
  PackSignedMetadata,
  ParsedForward,
  SecretsResolver,
  UnpackMetadata,
  UnpackOptions,
} from 'didcomm'

const { DIDCommMessageHelpers } = NativeModules

export class Message implements Omit<DIDCommMessage, "free"> {
  constructor(private _payload: IMessage) {}

  as_value(): IMessage {
    return this._payload
  }

  pack_encrypted(
    to: string,
    from: string | null,
    sign_by: string | null,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
    options: PackEncryptedOptions
  ): Promise<[string, PackEncryptedMetadata]> {
    return DIDCommMessageHelpers.pack_encrypted(
      this._payload,
      to,
      from,
      sign_by,
      options.protect_sender,
      did_resolver,
      secrets_resolver
    )
  }

  pack_plaintext(did_resolver: DIDResolver): Promise<string> {
    throw new Error("Not implemented")
  }

  pack_signed(
    sign_by: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver
  ): Promise<[string, PackSignedMetadata]> {
    throw new Error("Not implemented")
  }

  static unpack(
    msg: string,
    did_resolver: DIDResolver,
    secrets_resolver: SecretsResolver,
    _options: UnpackOptions
  ): Promise<[Message, UnpackMetadata]> {
    return DIDCommMessageHelpers.unpack(msg, did_resolver, secrets_resolver)
  }

  try_parse_forward(): ParsedForward {
    throw new Error("Not implemented")
  }
}
