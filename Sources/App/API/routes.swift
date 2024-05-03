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
        
        do {
            let accountId = req.parameters.get("accountId")!
            let firstName = req.parameters.get("firstName")!
            let lastName = req.parameters.get("firstName")!
            let accountBalance : Float64  = Float64(req.parameters.get("accountBalance")!)!
            let currency = req.parameters.get("currency")!

            return try PiggyBankService.shared.createBankAccount(accountId: accountId, amount: 0, currency: currency, firstName: firstName, lastName: lastName)
        } catch let error {
            throw PiggyBankError.invalidParameters(message: error.localizedDescription)
        }
    }
    
    // curl -s -X GET "http://localhost:8181/initializeAccount/withAccountId/231231231/withFirstName/Eglantine/withLastName/Fonrose/withAccountBalance/1500/EUR/withOverdraftAuthorization/:overdraftAuthorization/withOverdraftLimit/:overdraftLimit") { req async throws -> BankAccountDTO in
    app.get("initializeAccount", "withAccountId", ":accountId", "withFirstName", ":firstName", "withLastName", ":lastName", "withAccountBalance", ":accountBalance", "currency", ":theCurrency", "withOverdraftAuthorization", ":overdraftAuthorization", "withOverdraftLimit", ":overdraftLimit") { req async throws -> BankAccountDTO in
    
        do {
            let accountId = req.parameters.get("accountId")!
            let firstName = req.parameters.get("firstName")!
            let lastName = req.parameters.get("firstName")!
            let accountBalance : Float64  = Float64(req.parameters.get("accountBalance")!)!
            let currency = req.parameters.get("currency")!
            let overdraftAuthorization = Int64(req.parameters.get("overdraftAuthorization")!)!
            let overdraftLimit: Float64 = Float64(req.parameters.get("overdraftLimit")!)!
            
            return try PiggyBankService.shared.createBankAccount(accountId: accountId, amount: 0, currency: currency, firstName: firstName, lastName: lastName, isOverdraftAllowed: overdraftAuthorization, overdraftLimit: overdraftLimit)
        } catch let error {
            throw PiggyBankError.invalidParameters(message: error.localizedDescription)
        }
        
    }
    
    // curl -s -X GET "http://localhost:8181/makePayment/fromAccount/231231231/withAmount/120/EUR
    app.get("makePayment", "fromAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let amount : Float64  = Float64(req.parameters.get("amount")!) ?? -13.37
        let currency = req.parameters.get("currency")!
        
        let result: BankAccountDTO = try PiggyBankService.shared.makePayment(fromBankAccountID: accountId, forAnAmountOf: amount, withCurrency: currency);
        return result;
        
    }
    
    // curl -s -X GET "http://localhost:8181/makeDeposit/toAccount/231231231/withAmount/120/EUR
    app.get("makeDeposit", "toAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let amount : Float64  = Float64(req.parameters.get("amount")!) ?? -13.37
        let currency = req.parameters.get("currency")!
        
        let result = try PiggyBankService.shared.makeDeposit(toAccount: accountId, forAnAmountOf: amount, withCurrency: currency);
        return result;
        
    }

    // curl -s -X GET "http://localhost:8181/transferMoney/fromAccount/231231231/toAccount/5672357234/withAmount/120"
    app.get("transferMoney", "fromAccount", ":senderAccountID", "toAccount", ":recipientAccountId", "withAmount", ":amount") { req async throws -> BankAccountDTO in
                
        let senderAccountID = req.parameters.get("senderAccountID")!
        let recipientAccountId = req.parameters.get("recipientAccountId")!
        let amount : Float64  = Float64(req.parameters.get("amount")!)!
        
        let result = try PiggyBankService.shared.transferMoney(fromAccountID: senderAccountID, toAccountID: recipientAccountId, forAnAmountOf: amount)
        return result
        
    }
    
    
    // curl -s -X GET "http://localhost:8181/getBankAccount/231231231"
    app.get("getBankAccount", ":accountId") { req async throws -> BankAccountDTO in
        do {
            let accountId = req.parameters.get("accountId")!
            
            return try PiggyBankService.shared.getBankAccountInfo(forAccountId: accountId)
        } catch {
            print("ERROR GRAVE [\(error)]")
            throw PiggyBankError.technicalError
        }
    }

    // curl -s -X GET "http://localhost:8181/getTransactions/231231231/inCurrency/EUR"
    app.get("getTransactions", ":accountId", "inCurrency", ":currency") { req async throws -> [TransactionDTO] in
        do {
            let accountId = req.parameters.get("accountId")!
            let currency = req.parameters.get("currency")!

            do {
                return try PiggyBankService.shared.getAllTransactions(forAccountId: accountId, withCurrency: currency)
            } catch {
                print("ERROR GRAVE [\(error)]")
                throw PiggyBankError.technicalError
            }
        } catch {
            throw PiggyBankError.invalidParameters(message: error.localizedDescription)
        }
    }
    
}
