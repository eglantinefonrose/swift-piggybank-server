import Vapor

func routes(_ app: Application) throws {
    
    
    // curl -s -X GET "http://localhost:8181/hello/gnu"
    // Remaque: C'est une route d'exemple qui renvoie explicitement la réponse HTTP
    app.get("hello", "gnu") { req async -> Response in
        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        print("Eglant la fouine [\(timeEpoch)]")
        return Response(
            status: .ok,
            headers: ["Content-Type": "text/html"],
            body: Response.Body(stringLiteral: "<html>\n\t<h2><b>Salut timeEpoch=[\(timeEpoch)]</b></h2>\n</html>\n"))
    }

    
    // curl -s -X GET "http://localhost:8181/initializeAccount/withAccountId/231231231/withFirstName/Eglantine/withLastName/Fonrose/withAccountBalance/1500/EUR"
    app.get("initializeAccount", "withAccountId", ":accountId", "withFirstName", ":firstName", "withLastName", ":lastName", "withAccountBalance", ":accountBalance", ":currency") { req async throws -> BankAccountDTO in
        
        let accountId = req.parameters.get("accountId")!
        let firstName = req.parameters.get("firstName")!
        let lastName  = req.parameters.get("firstName")!
        let currency  = req.parameters.get("currency")!
        guard let accountBalance = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        return try PiggyBankService.shared.createBankAccount(accountId: accountId, amount: 0, currency: currency, firstName: firstName, lastName: lastName)
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/initializeAccount/withAccountId/231231231/withFirstName/Eglantine/withLastName/Fonrose/withAccountBalance/1500/EUR/withOverdraftAuthorization/:overdraftAuthorization/withOverdraftLimit/:overdraftLimit") { req async throws -> BankAccountDTO in
    app.get("initializeAccount", "withAccountId", ":accountId", "withFirstName", ":firstName", "withLastName", ":lastName", "withAccountBalance", ":accountBalance", "currency", ":theCurrency", "withOverdraftAuthorization", ":overdraftAuthorization", "withOverdraftLimit", ":overdraftLimit") { req async throws -> BankAccountDTO in
    
        let accountId = req.parameters.get("accountId")!
        let firstName = req.parameters.get("firstName")!
        let lastName  = req.parameters.get("firstName")!
        let currency  = req.parameters.get("currency")!
        guard let accountBalance         = Float64(req.parameters.get("accountBalance")!) else         { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }
        guard let overdraftAuthorization =   Int64(req.parameters.get("overdraftAuthorization")!) else { throw PiggyBankError.invalidParameters(message: "Invalid overdraftAuthorization=[\(req.parameters.get("overdraftAuthorization")!)]") }
        guard let overdraftLimit         = Float64(req.parameters.get("overdraftLimit")!) else         { throw PiggyBankError.invalidParameters(message: "Invalid overdraftLimit=[\(req.parameters.get("overdraftLimit")!)]") }

        return try PiggyBankService.shared.createBankAccount(accountId: accountId, amount: 0, currency: currency, firstName: firstName, lastName: lastName, isOverdraftAllowed: overdraftAuthorization, overdraftLimit: overdraftLimit)
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/makePayment/fromAccount/231231231/withAmount/120/EUR
    app.get("makePayment", "fromAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let currency = req.parameters.get("currency")!
        guard let amount = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        let result: BankAccountDTO = try PiggyBankService.shared.makePayment(fromBankAccountID: accountId, forAnAmountOf: amount, withCurrency: currency);
        return result;
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/makeDeposit/toAccount/231231231/withAmount/120/EUR
    app.get("makeDeposit", "toAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let currency = req.parameters.get("currency")!
        guard let amount = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        let result = try PiggyBankService.shared.makeDeposit(toAccount: accountId, forAnAmountOf: amount, withCurrency: currency);
        return result;
        
    }

    
    // curl -s -X GET "http://localhost:8181/transferMoney/fromAccount/231231231/toAccount/5672357234/withAmount/120"
    app.get("transferMoney", "fromAccount", ":senderAccountID", "toAccount", ":recipientAccountId", "withAmount", ":amount") { req async throws -> BankAccountDTO in
                
        let senderAccountID = req.parameters.get("senderAccountID")!
        let recipientAccountId = req.parameters.get("recipientAccountId")!
        guard let amount = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        let result = try PiggyBankService.shared.transferMoney(fromAccountID: senderAccountID, toAccountID: recipientAccountId, forAnAmountOf: amount)
        return result
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/getBankAccount/231231231"
    app.get("getBankAccount", ":accountId") { req async throws -> BankAccountDTO in
        
        let accountId = req.parameters.get("accountId")!
        
        return try PiggyBankService.shared.getBankAccountInfo(forAccountId: accountId)
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/getTransactions/231231231/inCurrency/EUR"
    app.get("getTransactions", ":accountId", "inCurrency", ":currency") { req async throws -> [TransactionDTO] in
        
        let accountId = req.parameters.get("accountId")!
        let currency = req.parameters.get("currency")!
        
        return try PiggyBankService.shared.getAllTransactions(forAccountId: accountId, withCurrency: currency)
        
    }
    
}
