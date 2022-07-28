extension Attachment {
    init(fromJson json: JSONDictionary) {
        
        guard let dataJson = json["data"] as? JSONDictionary else {
            fatalError("Can't resolve 'data' from Attachment.")
        }
        
        self.data = .fromJson(dataJson)
        self.id = json["id"] as? String
        self.description = json["description"] as? String
        self.filename = json["filename"] as? String
        self.mediaType = json["media_type"] as? String
        self.format = json["format"] as? String
        self.lastmodTime = json["lastmod_time"] as? UInt64
        self.byteCount = json["byte_count"] as? UInt64
    }
    
    func dataDictionary() -> JSONDictionary {
        return [ "data": self.data.dataDictionary(),
                 "id": self.id,
                 "description": self.description,
                 "filename": self.filename,
                 "media_type": self.mediaType,
                 "format": self.format,
                 "lastmod_time": self.lastmodTime,
                 "byte_count": self.byteCount ]
    }
}

extension AttachmentData {
    static func fromJson(_ data: JSONDictionary) -> AttachmentData{
        let jws = data["jws"] as? String
        if let base64 = data["base64"] as? String {
            return .base64(value: .init(base64: base64, jws: jws))
        } else if let json = data["json"] as? String {
            return .json(value: .init(json: json, jws: jws))
        } else if let links = data["links"] as? [String] {
            let hash = data["hash"] as? String ?? ""
            return .links(value: .init(links: links, hash: hash, jws: jws))
        } else {
            fatalError("AttachmentData not supported! Supported types: 'base64', 'json' and 'links'.")
        }
    }
    
    func dataDictionary() -> JSONDictionary {
        switch self {
        case .base64(let value):
            return ["base64": value.base64, "jws": value.jws]
        case .json(let value):
            return ["json": value.json, "jws": value.jws]
        case .links(let value):
            return ["links": value.links, "hash": value.hash,"jws": value.jws]
        }
    }
}
