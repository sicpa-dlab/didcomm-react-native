extension Service {
    init(fromJson json: JSONDictionary) {
        
        print(json)
        
        guard let id = json["id"] as? String else {
            fatalError("Cant resolve verification method: id")
        }

        guard let serviceEndpoint = json["serviceEndpoint"] as? JSONDictionary else {
            fatalError("Cant resolve verification method: kind")
        }
        
        self.id = id
        self.kind = .fromString(serviceEndpoint)
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
