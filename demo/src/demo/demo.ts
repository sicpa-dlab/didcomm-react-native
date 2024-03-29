//Source https://github.com/sicpa-dlab/didcomm-rust/blob/main/wasm/demo/src/main.ts
import {
  Message,
  DIDDoc,
  DIDResolver,
  Secret,
  SecretsResolver,
  FromPrior,
} from "@sicpa_open_source/didcomm-react-native"

import {
  ALICE_DID,
  ALICE_DID_DOC,
  ALICE_SECRETS,
  BOB_DID,
  BOB_DID_DOC,
  BOB_SECRETS,
  CHARLIE_DID,
  CHARLIE_DID_DOC,
  CHARLIE_SECRET_AUTH_KEY_ED25519,
  CHARLIE_SECRETS,
  FROM_PRIOR_FULL,
} from "./test-vectors"

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
  console.log("=================== NON REPUDIABLE ENCRYPTION ===================\n")
  await nonRepudiableEncryption()
  console.log("\n=================== MULTI RECIPIENT ===================\n")
  await multiRecipient()
  console.log("\n=================== REPUDIABLE AUTHENTICATED ENCRYPTION ===================\n")
  await repudiableAuthentcatedEncryption()
  console.log("\n=================== REPUDIABLE NON AUTHENTICATED ENCRYPTION ===================\n")
  await repudiableNonAuthentcatedEncryption()
  console.log("\n=================== SIGNED UNENCRYPTED ===================\n")
  await signedUnencrypted()
  console.log("\n=================== PLAINTEXT ===================\n")
  await plaintext()
  console.log("\n=================== WRAP IN FORWARD ===================\n")
  await wrapInForward()
  console.log("\n=================== FROM PRIOR PACK/UNPACK ===================")
  await fromPrior()
  console.log("\n=================== PARALLEL ENCRYPTION ===================")
  await parallelEncryption()
}

async function nonRepudiableEncryption() {
  // --- Building message from ALICE to BOB ---
  const msg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: "did:example:alice",
    to: ["did:example:bob"],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
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
    },
  )

  console.log("Encryption metadata is\n", encryptMetadata)

  // --- Sending message ---
  console.log("Sending message\n", encryptedMsg)

  // --- Unpacking message ---
  didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

  const [unpackedMsg, unpackMetadata] = await Message.unpack(encryptedMsg, didResolver, secretsResolver, {})

  console.log(unpackedMsg, unpackMetadata)

  console.log("Received message is\n", unpackedMsg.as_value())
  console.log("Received message unpack metadata is\n", unpackMetadata)
}

async function multiRecipient() {
  // --- Building message from ALICE to BOB and Charlie ---
  const msg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: "did:example:alice",
    to: ["did:example:bob", "did:example:charlie"],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
  })

  let didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC, CHARLIE_DID_DOC])
  let secretsResolver = new ExampleSecretsResolver(ALICE_SECRETS)

  // --- Packing encrypted and authenticated message for Bob ---
  const [encryptedMsgBob, encryptMetadataBob] = await msg.pack_encrypted(
    BOB_DID,
    ALICE_DID,
    null,
    didResolver,
    secretsResolver,
    {
      forward: false, // TODO: should be true by default
    },
  )

  console.log("Encryption metadata for Bob is\n", encryptMetadataBob)

  // --- Sending message ---
  console.log("Sending message to Bob\n", encryptedMsgBob)

  // --- Packing encrypted and authenticated message for Charlie ---
  const [encryptedMsgCharlie, encryptMetadataCharlie] = await msg.pack_encrypted(
    CHARLIE_DID,
    ALICE_DID,
    null,
    didResolver,
    secretsResolver,
    {
      forward: false, // TODO: should be true by default
    },
  )

  console.log("Encryption metadata for Charle is\n", encryptMetadataCharlie)

  // --- Sending message ---
  console.log("Sending message to Charle\n", encryptedMsgCharlie)

  // --- Unpacking message for Bob ---
  didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

  const [unpackedMsgBob, unpackMetadataBob] = await Message.unpack(encryptedMsgBob, didResolver, secretsResolver, {})

  console.log("Received message for Bob is\n", unpackedMsgBob.as_value())
  console.log("Received message unpack metadata for Bob is\n", unpackMetadataBob)

  // --- Unpacking message for Charlie ---
  didResolver = new ExampleDIDResolver([ALICE_DID_DOC, CHARLIE_DID_DOC])
  secretsResolver = new ExampleSecretsResolver(CHARLIE_SECRETS)

  const [unpackedMsgCharlie, unpackMetadataCharlie] = await Message.unpack(
    encryptedMsgCharlie,
    didResolver,
    secretsResolver,
    {},
  )

  console.log("Received message for Charlie is\n", unpackedMsgCharlie.as_value())
  console.log("Received message unpack metadata for Charlie is\n", unpackMetadataCharlie)
}

async function repudiableAuthentcatedEncryption() {
  // --- Building message from ALICE to BOB ---
  const msg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: "did:example:alice",
    to: ["did:example:bob"],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
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
    },
  )

  console.log("Encryption metadata is\n", encryptMetadata)

  // --- Sending message ---
  console.log("Sending message\n", encryptedMsg)

  // --- Unpacking message ---
  didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

  const [unpackedMsg, unpackMetadata] = await Message.unpack(encryptedMsg, didResolver, secretsResolver, {})

  console.log("Received message is\n", unpackedMsg.as_value())
  console.log("Received message unpack metadata is\n", unpackMetadata)
}

