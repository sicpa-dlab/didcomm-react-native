import UIKit
extension Secret {
    init(fromJson json: JSONDictionary) {
        
        guard let id = json["id"] as? String else {
            fatalError("Cant resolve secret: id")
        }
        
        guard let type = json["type"] as? String else {
            fatalError("Cant resolve verification method: type")
        }
        
        guard let secretMaterialJson = json["secret_material"] as? NSDictionary else {
            fatalError("Cant resolve verification method: type")
        }
        
        guard let format = secretMaterialJson.value(forKey: "format") as? String else {
            fatalError("Cant resolve Verification Material: format")
        }
        
        guard let value = secretMaterialJson.value(forKey: "value") as? JSONDictionary else {
            fatalError("Cant resolve Verification Material: value")
        }
        
        self.id = id
        self.type = .fromString(type)
        self.secretMaterial = .fromString(format,
                                          jsonString: value.asString ?? "{}")
    }
}

