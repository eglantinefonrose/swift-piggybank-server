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
    app.get("makePayment", "toAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let amount : Float  = Float(req.parameters.get("amount")!) ?? -13.37
        let currency = req.parameters.get("currency")!
        
        return try PiggyBankService.shared.makePayment(accountId: accountId, thePaymentAmount: amount, currency: currency)
        
    }
    
    
    // getBankAccount/231231231
    app.get("getBankAccount", ":accountId") { req async throws -> BankAccountDTO in
        let accountId = req.parameters.get("accountId")!
        do {
            return try PiggyBankServerDataStorageService.shared.getBankAccountDTO(selectedAccountId: accountId)
        } catch {
            print("RROR GRVE")
            throw PiggyBankError.overDraftMustBeNegative
        }
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
