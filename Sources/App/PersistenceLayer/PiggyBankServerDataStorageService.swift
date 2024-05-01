//
//  File.swift
//  
//
//  Created by Eglantine Fonrose on 09/08/2023.
//

import Foundation
import SQLite

class PiggyBankServerDataStorageService {
    
    private var db: Connection!
    private var bankAccountsDTO: Table!
    private var accountId: Expression<String>!
    private var firstName: Expression<String>!
    private var lastName: Expression<String>!
    private var accountBalance: Expression<Float64>!
    private var currency: Expression<String>!
    private var isOverdraftAllowed: Expression<Int64>!
    private var overDraftLimit: Expression<Float64>!
    private var transactions: Table!
    private var transactionSenderBankAccountID: Expression<String>!
    private var transactionRecipientAccountID: Expression<String>!
    private var transactionPaymentAmount: Expression<Float64>!
    private var transactionCurrency: Expression<String>!
    private var transactionID: Expression<String>!
    private var transactionDate: Expression<Int64>!

    init () {
        do {
            db = try Connection("/Users/eglantine/Dev/0.perso/2.Proutechos/0.PiggyBank/0.PiggyBank/PiggyDataBase.db")
            bankAccountsDTO = Table("BankAccountDTO")
            accountId = Expression<String>("accountId")
            firstName = Expression<String>("firstName")
            lastName = Expression<String>("lastName")
            accountBalance = Expression<Float64>("accountBalance")
            currency = Expression<String>("currency")
            isOverdraftAllowed = Expression<Int64>("isOverdraftAllowed")
            overDraftLimit = Expression<Float64>("overdraftLimit")
            
            transactions = Table("Transactions")
            transactionID = Expression<String>("id")
            transactionSenderBankAccountID = Expression<String>("senderAccountID")
            transactionRecipientAccountID = Expression<String>("recipientAccountID")
            transactionPaymentAmount = Expression<Float64>("amount")
            transactionCurrency = Expression<String>("currency")
            transactionDate = Expression<Int64>("date")

            /*if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                try db.run(bankAccountsDTO.create { (t) in
                    t.column(accountId, primaryKey: true)
                    t.column(firstName)
                    t.column(lastName)
                    t.column(accountBalance)
                    t.column(currency)
                    t.column(isOverdraftAllowed)
                    t.column(overDraftLimit)
                })

                try db.run(bankAccountsDTO.insert (
                    accountId <- "58540395859",
                    firstName <- "Malo",
                    lastName <- "Fonrose",
                    accountBalance <- 0,
                    currency <- "EUR",
                    isOverdraftAllowed <- 0,
                    overDraftLimit <- 0
                ))

                try db.run(bankAccountsDTO.insert (
                    accountId <- "38469403805",
                    firstName <- "Eglantine",
                    lastName <- "Fonrose",
                    accountBalance <- 0,
                    currency <- "EUR",
                    isOverdraftAllowed <- 0,
                    overDraftLimit <- 0
                ))

                UserDefaults.standard.set(true, forKey: "is_db_created")

            }*/

            print("-- dbmanager init --")

        }
        catch {
            print(error.localizedDescription)
        }
    }

