extension DidDoc {
    
    init(fromJson json: JSONDictionary) {
        guard let did = json["did"] as? String else {
            fatalError("Cant resolve did")
        }
        
        guard let keyAgreements = json["key_agreements"] as? [String] else {
            fatalError("Cant resolve keyAgreements")
        }
        
        guard let authentications = json["authentications"] as? [String] else {
            fatalError("Cant resolve authentications")
        }
        
        
        guard let verificationMethodsJson = json["verification_methods"] as? [JSONDictionary] else {
            fatalError("Cant resolve verificationMethodsJson")
        }
        
        guard let servicesJson = json["services"] as? [JSONDictionary] else {
            fatalError("Cant resolve verificationMethodsJson")
        }
        
        self.did = did
        self.keyAgreements = keyAgreements
        self.authentications = authentications
        self.verificationMethods = verificationMethodsJson.map { verificationMethodJson in
            return .init(fromJson: verificationMethodJson)
        }
        
        self.services = servicesJson.map { serviceJson in
            return .init(fromJson: serviceJson)
        }

    }
}

extension VerificationMethod {
    init(fromJson json: JSONDictionary) {
        
        guard let id = json["id"] as? String else {
            fatalError("Cant resolve verification method: id")
        }

        guard let type = json["type"] as? String else {
            fatalError("Cant resolve verification method: type")
        }
        
        guard let controller = json["controller"] as? String else {
            fatalError("Cant resolve verification method: type")
        }
        
        guard let verificationMaterialJson = json["verification_material"] as? JSONDictionary else {
            fatalError("Cant resolve verification method: type")
        }
        
        guard let format =  verificationMaterialJson["format"] as? String else {
            fatalError("Cant resolve Verification Material: format")
        }
        
        guard let value =  verificationMaterialJson["value"] as? JSONDictionary else {
            fatalError("Cant resolve Verification Material: value")
        }
        
        self.id = id
        self.type = .fromString(type)
        self.controller = controller
        self.verificationMaterial = .fromString(format, jsonString: value.asString ?? "{}")

    }
}
