import { DIDResolver, IMessage, DIDCommMessage, PackEncryptedMetadata, PackEncryptedOptions, PackSignedMetadata, ParsedForward, SecretsResolver, UnpackMetadata, UnpackOptions } from './types';
export declare class Message implements Omit<DIDCommMessage, 'free'> {
    private payload;
    constructor(payload: IMessage);
    as_value(): IMessage;
    pack_encrypted(to: string, from: string | null, sign_by: string | null, did_resolver: DIDResolver, secrets_resolver: SecretsResolver, options: PackEncryptedOptions): Promise<[string, PackEncryptedMetadata]>;
    pack_plaintext(did_resolver: DIDResolver): Promise<string>;
    pack_signed(sign_by: string, did_resolver: DIDResolver, secrets_resolver: SecretsResolver): Promise<[string, PackSignedMetadata]>;
    static unpack(msg: string, did_resolver: DIDResolver, secrets_resolver: SecretsResolver, _options: UnpackOptions): Promise<[Message, UnpackMetadata]>;
    try_parse_forward(): ParsedForward;
}
