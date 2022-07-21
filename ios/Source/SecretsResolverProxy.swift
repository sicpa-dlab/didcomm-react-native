public class SecretsResolverProxy: SecretsResolver {
    public func getSecret(secretid: String, cb: OnGetSecretResult) -> ErrorCode {
        return .success
    }
    
    public func findSecrets(secretids: [String], cb: OnFindSecretsResult) -> ErrorCode {
        return .success
    }
}
