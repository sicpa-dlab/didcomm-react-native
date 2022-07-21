import Foundation

typealias JSONDictionary = [String : Any]

//TODO
func parseMessage(msg: NSDictionary) -> Message {
    
    // Do some extra logic here
    guard let id = msg.value(forKey: "id") as? String else {
        fatalError("Cant resolve id")
    }
    
    guard let typ = msg.value(forKey: "typ") as? String else {
        fatalError("Cant resolve typ")
    }
    
    guard let type = msg.value(forKey: "type") as? String else {
        fatalError("Cant resolve type")
    }
    
    //body: "{\"messagespecificattribute\": \"and its value\"}",
    guard let body = msg.value(forKey: "body") as? NSDictionary else {
        fatalError("Cant resolve body")
    }

    let from = msg.value(forKey: "from") as? String
    let to = msg.value(forKey: "to") as? [String]
    let thid = msg.value(forKey: "thid") as? String
    let pthid = msg.value(forKey: "pthid")  as? String
    let extraHeaders = msg.value(forKey: "extraHeaders") as? [String: String] ?? [:]
    let createdTime = msg.value(forKey: "createdTime") as? UInt64
    let expiresTime = msg.value(forKey: "expiresTime") as? UInt64
    let fromPrior = msg.value(forKey: "fromPrior") as? String
    //parse again
    let attachments = msg.value(forKey: "attachments") as? [Attachment]
   
    return Message(id: id,
                   typ: typ,
                   type: type,
                   body: "{\"messagespecificattribute\": \"and its value\"}",
                   from: from,
                   to: to,
                   thid: thid,
                   pthid: pthid,
                   extraHeaders: extraHeaders,
                   createdTime: createdTime,
                   expiresTime: expiresTime,
                   fromPrior: fromPrior,
                   attachments: attachments)
    
    /*
    return Message(id: "1234567890",
                   typ: "application/didcomm-plain+json",
                   type: "http://example.com/protocols/lets_do_lunch/1.0/proposal",
                   body: "{\"messagespecificattribute\": \"and its value\"}",
                   from: "did:example:alice",
                   to: ["did:example:bob"],
                   thid: nil,
                   pthid: nil,
                   extraHeaders: [:],
                   createdTime: 1516269022,
                   expiresTime: 1516385931,
                   fromPrior: nil,
                   attachments: nil)
    */
}

func parseDidDoc(json: [String: Any?]) -> DidDoc {
    
    guard let did = json["did"] as? String else {
        fatalError("Cant resolve did")
    }
    
    guard let keyAgreements = json["key_agreements"] as? [String] else {
        fatalError("Cant resolve keyAgreements")
    }
    
    guard let authentications = json["authentications"] as? [String] else {
        fatalError("Cant resolve authentications")
    }
    
    
    guard let verificationMethodsJson = json["verification_methods"] as? [NSDictionary] else {
        fatalError("Cant resolve verificationMethodsJson")
    }
    
    guard let servicesJson = json["services"] as? [NSDictionary] else {
        fatalError("Cant resolve verificationMethodsJson")
    }
    
    
    let verificationMethods = parseVerificationMethods(json: verificationMethodsJson)
    let services = parseServices(servicesJson)
    
    return DidDoc(did: did,
                  keyAgreements: keyAgreements,
                  authentications: authentications,
                  verificationMethods: verificationMethods,
                  services: services)
    
}

func parseVerificationMethods(json: [NSDictionary]) ->  [VerificationMethod] {
    var verificationMethods: [VerificationMethod] = []
    for vObj in json {
        
        guard let id = vObj.value(forKey: "id") as? String else {
            fatalError("Cant resolve verification method: id")
        }

        guard let type = vObj.value(forKey: "type") as? String else {
            fatalError("Cant resolve verification method: type")
        }
        
        guard let controller = vObj.value(forKey: "controller") as? String else {
            fatalError("Cant resolve verification method: type")
        }
        
        guard let verificationMaterialJson = vObj.value(forKey: "verification_material") as? NSDictionary else {
            fatalError("Cant resolve verification method: type")
        }
        
        let verificationMaterial = parseVerificationMaterial(verificationMaterialJson)
        
        verificationMethods.append(.init(id: id,
                                         type: parseVerificationMethodType(type),
                                         controller: controller,
                                         verificationMaterial: verificationMaterial))
        
    }
    return verificationMethods
}

func parseVerificationMethodType(_ type: String) -> VerificationMethodType {
    
    switch type {
    case "jsonWebKey2020":
        return .jsonWebKey2020
    case "x25519KeyAgreementKey2019":
        return .x25519KeyAgreementKey2019
    case "ed25519VerificationKey2018":
        return .ed25519VerificationKey2018
    case "ecdsaSecp256k1VerificationKey2019":
        return .ecdsaSecp256k1VerificationKey2019
    case "x25519KeyAgreementKey2020":
        return .x25519KeyAgreementKey2020
    case "ed25519VerificationKey2020":
        return .ed25519VerificationKey2020
    default:
        return .other
    }
}

func parseVerificationMaterial(_ json: NSDictionary) -> VerificationMaterial {
    
    guard let format = json.value(forKey: "format") as? String else {
        fatalError("Cant resolve Verification Material: format")
    }
    
    guard let value = json.value(forKey: "value") as? JSONDictionary else {
        fatalError("Cant resolve Verification Material: value")
    }
    
    switch format.lowercased() {
    case "jwk":
        return .jwk(value: asString(jsonDictionary: value))
    case "multibase":
        return .multibase(value: asString(jsonDictionary: value))
    case "base58":
        return .base58(value: asString(jsonDictionary: value))
    case "hex":
        return .hex(value: asString(jsonDictionary: value))
    default:
        return .other(value: asString(jsonDictionary: value))
        
    }
}

func parseServices(_ json: [NSDictionary]) -> [Service] {
    let services: [Service] = []
    for sObj in json {
        fatalError("FUNCTION NOT IMPLEMENTED YET")
//        guard let _ = sObj.value(forKey: "value") as? NSDictionary else {
//            fatalError("Cant resolve Verification Material: value")
//        }
    }
    return services
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

//Catch errors
func asString(jsonDictionary: JSONDictionary) -> String {
  do {
    let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
    return String(data: data, encoding: String.Encoding.utf8) ?? ""
  } catch {
    return ""
  }
}
