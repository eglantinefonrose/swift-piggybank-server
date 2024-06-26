import Vapor

func routes(_ app: Application) throws {
    
    
    // curl -s -X GET "http://localhost:8181/hello/gnu"
    app.get("hello", "gnu") { req async -> Response in
        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        print("Eglant la fouine [\(timeEpoch)]")
        return Response(
            status: .ok,
            headers: ["Content-Type": "text/html"],
            body: Response.Body(stringLiteral: "<html>\n\t<h2><b>Salut timeEpoch=[\(timeEpoch)]</b></h2>\n</html>\n"))
    }


    
    
    // curl -s -X PUT "http://localhost:8181/initializeAccount" -H "Content-type: application/json" -d '{"firstName":"Eglantine","lastName":"Eglantine","accountId":"231231238","accountBalance":0,"currency":"EUR","isOverdraftAllowed":0}' | jq .
    app.put("initializeAccount") { req async throws -> BankAccountDTO in

        let bankAccountInfo = try req.content.decode(BankAccountDTO.self)
        return try PiggyBankService.shared.createBankAccount(bankAccountInfo: bankAccountInfo)

    }
    
    
    // curl -s -X PUT "http://localhost:8181/initializeAccount/withAccountId/231231231/withFirstName/Eglantine/withLastName/Fonrose/withAccountBalance/1500/EUR" | jq .
    app.put("initializeAccount", "withAccountId", ":accountId", "withFirstName", ":firstName", "withLastName", ":lastName", "withAccountBalance", ":accountBalance", ":currency") { req async throws -> BankAccountDTO in
        
        let accountId = req.parameters.get("accountId")!
        let firstName = req.parameters.get("firstName")!
        let lastName  = req.parameters.get("firstName")!
        let currency  = req.parameters.get("currency")!
        guard let accountBalance = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        return try PiggyBankService.shared.createBankAccount(accountId: accountId, amount: accountBalance, currency: currency, firstName: firstName, lastName: lastName)
        
    }
    
    
    // curl -s -X PUT "http://localhost:8181/initializeAccount/withAccountId/231231231/withFirstName/Eglantine/withLastName/Fonrose/withAccountBalance/1500/EUR/withOverdraftAuthorization/:overdraftAuthorization/withOverdraftLimit/:overdraftLimit") | jq .
    app.put("initializeAccount", "withAccountId", ":accountId", "withFirstName", ":firstName", "withLastName", ":lastName", "withAccountBalance", ":accountBalance", "currency", ":theCurrency", "withOverdraftAuthorization", ":overdraftAuthorization", "withOverdraftLimit", ":overdraftLimit") { req async throws -> BankAccountDTO in
    
        let accountId = req.parameters.get("accountId")!
        let firstName = req.parameters.get("firstName")!
        let lastName  = req.parameters.get("firstName")!
        let currency  = req.parameters.get("currency")!
        guard let accountBalance         = Float64(req.parameters.get("accountBalance")!) else         { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }
        guard let overdraftAuthorization =   Int64(req.parameters.get("overdraftAuthorization")!) else { throw PiggyBankError.invalidParameters(message: "Invalid overdraftAuthorization=[\(req.parameters.get("overdraftAuthorization")!)]") }
        guard let overdraftLimit         = Float64(req.parameters.get("overdraftLimit")!) else         { throw PiggyBankError.invalidParameters(message: "Invalid overdraftLimit=[\(req.parameters.get("overdraftLimit")!)]") }

        return try PiggyBankService.shared.createBankAccount(accountId: accountId, amount: accountBalance, currency: currency, firstName: firstName, lastName: lastName, isOverdraftAllowed: overdraftAuthorization, overdraftLimit: overdraftLimit)
        
    }
    
    
    // curl -s -X POST "http://localhost:8181/makePayment/fromAccount/231231231/withAmount/120/EUR | jq .
    app.post("makePayment", "fromAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let currency = req.parameters.get("currency")!
        guard let amount = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        let result: BankAccountDTO = try PiggyBankService.shared.makePayment(fromBankAccountID: accountId, forAnAmountOf: amount, withCurrency: currency);
        return result;
        
    }
    
    
    // curl -s -X POST "http://localhost:8181/makeDeposit/toAccount/231231231/withAmount/120/EUR | jq .
    app.post("makeDeposit", "toAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let currency = req.parameters.get("currency")!
        guard let amount = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        let result = try PiggyBankService.shared.makeDeposit(toAccount: accountId, forAnAmountOf: amount, withCurrency: currency);
        return result;
        
    }

    
    // curl -s -X POST "http://localhost:8181/transferMoney/fromAccount/231231231/toAccount/5672357234/withAmount/120" | jq .
    app.post("transferMoney", "fromAccount", ":senderAccountID", "toAccount", ":recipientAccountId", "withAmount", ":amount") { req async throws -> BankAccountDTO in
                
        let senderAccountID = req.parameters.get("senderAccountID")!
        let recipientAccountId = req.parameters.get("recipientAccountId")!
        guard let amount = Float64(req.parameters.get("accountBalance")!) else { throw PiggyBankError.invalidParameters(message: "Invalid accountBalance=[\(req.parameters.get("accountBalance")!)]") }

        let result = try PiggyBankService.shared.transferMoney(fromAccountID: senderAccountID, toAccountID: recipientAccountId, forAnAmountOf: amount)
        return result
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/getBankAccount/231231231" | jq .
    app.get("getBankAccount", ":accountId") { req async throws -> BankAccountDTO in
        
        let accountId = req.parameters.get("accountId")!
        
        return try PiggyBankService.shared.getBankAccountInfo(forAccountId: accountId)
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/getTransactions/231231231/inCurrency/EUR" | jq .
    app.get("getTransactions", ":accountId", "inCurrency", ":currency") { req async throws -> [TransactionDTO] in
        
        let accountId = req.parameters.get("accountId")!
        let currency = req.parameters.get("currency")!
        
        return try PiggyBankService.shared.getAllTransactions(forAccountId: accountId, withCurrency: currency)
        
    }
    
}
