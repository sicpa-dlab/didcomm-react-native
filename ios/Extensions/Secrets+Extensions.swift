import UIKit
extension Secret {
    init(fromJson json: JSONDictionary) {
        
        guard let id = json["id"] as? String else {
            fatalError("Can't resolve 'id' from Secret.")
        }
        
        guard let type = json["type"] as? String else {
            fatalError("Can't resolve 'type' from Secret.")
        }
        
        guard let secretMaterialJson = json["secret_material"] as? NSDictionary else {
            fatalError("Can't resolve 'secret_material' from Secret Material.")
        }
        
        guard let format = secretMaterialJson.value(forKey: "format") as? String else {
            fatalError("Can't resolve 'format' from Secret.")
        }
        
        guard let value = secretMaterialJson.value(forKey: "value") as? JSONDictionary else {
            fatalError("Can't resolve 'value' from Secret.")
        }
        
        self.id = id
        self.type = .fromString(type)
        self.secretMaterial = .fromString(format,
                                          jsonString: value.asString ?? "{}")
    }
}

