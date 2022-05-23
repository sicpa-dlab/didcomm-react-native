"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Message = void 0;
const react_native_1 = require("react-native");
const resolvers_proxy_1 = require("./resolvers-proxy");
const { DIDCommMessageHelpersModule } = react_native_1.NativeModules;
class Message {
    payload;
    constructor(payload) {
        this.payload = payload;
    }
    as_value() {
        return this.payload;
    }
    async pack_encrypted(to, from, sign_by, did_resolver, secrets_resolver, options) {
        resolvers_proxy_1.DIDCommResolversProxy.setResolvers(did_resolver, secrets_resolver);
        return await DIDCommMessageHelpersModule.pack_encrypted(this.payload, to, from, sign_by, options?.protect_sender ?? true);
    }
    pack_plaintext(did_resolver) {
        throw new Error("'Message.pack_plaintext' is not implemented yet");
    }
    pack_signed(sign_by, did_resolver, secrets_resolver) {
        throw new Error("'Message.pack_signed' is not implemented yet");
    }
    static async unpack(msg, did_resolver, secrets_resolver, _options) {
        resolvers_proxy_1.DIDCommResolversProxy.setResolvers(did_resolver, secrets_resolver);
        const [unpackedMsgData, unpackMetadata] = await DIDCommMessageHelpersModule.unpack(msg);
        return [new Message(unpackedMsgData), unpackMetadata];
    }
    try_parse_forward() {
        throw new Error("'Message.try_parse_forward' is not implemented yet");
    }
}
exports.Message = Message;
