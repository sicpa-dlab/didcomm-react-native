"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DIDCommResolversProxy = void 0;
const react_native_1 = require("react-native");
const { DIDCommResolversProxyModule } = react_native_1.NativeModules;
const { DID_STRING_KEY, KID_STRING_KEY, KIDS_STRING_KEY } = DIDCommResolversProxyModule.getConstants();
var ResolverProxyEvent;
(function (ResolverProxyEvent) {
    ResolverProxyEvent["ResolveDid"] = "resolve-did";
    ResolverProxyEvent["FindKey"] = "find-key";
    ResolverProxyEvent["FindKeys"] = "find-keys";
})(ResolverProxyEvent || (ResolverProxyEvent = {}));
class DIDCommResolversProxy {
    static nativeEventEmitter;
    static didDocResolver = null;
    static secretsResolver = null;
    static setResolvers(didDocResolver, secretsResolver) {
        this.didDocResolver = didDocResolver;
        this.secretsResolver = secretsResolver;
    }
    static start(nativeEventEmitter) {
        this.nativeEventEmitter = new react_native_1.NativeEventEmitter(DIDCommResolversProxyModule);
        this.nativeEventEmitter.addListener(ResolverProxyEvent.ResolveDid, (event) => this.resolveDid(event[DID_STRING_KEY]));
        this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKey, (event) => this.findKey(event[KID_STRING_KEY]));
        this.nativeEventEmitter.addListener(ResolverProxyEvent.FindKeys, (event) => this.findKeys(event[KIDS_STRING_KEY]));
    }
    static stop() {
        Object.values(ResolverProxyEvent).forEach((eventType) => {
            this.nativeEventEmitter?.removeAllListeners(eventType);
        });
    }
    static async findKeys(kids) {
        if (!this.secretsResolver) {
            console.log("Attempted to proxy 'findKeys' call, but secret resolver is not defined. Skipping...");
            return;
        }
        const secretIds = await this.secretsResolver.find_secrets(kids);
        DIDCommResolversProxyModule.setFoundSecretIds(JSON.stringify(secretIds));
    }
    static async findKey(kid) {
        if (!this.secretsResolver) {
            console.log("Attempted to proxy 'findKey' call, but secret resolver is not defined. Skipping...");
            return;
        }
        const secret = await this.secretsResolver.get_secret(kid);
        DIDCommResolversProxyModule.setFoundSecret(JSON.stringify(secret));
    }
    static async resolveDid(did) {
        if (!this.didDocResolver) {
            console.log("Attempted to proxy 'resolveDid' call, but DID doc resolver is not defined. Skipping...");
            return;
        }
        const resolvedDid = await this.didDocResolver.resolve(did);
        DIDCommResolversProxyModule.setResolvedDid(JSON.stringify(resolvedDid));
    }
}
exports.DIDCommResolversProxy = DIDCommResolversProxy;
