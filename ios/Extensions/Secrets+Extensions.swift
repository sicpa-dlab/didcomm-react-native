import DidcommSDK

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
        
        guard let value = secretMaterialJson.value(forKey: "value") as? String else {
            fatalError("Can't resolve 'value' from Secret.")
        }
        
        self.init(id: id, type: .fromString(type),
                  secretMaterial: .fromString(format,
                                              jsonString: value))
    }
}

