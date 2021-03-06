import DidcommSDK

extension DidDoc {
    
    init(fromJson json: JSONDictionary) {
        guard let did = json["did"] as? String else {
            fatalError("Can't resolve 'did' from DidDoc.")
        }
        
        guard let keyAgreements = json["key_agreements"] as? [String] else {
            fatalError("Can't resolve 'key_agreements' from DidDoc.")
        }
        
        guard let authentications = json["authentications"] as? [String] else {
            fatalError("Can't resolve 'authentications' from DidDoc.")
        }
        
        
        guard let verificationMethodsJson = json["verification_methods"] as? [JSONDictionary] else {
            fatalError("Can't resolve 'verification_methods' from DidDoc.")
        }
        
        guard let servicesJson = json["services"] as? [JSONDictionary] else {
            fatalError("Can't resolve 'services' from DidDoc.")
        }
        
        let vMethods: [VerificationMethod] = verificationMethodsJson.map { verificationMethodJson in
            return .init(fromJson: verificationMethodJson)
        }
        
        let services: [Service] = servicesJson.map { serviceJson in
            return .init(fromJson: serviceJson)
        }
        
        self.init(did: did,
                  keyAgreements: keyAgreements,
                  authentications: authentications,
                  verificationMethods: vMethods,
                  services: services)
    }
}

extension VerificationMethod {
    init(fromJson json: JSONDictionary) {
        
        guard let id = json["id"] as? String else {
            fatalError("Can't resolve 'id' from VerificationMethod.")
        }

        guard let type = json["type"] as? String else {
            fatalError("Can't resolve 'type' from VerificationMethod.")
        }
        
        guard let controller = json["controller"] as? String else {
            fatalError("Can't resolve 'controller' from VerificationMethod.")
        }
        
        guard let verificationMaterialJson = json["verification_material"] as? JSONDictionary else {
            fatalError("Can't resolve 'verification_material' from VerificationMethod.")
        }
        
        guard let format =  verificationMaterialJson["format"] as? String else {
            fatalError("Can't resolve 'format' from Verification Material.")
        }
        
        guard let value =  verificationMaterialJson["value"] as? JSONDictionary else {
            fatalError("Can't resolve 'value' from Verification Material.")
        }
        
        self.init(id: id,
                  type: .fromString(type),
                  controller: controller,
                  verificationMaterial: .fromString(format, jsonString: value.asString ?? "{}"))
    }
}
