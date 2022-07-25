extension Message {
    func dataDictionary() -> JSONDictionary {
        
        let attachmentsJson = self.attachments?.map { attachment  in
            return attachment.dataDictionary()
        }
        
        return [ "id": self.id,
                 "typ": self.typ,
                 "type": self.type,
                 "body": self.body,
                 "from": self.from,
                 "to": self.to,
                 "thid": self.thid,
                 "pthid": self.pthid,
                 "extraHeaders": self.extraHeaders,
                 "createdTime": self.createdTime,
                 "expiresTime": self.expiresTime,
                 "fromPrior": self.fromPrior,
                 "attachments": attachmentsJson ]
    }
    
    init(fromJson json: NSDictionary) {
    
        guard let id = json["id"] as? String else {
            fatalError("Cant resolve id from Message")
        }
        
        guard let typ = json["typ"] as? String else {
            fatalError("Cant resolve typ from Message")
        }
        
        guard let type = json["type"] as? String else {
            fatalError("Cant resolve type from Message")
        }
        
        guard let body = json["body"] as? JSONDictionary else {
            fatalError("Cant resolve body from Message")
        }
       
        self.id = id
        self.typ = typ
        self.type = type
        self.body = body.asString ?? "{}"
        self.from = json["from"] as? String
        self.to = json["to"] as? [String]
        self.thid = json["thid"] as? String
        self.pthid = json["pthid"] as? String
        self.extraHeaders = json["extraHeaders"]  as? [String: String] ?? [:]
        self.createdTime = json["createdTime"] as? UInt64
        self.expiresTime = json["expiresTime"] as? UInt64
        self.fromPrior = json["fromPrior"] as? String

        if let attachmentsJson = json["attachments"] as? [JSONDictionary] {
            self.attachments = attachmentsJson.map { attachmentJson in
                return .init(fromJson: attachmentJson)
            }
        } else {
            self.attachments = nil
        }
    }
}