    public func getBankAccountDTO(selectedAccountId:String) throws -> BankAccountDTO {

        var bankAccountDTO: BankAccountDTO = BankAccountDTO(theAccountId: "", theAmount: 3, theCurrency: "", theFirstName: "", theLastName: "", isOverdraftAllowed: 0, theOverDraftLimit: 0)
        
        do {

            // Requête pour récupérer la ligne où le champ "accountId" est "selectedAccountId"
            let query = bankAccountsDTO.filter(accountId == selectedAccountId)
            
            // Exécution de la requête et récupération du résultat
            if let row = try db.pluck(query) {
                let bankAccountID = row[accountId]
                let bankAccountFirstName = row[firstName]
                let bankAccountLastName = row[lastName]
                let bankAccountAmount = row[accountBalance]
                let bankAccountCurrency = row[currency]
                let bankAccountisOverdraftAllowed = row[isOverdraftAllowed]
                let bankAccounttheOverDraftLimit = row[overDraftLimit]
                
                bankAccountDTO = BankAccountDTO(theAccountId: bankAccountID, theAmount: Float64(Float(bankAccountAmount)), theCurrency: bankAccountCurrency, theFirstName: bankAccountFirstName, theLastName: bankAccountLastName, isOverdraftAllowed: Int64(bankAccountisOverdraftAllowed), theOverDraftLimit: Float64(bankAccounttheOverDraftLimit))
                print("firstName \(bankAccountFirstName)")
                
                return bankAccountDTO
                
            } else {
                print("Error - Aucune ligne trouvée avec l'id \(selectedAccountId)")
                throw PiggyBankError.unknownAccount
            }
            
        } catch let error as PiggyBankError {
            // If the error is already a PiggyBank error (ie thrown by our code), we re-throw it as-is
            throw error
        } catch {
            // If the error is any other error, we throw a 'PiggyBankError.technicalError'
            throw PiggyBankError.technicalError
        }

        //return try BankAccountDTO(theAccountId: "5140124I234", theAmount: 123.10, theCurrency: "EUR", theFirstName: "Nicolas", theLastName: "Fonrose")

    }
    
    
    public func getAllTransactions(selectedAccountId:String, currency: String) throws -> [TransactionDTO] {

        var transactionsList : [TransactionDTO] = []
        
        do {

            // Requête pour récupérer la ligne où le champ "accountId" est "selectedAccountId"
            let query = transactions
                //.filter(transactionSenderBankAccountID == selectedAccountId)
                .filter(transactionRecipientAccountID == selectedAccountId || transactionSenderBankAccountID == selectedAccountId)
                .order(transactionDate.desc)
            
            // Exécution de la requête et récupération du résultat
            
            for row in try db.prepare(query) {
                let transactionID = row[transactionID]
                let transactionSenderBankAccountID = row[transactionSenderBankAccountID]
                let transactionRecipientBankAccountID = row[transactionRecipientAccountID]
                let transactionCurrency = currency
                let transactionPaymentAmount = try PiggyBankService.shared.moneyConvertor(amount: row[transactionPaymentAmount], oldCurrency: transactionCurrency, newCurrency: currency)
                let transactionDate = row[transactionDate]
                
                transactionsList.append(TransactionDTO(theId: transactionID, theSenderAccountID: transactionSenderBankAccountID, theRecipientAccountID: transactionRecipientBankAccountID, theAmount: transactionPaymentAmount, theCurrency: transactionCurrency, theDate: transactionDate))
            }
            
        } catch let error as PiggyBankError {
            // If the error is already a PiggyBank error (ie thrown by our code), we re-throw it as-is
            throw error
        } catch {
            // If the error is any other error, we throw a 'PiggyBankError.technicalError'
            throw PiggyBankError.technicalError
        }

        return transactionsList

    }
    
    
    public func createABankAccountDTO(theAccountId: String, theFirstName: String, theLastName: String, theAccountBalance: Float64, theCurrency: String, isTheOverdraftAllowed: Int64, theOverDraftLimit: Float64) throws -> BankAccountDTO {
        
        do {
            try db.run(bankAccountsDTO.insert (
                accountId <- theAccountId,
                firstName <- theFirstName,
                lastName <- theLastName,
                accountBalance <- theAccountBalance,
                currency <- theCurrency,
                isOverdraftAllowed <- isTheOverdraftAllowed,
                overDraftLimit <- theOverDraftLimit
            ))
            
            return BankAccountDTO(theAccountId: theAccountId, theAmount: theAccountBalance, theCurrency: theCurrency, theFirstName: theFirstName, theLastName: theLastName, isOverdraftAllowed: isTheOverdraftAllowed, theOverDraftLimit: theOverDraftLimit)
            
        }
        catch {
            throw PiggyBankError.technicalError
        }
        
    }
    
    func makePayment(selectedBankAccountID: String, thePaymentAmount: Float64, theCurrency: String) throws -> BankAccountDTO {
                
        do {
            // Charge l'état actuel du compte bancaire depuis la base de données
            let bankAccount = try PiggyBankServerDataStorageService.shared.getBankAccountDTO(selectedAccountId: selectedBankAccountID)
            
            guard (theCurrency == bankAccount.getCurrency()) else { throw PiggyBankError.inconsistentCurrency }
            if ( (bankAccount.getOverdraftAuthorization()==1) && (Int((bankAccount.getAccountBalance() - thePaymentAmount)) < Int(bankAccount.getOverdraftLimit())) ) { throw PiggyBankError.insufficientOverdraftLimitExceeded }
            if ( (bankAccount.getOverdraftAuthorization()==0) && (bankAccount.getAccountBalance() < thePaymentAmount) )                       {
                throw PiggyBankError.insufficientAccountBalance(message:"You would need \(thePaymentAmount - bankAccount.getAccountBalance()) more \(bankAccount.getCurrency()) on your account")
            }

            let bankAccountAmount = bankAccount.getAccountBalance() - thePaymentAmount
            let newBankAccountDTO = bankAccount.setAccountBalance(newAccountBalance: Float64(Float(bankAccountAmount)))
            let oldBankAccountDTO = bankAccountsDTO.filter(accountId == selectedBankAccountID)
            try db.run(oldBankAccountDTO.delete())
            
            try db.run(bankAccountsDTO.insert (
                accountId <- selectedBankAccountID,
                firstName <- newBankAccountDTO.getAccountOwnerFirstName(),
                lastName <- newBankAccountDTO.getAccountOwnerLastName(),
                accountBalance <- newBankAccountDTO.getAccountBalance(),
                currency <- newBankAccountDTO.getCurrency(),
                isOverdraftAllowed <- newBankAccountDTO.getOverdraftAuthorization(),
                overDraftLimit <- newBankAccountDTO.getOverdraftLimit()
            ))
            
            print("Paiement d'un montant de \(thePaymentAmount) \(theCurrency) realisé avec succès à partir du compte \(String(describing: accountId))")
            print("Nouveau solde : \(newBankAccountDTO.getAccountBalance())")
            return try getBankAccountDTO(selectedAccountId: selectedBankAccountID)
                
        }
        catch let error {
            throw error
        }
        
    }
    
