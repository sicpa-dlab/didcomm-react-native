import DidcommSDK

extension Service {
    init(fromJson json: JSONDictionary) {

        guard let id = json["id"] as? String else {
            fatalError("Can't resolve 'id' from Service.")
        }

        guard let serviceEndpoint = json["serviceEndpoint"] as? JSONDictionary else {
            fatalError("Can't resolve 'serviceEndpoint' from Service.")
        }
        
        self.init(id: id,
                  kind: .fromString(serviceEndpoint))
        
    }
}

extension ServiceKind {
    static func fromString(_ json: JSONDictionary) -> ServiceKind {
        guard let uri = json["uri"] as? String,
              let accept = json["accept"] as? [String],
              let routingKeys = json["routingKeys"] as? [String] else {
            return .other(value: "")
        }
        
        return .didCommMessaging(value: .init(serviceEndpoint: uri, accept: accept, routingKeys: routingKeys))
    }
}