async function repudiableNonAuthentcatedEncryption() {
  // --- Building message from ALICE to BOB ---
  const msg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: "did:example:alice",
    to: ["did:example:bob"],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
  })

  // --- Packing encrypted and authenticated message ---
  let didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  let secretsResolver = new ExampleSecretsResolver(ALICE_SECRETS)

  const [encryptedMsg, encryptMetadata] = await msg.pack_encrypted(BOB_DID, null, null, didResolver, secretsResolver, {
    forward: false, // TODO: should be true by default
  })

  console.log("Encryption metadata is\n", encryptMetadata)

  // --- Sending message ---
  console.log("Sending message\n", encryptedMsg)

  // --- Unpacking message ---
  didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

  const [unpackedMsg, unpackMetadata] = await Message.unpack(encryptedMsg, didResolver, secretsResolver, {})

  console.log("Received message is\n", unpackedMsg.as_value())
  console.log("Received message unpack metadata is\n", unpackMetadata)
}

async function signedUnencrypted() {
  // --- Building message from ALICE to BOB ---
  const msg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: "did:example:alice",
    to: ["did:example:bob"],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
  })

  // --- Packing encrypted and authenticated message ---
  let didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  let secretsResolver = new ExampleSecretsResolver(ALICE_SECRETS)

  const [signedMsg, signMetadata] = await msg.pack_signed(ALICE_DID, didResolver, secretsResolver)

  console.log("Encryption metadata is\n", signMetadata)

  // --- Sending message ---
  console.log("Sending message\n", signedMsg)

  // --- Unpacking message ---
  didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

  const [unpackedMsg, unpackMetadata] = await Message.unpack(signedMsg, didResolver, secretsResolver, {})

  console.log("Received message is\n", unpackedMsg.as_value())
  console.log("Received message unpack metadata is\n", unpackMetadata)
}

async function plaintext() {
  // --- Building message from ALICE to BOB ---
  const msg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: "did:example:alice",
    to: ["did:example:bob"],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
  })

  // --- Packing encrypted and authenticated message ---
  let didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])

  const plaintextMsg = await msg.pack_plaintext(didResolver)

  // --- Sending message ---
  console.log("Sending message\n", plaintextMsg)

  // --- Unpacking message ---
  didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC])
  const secretsResolver = new ExampleSecretsResolver(BOB_SECRETS)

  const [unpackedMsg, unpackMetadata] = await Message.unpack(plaintextMsg, didResolver, secretsResolver, {})

  console.log("Received message is\n", unpackedMsg.as_value())
  console.log("Received message unpack metadata is\n", unpackMetadata)
}

async function wrapInForward() {
  const msg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: "did:example:bob",
    to: ["did:example:alice"],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
  })

  const wrapResult = await Message.wrap_in_forward(
    JSON.stringify(msg),
    {
      header1: '{"messagespecificattribute": "and its value"}',
      header2: '{"messagespecificattribute": "and its value"}',
    },
    ALICE_DID,
    ["did:example:bob#key-x25519-1"],
    "A256cbcHs512EcdhEsA256kw",
    new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC]),
  )

  console.log("Wrap in forward result\n", wrapResult)
}

async function fromPrior() {
  const fromPrior = FROM_PRIOR_FULL

  console.log("Initial FromPrior content\n", fromPrior)

  const didResolver = new ExampleDIDResolver([ALICE_DID_DOC, CHARLIE_DID_DOC])
  const secretsResolver = new ExampleSecretsResolver(CHARLIE_SECRETS)

  const [packed, kid] = await fromPrior.pack(CHARLIE_SECRET_AUTH_KEY_ED25519.id, didResolver, secretsResolver)

  console.log("Packed FromPrior content\n", packed)
  console.log("Packed FromPrior kid\n", kid)

  const [unpacked, _] = await FromPrior.unpack(packed, didResolver)

  console.log("Unpacked FromPrior content\n", unpacked)
}

export async function parallelEncryption() {
  const bobMsg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: ALICE_DID,
    to: [BOB_DID],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
  })

  const charlieMsg = new Message({
    id: "1234567890",
    typ: "application/didcomm-plain+json",
    type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
    from: ALICE_DID,
    to: [CHARLIE_DID],
    created_time: 1516269022,
    expires_time: 1516385931,
    body: { messagespecificattribute: "and its value" },
  })

  const didResolver = new ExampleDIDResolver([ALICE_DID_DOC, BOB_DID_DOC, CHARLIE_DID_DOC])

  await Promise.all([
    encryptMessage(bobMsg, BOB_DID_DOC, ALICE_DID_DOC, BOB_SECRETS, ALICE_SECRETS, didResolver),
    encryptMessage(charlieMsg, CHARLIE_DID_DOC, ALICE_DID_DOC, CHARLIE_SECRETS, ALICE_SECRETS, didResolver),
  ])
}

async function encryptMessage(
  message: Message,
  toDIDDoc: DIDDoc,
  fromDIDDoc: DIDDoc,
  recipientKeys: Secret[],
  senderKeys: Secret[],
  didResolver: ExampleDIDResolver,
) {
  const secretsResolver = new ExampleSecretsResolver(senderKeys)

  const [encryptedMsg, metadata] = await message.pack_encrypted(
    toDIDDoc.did,
    fromDIDDoc.did,
    null,
    didResolver,
    secretsResolver,
    {},
  )
  if (recipientKeys.every((it) => !(metadata as any).toKids.includes(it.id)))
    throw new Error(`Message was encrypted with wrong KIDs`)

  console.log("Pack encrypted metadata:")
  console.log(metadata)

  console.log("Encrypted message:")
  console.log(encryptedMsg)
}
