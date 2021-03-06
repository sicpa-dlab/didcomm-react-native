import DidcommSDK

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
            fatalError("Can't resolve 'id' from Message.")
        }
        
        guard let typ = json["typ"] as? String else {
            fatalError("Can't resolve 'typ' from Message.")
        }
        
        guard let type = json["type"] as? String else {
            fatalError("Can't resolve 'type' from Message.")
        }
        
        guard let body = json["body"] as? JSONDictionary else {
            fatalError("Can't resolve 'body' from Message.")
        }
       
        var attachments: [Attachment]?
        
        if let attachmentsJson = json["attachments"] as? [JSONDictionary] {
            attachments = attachmentsJson.map { attachmentJson in
                return .init(fromJson: attachmentJson)
            }
        }
        
        self.init(id: id,
                  typ: typ,
                  type: type,
                  body: body.asString ?? "{}",
                  from: json["from"] as? String,
                  to: json["to"] as? [String],
                  thid: json["thid"] as? String,
                  pthid: json["pthid"] as? String,
                  extraHeaders: json["extraHeaders"]  as? [String: String] ?? [:],
                  createdTime: json["createdTime"] as? UInt64,
                  expiresTime: json["expiresTime"] as? UInt64,
                  fromPrior: json["fromPrior"] as? String,
                  attachments: attachments)
    }
}
