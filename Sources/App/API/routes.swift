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
        let amount : Float64  = Float64(req.parameters.get("amount")!) ?? -13.37
        let currency = req.parameters.get("currency")!
        
        return try PiggyBankServerDataStorageService.shared.makePayment(selectedBankAccountID: accountId, thePaymentAmount: amount, theCurrency: currency)
        
    }
    
    app.get("addMoney", "toAccount", ":accountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let amount : Float64  = Float64(req.parameters.get("amount")!) ?? -13.37
        let currency = req.parameters.get("currency")!
        
        return try PiggyBankServerDataStorageService.shared.addMoney(selectedBankAccountID: accountId, thePaymentAmount: amount, theCurrency: currency)
        
    }
    
    app.get("initializeAccount", "withAccountId", ":accountId", "withFirstName", ":firstName", "withLastName", ":lastName", "withAccountBalance", ":accountBalance", "currency", ":theCurrency", "overdraftAuthorization", ":overdraftAuthorization", "overdraftLimit", ":overdraftLimit") { req async throws -> BankAccountDTO in
                
        let accountId = req.parameters.get("accountId")!
        let firstName = req.parameters.get("firstName")!
        let lastName = req.parameters.get("firstName")!
        let accountBalance : Float64  = Float64(req.parameters.get("accountBalance")!) ?? -13.37
        let currency = req.parameters.get("currency")!
        let overdraftAuthorization = Int64(req.parameters.get("overdraftAuthorization")!) ?? -1
        let overdraftLimit = Float64(req.parameters.get("overdraftLimit")!) ?? -1
        
        return try PiggyBankServerDataStorageService.shared.createABankAccountDTO(theAccountId: accountId, theFirstName: firstName, theLastName: lastName, theAccountBalance: accountBalance, theCurrency: currency, isTheOverdraftAllowed: overdraftAuthorization, theOverDraftLimit: overdraftLimit)
        
    }
    
    app.get("transferMoney", "fromAccount", ":senderAccountID", "toAccount", ":recipientAccountId", "withAmount", ":amount", ":currency") { req async throws -> BankAccountDTO in
                
        let senderAccountID = req.parameters.get("senderAccountID")!
        let recipientAccountId = req.parameters.get("recipientAccountId")!
        let amount : Float64  = Float64(req.parameters.get("amount")!) ?? -13.37
        let currency = req.parameters.get("currency")!
        
        return try PiggyBankServerDataStorageService.shared.transferMoney(senderBankAccountID: senderAccountID, recipientBankAccountID: recipientAccountId, thePaymentAmount: amount, theCurrency: currency)
        
    }
    
    
    // getBankAccount/231231231
    app.get("getBankAccount", ":accountId") { req async throws -> BankAccountDTO in
        let accountId = req.parameters.get("accountId")!
        do {
            return try PiggyBankServerDataStorageService.shared.getBankAccountDTO(selectedAccountId: accountId)
        } catch {
            print("RROR GRVE")
            throw PiggyBankError.technicalError
        }
    }

    app.get("getSenderTransactions", ":accountId") { req async throws -> [TransactionDTO] in
        let accountId = req.parameters.get("accountId")!
        do {
            return try PiggyBankServerDataStorageService.shared.getAllSenderTransactions(selectedAccountId: accountId)
        } catch {
            print("RROR GRVE")
            throw PiggyBankError.technicalError
        }
    }
    
    app.get("getRecipientTransactions", ":accountId") { req async throws -> [TransactionDTO] in
        let accountId = req.parameters.get("accountId")!
        do {
            return try PiggyBankServerDataStorageService.shared.getAllRecipientTransactions(selectedAccountId: accountId)
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