    func addMoney(selectedBankAccountID: String, thePaymentAmount: Float64, theCurrency: String) throws -> BankAccountDTO {
        
        //let date = Date(timeIntervalSinceNow: 0)
        
        do {
            // Charge l'état actuel du compte bancaire depuis la base de données
            let bankAccount = try PiggyBankServerDataStorageService.shared.getBankAccountDTO(selectedAccountId: selectedBankAccountID)
            
            guard (theCurrency == bankAccount.getCurrency()) else { throw PiggyBankError.inconsistentCurrency }
            if thePaymentAmount > 100000 { throw PiggyBankError.abnormallyHighSum }

            let bankAccountAmount = bankAccount.getAccountBalance() + thePaymentAmount
            let newBankAccountDTO = bankAccount.setAccountBalance(newAccountBalance: Float64(Float(bankAccountAmount)))
            let oldBankAccountDTO = bankAccountsDTO.filter(accountId == selectedBankAccountID)
            try db.run(oldBankAccountDTO.delete())
            
            try db.run(bankAccountsDTO.insert (
                accountId <- selectedBankAccountID,
                firstName <- newBankAccountDTO.getAccountOwnerFirstName(),
                lastName <- newBankAccountDTO.getAccountOwnerLastName(),
                accountBalance <- newBankAccountDTO.getAccountBalance(),
                currency <- newBankAccountDTO.getCurrency(),
                isOverdraftAllowed <- newBankAccountDTO.getOverdraftAuthorization(),
                overDraftLimit <- newBankAccountDTO.getOverdraftLimit()
            ))
            
            print("L'ajout d'un montant de \(thePaymentAmount) \(theCurrency) realisé avec succès à partir du compte \(String(describing: accountId))")
            print("Nouveau solde : \(newBankAccountDTO.getAccountBalance())")
            return try getBankAccountDTO(selectedAccountId: selectedBankAccountID)
                
        }
        catch {
            throw PiggyBankError.unknownAccount
        }
        
    }
    
    
    func transferMoney(senderBankAccountID: String, recipientBankAccountID: String, thePaymentAmount: Float64/*, theCurrency: String*/) throws -> BankAccountDTO {
        
        do {
            // Charge l'état actuel du compte bancaire depuis la base de données
            let recipientBankAccountDTO = try PiggyBankServerDataStorageService.shared.getBankAccountDTO(selectedAccountId: recipientBankAccountID)
            let senderBankAccountDTO = try PiggyBankServerDataStorageService.shared.getBankAccountDTO(selectedAccountId: senderBankAccountID)
            let convertedPaymentAmount = try PiggyBankService.shared.moneyConvertor(amount: thePaymentAmount, oldCurrency: senderBankAccountDTO.getCurrency(), newCurrency: recipientBankAccountDTO.getCurrency())
            //let convertedPaymentAmount = Float64(100)
            if ( (senderBankAccountDTO.getOverdraftAuthorization()==1) && (Int((senderBankAccountDTO.getAccountBalance() - convertedPaymentAmount)) < Int(senderBankAccountDTO.getOverdraftLimit())) ) { throw PiggyBankError.insufficientOverdraftLimitExceeded }
            if ( (senderBankAccountDTO.getOverdraftAuthorization()==0) && (senderBankAccountDTO.getAccountBalance() < thePaymentAmount) )                       {
                throw PiggyBankError.insufficientAccountBalance(message:"You would need \(thePaymentAmount - senderBankAccountDTO.getAccountBalance()) more \(senderBankAccountDTO.getCurrency()) on your account")
            }
            if thePaymentAmount > 100000 { throw PiggyBankError.abnormallyHighSum }

            let senderBankAccountAmount = senderBankAccountDTO.getAccountBalance() - thePaymentAmount
            //let gougougaga = 10000
            let newSenderBankAccountDTO = senderBankAccountDTO.setAccountBalance(newAccountBalance: Float64(Float(senderBankAccountAmount)))
            let oldSenderBankAccountDTO = bankAccountsDTO.filter(accountId == senderBankAccountID)
            try db.run(oldSenderBankAccountDTO.delete())
            
            try db.run(bankAccountsDTO.insert (
                accountId <- senderBankAccountID,
                firstName <- newSenderBankAccountDTO.getAccountOwnerFirstName(),
                lastName <- newSenderBankAccountDTO.getAccountOwnerLastName(),
                accountBalance <- newSenderBankAccountDTO.getAccountBalance(),
                currency <- newSenderBankAccountDTO.getCurrency(),
                isOverdraftAllowed <- newSenderBankAccountDTO.getOverdraftAuthorization(),
                overDraftLimit <- newSenderBankAccountDTO.getOverdraftLimit()
            ))
            
             let recipientBankAccountAmount = recipientBankAccountDTO.getAccountBalance() + convertedPaymentAmount
            let newRecipientBankAccountDTO = recipientBankAccountDTO.setAccountBalance(newAccountBalance: Float64(Float(recipientBankAccountAmount)))
            let oldRecipientBankAccountDTO = bankAccountsDTO.filter(accountId == recipientBankAccountID)
            try db.run(oldRecipientBankAccountDTO.delete())
            
            try db.run(bankAccountsDTO.insert (
                accountId <- recipientBankAccountID,
                firstName <- newRecipientBankAccountDTO.getAccountOwnerFirstName(),
                lastName <- newRecipientBankAccountDTO.getAccountOwnerLastName(),
                accountBalance <- newRecipientBankAccountDTO.getAccountBalance(),
                currency <- newRecipientBankAccountDTO.getCurrency(),
                isOverdraftAllowed <- newRecipientBankAccountDTO.getOverdraftAuthorization(),
                overDraftLimit <- newRecipientBankAccountDTO.getOverdraftLimit()
            ))
            
            try db.run(transactions.insert(
                transactionID <- UUID().uuidString,
                transactionSenderBankAccountID <- senderBankAccountID,
                transactionRecipientAccountID <- recipientBankAccountID,
                transactionPaymentAmount <- convertedPaymentAmount,
                transactionCurrency <- recipientBankAccountDTO.getCurrency(),
                transactionDate <- Int64(NSDate().timeIntervalSince1970)
            ))
             
            print("Nouveau solde de l'envoyeur : \(newSenderBankAccountDTO.getAccountBalance())")
            return (try getBankAccountDTO(selectedAccountId: senderBankAccountID))
                
        }
        catch let error as PiggyBankError {
           // If the error is already a PiggyBank error (ie thrown by our code), we re-throw it as-is
           throw error
        }
        catch {
            throw PiggyBankError.technicalError
        }
        
    }
    
    
    /*public func updateAccountBalanceInDb(selectedBankAccountID: String, paymentAmount: Float, theCurrency: String) throws -> BankAccountDTO {
        
        do {
            
            let bankAccountDTO = bankAccountsDTO.filter(accountId == selectedBankAccountID)
            let newBankAccountDTO = try PiggyBankService.shared.makePayment(accountId: selectedBankAccountID, thePaymentAmount: Float64(paymentAmount), currency: theCurrency)
            try db.run(bankAccountDTO.delete())
            
            try db.run(bankAccountsDTO.insert (
                accountId <- selectedBankAccountID,
                firstName <- newBankAccountDTO.getAccountOwnerFirstName(),
                lastName <- newBankAccountDTO.getAccountOwnerLastName(),
                accountBalance <- newBankAccountDTO.getAccountBalance(),
                currency <- newBankAccountDTO.getCurrency(),
                isOverdraftAllowed <- newBankAccountDTO.getOverdraftAuthorization(),
                overDraftLimit <- newBankAccountDTO.getOverdraftLimit()
            ))
            
            print("Paiement d'un montant de \(paymentAmount) \(theCurrency) realisé avec succès à partir du compte \(String(describing: accountId))")
            print("Nouveau solde : \(newBankAccountDTO.getAccountBalance())")
            return try getBankAccountDTO(selectedAccountId: selectedBankAccountID)
            
        }
        catch {
            throw PiggyBankError.technicalError
        }
                                         
       //replace(selectedBankAccountDTO.getAccountBalance(), with: PiggyBankService().makePayment(accountId: selectedAccountID, thePaymentAmount: paymentAmount))
    }*/

    ///
    ///
    ///
    func loadBankAccount(accountId: String) -> BankAccountDTO? {
        return BankAccountDTO(theAccountId: accountId, theAmount: 0, theCurrency: "EUR", theFirstName: "TonPrenom", theLastName: "TonNom")
    }
    
    func storeBankAccount(accountToBeStored: BankAccountDTO) {
        
    }
    
    
    
    
    
    //
    //
    // SINGLETON
    //
    //
    
    public static var shared = PiggyBankServerDataStorageService()  // BigModel(shouldInjectMockedData:true)


}


