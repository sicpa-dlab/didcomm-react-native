import Foundation

@objc(DIDCommResolversProxyModule)
class DIDCommResolversProxyModule: NSObject {
    
    @objc(setResolvedDid:resolversId:)
    func setResolvedDid(_ jsonValue: NSString?, resolversId: String) {
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"did"), object: jsonValue)
    }
    @objc(setFoundSecret:resolversId:)
    func setFoundSecret(_ jsonValue: NSString?, resolversId: String) {
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"kid"), object: jsonValue)
    }

    @objc(setFoundSecretIds:resolversId:)
    func setFoundSecretIds(_ jsonValue: NSString?, resolversId: String) {
        NotificationCenter.default.post(name: NSNotification.Name(resolversId+"kids"), object: jsonValue)
    }
}
