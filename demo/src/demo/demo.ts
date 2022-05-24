//Source https://github.com/sicpa-dlab/didcomm-rust/blob/main/wasm/demo/src/main.ts
import { Message, DIDDoc, DIDResolver, Secret, SecretsResolver } from '@sicpa-dlab/didcomm-react-native'

import { ALICE_DID, ALICE_DID_DOC, ALICE_SECRETS, BOB_DID, BOB_DID_DOC, BOB_SECRETS } from './test-vectors'


class ExampleDIDResolver implements DIDResolver {
    private knownDids: DIDDoc[]

    public constructor(knownDids: DIDDoc[]) {
        this.knownDids = knownDids
    }

    public async resolve(did: string): Promise<DIDDoc | null> {
        return this.knownDids.find((ddoc) => ddoc.did === did) || null
    }
}

class ExampleSecretsResolver implements SecretsResolver {
    private knownSecrets: Secret[]

    public constructor(knownSecrets: Secret[]) {
        this.knownSecrets = knownSecrets
    }

    public async get_secret(secretId: string): Promise<Secret | null> {
        return this.knownSecrets.find((secret) => secret.id === secretId) || null
    }

    public async find_secrets(secretIds: string[]): Promise<string[]> {
        return secretIds.filter((id) => this.knownSecrets.find((secret) => secret.id === id))
    }
}

export async function runDemo() {
    console.log('=================== NON REPUDIABLE ENCRYPTION ===================\n')
    await nonRepudiableEncryption()
    //console.log('\n=================== MULTI RECIPIENT ===================\n')
    //await multiRecipient()
    console.log('\n=================== REPUDIABLE AUTHENTICATED ENCRYPTION ===================\n')
    await repudiableAuthentcatedEncryption()
    console.log('\n=================== REPUDIABLE NON AUTHENTICATED ENCRYPTION ===================\n')
    await repudiableNonAuthentcatedEncryption()
    // console.log('\n=================== SIGNED UNENCRYPTED ===================\n')
    // await signedUnencrypteed()
    // console.log('\n=================== PLAINTEXT ===================')
    // await plaintext()
}

async function nonRepudiableEncryption() {
    // --- Building message from ALICE to BOB ---
    const msg = new Message({
        id: '1234567890',
        typ: 'application/didcomm-plain+json',
        type: 'http://example.com/protocols/lets_do_lunch/1.0/proposal',
        from: 'did:example:alice',
        to: ['did:example:bob'],
        created_time: 1516269022,
        expires_time: 1516385931,
        body: { messagespecificattribute: 'and its value' },
    })

    // --- Packing encrypted and authenticated message ---
    let didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
    let secretsResolver = new ExampleSecretsResolver(ALICE_SECRETS)

    const [encryptedMsg, encryptMetadata] = await msg.pack_encrypted(
        BOB_DID,
        ALICE_DID,
        ALICE_DID,
        didResolver,
        secretsResolver,
        {
            forward: false, // TODO: should be true by default
        }
    )

    console.log('Encryption metadata is\n', encryptMetadata)

    // --- Sending message ---
    console.log('Sending message\n', encryptedMsg)

    // --- Unpacking message ---
    didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
    secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

    const [unpackedMsg, unpackMetadata] = await Message.unpack(encryptedMsg, didResolver, secretsResolver, {})

    console.log(unpackedMsg, unpackMetadata)

    console.log('Received message is\n', unpackedMsg.as_value())
    console.log('Received message unpack metadata is\n', unpackMetadata)
}

async function repudiableAuthentcatedEncryption() {
    // --- Building message from ALICE to BOB ---
    const msg = new Message({
        id: '1234567890',
        typ: 'application/didcomm-plain+json',
        type: 'http://example.com/protocols/lets_do_lunch/1.0/proposal',
        from: 'did:example:alice',
        to: ['did:example:bob'],
        created_time: 1516269022,
        expires_time: 1516385931,
        body: { messagespecificattribute: 'and its value' },
    })

    // --- Packing encrypted and authenticated message ---
    let didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
    let secretsResolver = new ExampleSecretsResolver(ALICE_SECRETS)

    const [encryptedMsg, encryptMetadata] = await msg.pack_encrypted(
        BOB_DID,
        ALICE_DID,
        null,
        didResolver,
        secretsResolver,
        {
            forward: false, // TODO: should be true by default
        }
    )

    console.log('Encryption metadata is\n', encryptMetadata)

    // --- Sending message ---
    console.log('Sending message\n', encryptedMsg)

    // --- Unpacking message ---
    didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
    secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

    const [unpackedMsg, unpackMetadata] = await Message.unpack(encryptedMsg, didResolver, secretsResolver, {})

    console.log('Received message is\n', unpackedMsg.as_value())
    console.log('Received message unpack metadata is\n', unpackMetadata)
}

async function repudiableNonAuthentcatedEncryption() {
    // --- Building message from ALICE to BOB ---
    const msg = new Message({
        id: '1234567890',
        typ: 'application/didcomm-plain+json',
        type: 'http://example.com/protocols/lets_do_lunch/1.0/proposal',
        from: 'did:example:alice',
        to: ['did:example:bob'],
        created_time: 1516269022,
        expires_time: 1516385931,
        body: { messagespecificattribute: 'and its value' },
    })

    // --- Packing encrypted and authenticated message ---
    let didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
    let secretsResolver = new ExampleSecretsResolver(ALICE_SECRETS)

    const [encryptedMsg, encryptMetadata] = await msg.pack_encrypted(BOB_DID, null, null, didResolver, secretsResolver, {
        forward: false, // TODO: should be true by default
    })

    console.log('Encryption metadata is\n', encryptMetadata)

    // --- Sending message ---
    console.log('Sending message\n', encryptedMsg)

    // --- Unpacking message ---
    didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
    secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

    const [unpackedMsg, unpackMetadata] = await Message.unpack(encryptedMsg, didResolver, secretsResolver, {})

    console.log('Received message is\n', unpackedMsg.as_value())
    console.log('Received message unpack metadata is\n', unpackMetadata)
}
