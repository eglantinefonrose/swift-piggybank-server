import Vapor

func routes(_ app: Application) throws {
    
    app.get { req async in
        let timeEpoch = NSDate().timeIntervalSince1970
        print("Eglant la Gogol")
        return "It works [\(timeEpoch)]!"
    }
    
    app.get("hello") { req async -> String in
        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        print("Eglant la buse")
        return "Hello, world [\(timeEpoch)]!"
    }
    
    app.get("hello", "schibbo") { req async -> String in
        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        print("Eglant la truie")
        return "<html><h2><b>Salug</b></h2> [\(timeEpoch)]!</html>"
    }

    app.get("hellog", ":name") { req async -> String in
        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        let name = req.parameters.get("name")!
        print("\(name) la truie")
        return "<html><h2><b>Salug \(name)</b></h2> [\(timeEpoch)]!</html>"
    }
    
    // makePayment/toAccount/231231231/withAmount/120/EUR
    app.get("makePayment", "toAccount", ":accountId", "withAmount", ":amount", ":currency") { req async -> BankAccountDTO in
                
        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        let date = Date(timeIntervalSinceNow: 0)
        let accountId = req.parameters.get("accountId")!
        let amount = req.parameters.get("amount")!
        let currency = req.parameters.get("currency")!
        
        return PiggyBankService.shared.makePayment(timeEpoch, date, accountId, amount, currency)
        
    }
    
    // getBankAccount/231231231
    app.get("getBankAccount", ":accountId") { req async -> BankAccountDTO in
        let accountId = req.parameters.get("accountId")!
        return PiggyBankServerDataStorageService.shared.getBankAccountDTO(accountId: accountId)
    }

    
    app.get("hello", "gnu") { req async -> Response in
        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        print("Eglant la fouine [\(timeEpoch)]")
        return Response(
            status: .ok,
            headers: ["Content-Type": "text/html"],
            body: "<html><h2><b>Salug</b></h2></html>")
    }

    
}
