extension FromPrior {
    func dataDictionary() -> [String: Any?] {
        return [ "iss": iss,
                 "sub": sub,
                 "aud": aud,
                 "exp": exp,
                 "nbf": nbf,
                 "iat": iat,
                 "jti": jti ]
    }
    
    init(fromJson fromPrior: NSDictionary) {
        
        guard let iss = fromPrior.value(forKey: "iss") as? String  else {
            fatalError("Can't resolve 'iss' from FromPrior.")
        }
        
        guard let sub = fromPrior.value(forKey: "sub") as? String else {
            fatalError("Can't resolve 'sub' from FromPrior.")
        }
        
        self.iss = iss
        self.sub = sub
        self.aud = fromPrior.value(forKey: "aud") as? String
        self.exp = fromPrior.value(forKey: "exp") as? UInt64
        self.nbf = fromPrior.value(forKey: "nbf") as? UInt64
        self.iat = fromPrior.value(forKey: "iat") as? UInt64
        self.jti = fromPrior.value(forKey: "jti") as? String
    }
}
