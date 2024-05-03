//
//  File.swift
//  
//
//  Created by Eglantine Fonrose on 09/08/2023.
//

import Foundation


public struct PiggyBankService {
    
    /**
     Create a new BankAccount (without authorization for overdrafts)
     
     throws
         PiggyBankError.overDraftLimitUndefined
         PiggyBankError.overDraftMustBeNegative
         PiggyBankError.accountAlreadyExists
     */
    func createBankAccount(accountId: String, amount: Float, currency: String, firstName: String, lastName: String) throws -> BankAccountDTO {
        
        // Define the default parameters
        let isOverdraftAllowed: Int64 = 0;
        let overdraftLimit: Float64? = nil;
        
        // Create the account
        return try createBankAccount(accountId: accountId, amount: amount, currency: currency, firstName: firstName, lastName: lastName, isOverdraftAllowed: isOverdraftAllowed, overdraftLimit: overdraftLimit)
        
    }
    
    
   /**
    Create a new BankAccount
    
    throws
        PiggyBankError.overDraftLimitUndefined
        PiggyBankError.overDraftMustBeNegative
        PiggyBankError.accountAlreadyExists
    */
    func createBankAccount(accountId: String, amount: Float, currency: String, firstName: String, lastName: String, isOverdraftAllowed: Int64, overdraftLimit: Float64?) throws -> BankAccountDTO {
            
        // Vérifie les prérequis
        if ( (isOverdraftAllowed == 1) && (overdraftLimit == nil) )                                { throw PiggyBankError.overDraftLimitUndefined }
        if ( (isOverdraftAllowed == 1) && (overdraftLimit! > 0) )                                  { throw PiggyBankError.overDraftMustBeNegative }
        do {
            // Teste si un compte avec cet ID existe déjà. Si l'appel 'getBankAccountInfo' reussi, on doit envoyer l'exception 'PiggyBankError.accountAlreadyExists'
            let _ = try PiggyBankServerDataStorageService.shared.getBankAccountInfo(accountId: accountId)
            throw PiggyBankError.accountAlreadyExists
        } catch {
            // On ne fait rien ici, puisque ça veut dire que "tout va bien" (ie un compte avec ce id n'existe pas déjà)
        }
        
        // Crée le nouveau compte
        let theNewBankAccount = BankAccountDTO(theAccountId: accountId, theAmount: Float64(amount), theCurrency: currency, theFirstName: firstName, theLastName: lastName, isOverdraftAllowed: isOverdraftAllowed, theOverDraftLimit: overdraftLimit);
        PiggyBankServerDataStorageService.shared.storeBankAccountInfo(accountToBeStored: theNewBankAccount)
        
        return theNewBankAccount
        
    }


    /**
     Make a payment to an entity outside the bank (which is why we don't have a 'toBankAccountID' parameter)
     
     throws
        PiggyBankError.inconsistentCurrency
        PiggyBankError.insufficientOverdraftLimitExceeded
        PiggyBankError.insufficientAccountBalance
     */
    func makePayment(fromBankAccountID: String, forAnAmountOf amount: Float64, withCurrency currency: String) throws -> BankAccountDTO {
    
        // Charge l'état actuel du compte bancaire depuis la base de données
        var bankAccount = try PiggyBankServerDataStorageService.shared.getBankAccountInfo(accountId: fromBankAccountID)
        
        // Vérifie les prérequis
        //  - Cohérence de la currency
        guard (currency == bankAccount.getCurrency()) else { throw PiggyBankError.inconsistentCurrency }
        //  - Compte suffisamment alimenté ou découvert autorisé suffisant (ce code renvoie des exceptions en cas de problème)
        try self.assertAccountHasEnoughBalanceOrHasLargeEnoughOverdraftLimit(bankAccount: bankAccount, amount: amount);

        // Retranche le montant du paiement au compte
        bankAccount.setAccountBalance(newAccountBalance: bankAccount.getAccountBalance()-amount)

        // Stocke la modification dans la base
        PiggyBankServerDataStorageService.shared.storeBankAccountInfo(accountToBeStored: bankAccount)
        
        return bankAccount
        
    }

    
    /**
     Make a deposit (which has to be in the currency of the recipient account)
     
     throws
        PiggyBankError.inconsistentCurrency
        PiggyBankError.abnormallyHighSum
     */
    func makeDeposit(toAccount accountId: String, forAnAmountOf amount: Float64, withCurrency currency: String) throws -> BankAccountDTO {
        // Charge l'état actuel du compte bancaire depuis la base de données
        var bankAccount = try PiggyBankServerDataStorageService.shared.getBankAccountInfo(accountId: accountId)
        
        // Vérifie les prérequis
        //  - Cohérence de la currency
        guard (currency == bankAccount.getCurrency()) else { throw PiggyBankError.inconsistentCurrency }
        //  - Limit maximum de dépot
        if amount > 100000 { throw PiggyBankError.abnormallyHighSum }
        
        // Ajoute le montant du paiement au compte
        bankAccount.setAccountBalance(newAccountBalance: bankAccount.getAccountBalance()+amount)

        // Stocke la modification dans la base
        let date = Date(timeIntervalSinceNow: 0)
        PiggyBankServerDataStorageService.shared.storeBankAccountInfo(accountToBeStored: bankAccount)
        print("Ajout d'argent réalisé avec succès d'un montant de \(amount) \(currency) sur le compte \(accountId) à \(date)")

        return bankAccount
    }

    
    /**
     Transfer money from one account to another (inside the Bank)
     
     throws
        PiggyBankError.insufficientOverdraftLimitExceeded
        PiggyBankError.insufficientAccountBalance
     */
    func transferMoney(fromAccountID senderBankAccountID: String, toAccountID recipientBankAccountID: String, forAnAmountOf thePaymentAmount: Float64/*, theCurrency: String*/) throws -> BankAccountDTO {

        // Charge l'état actuel du compte bancaire depuis la base de données
        let fromBankAccount = try PiggyBankServerDataStorageService.shared.getBankAccountInfo(accountId: senderBankAccountID)
        let toBankAccount   = try PiggyBankServerDataStorageService.shared.getBankAccountInfo(accountId: recipientBankAccountID)
        
        // Gère le locking concernant le compte émetteur (pour traiter le cas de requêtes parallèles pour un même compte emetteur)
        //  - Prend un lock sur le compte émetteur
        try PiggyBankServerDataStorageService.shared.getLockOnBankAccountInfo(accountId: senderBankAccountID)
        //  - Déclare le code qui libèrera le lock (à la sortie de la méthode; cf https://www.hackingwithswift.com/new-syntax-swift-2-defer)
        defer {
            do {
                try PiggyBankServerDataStorageService.shared.releaseLockOnBankAccountInfo(accountId: senderBankAccountID)
            } catch let dbError {
                print("MAJOR ERROR - Failed to release lock for account=[\(senderBankAccountID)] with errorMessage=[\(dbError.localizedDescription)]")
            }
        }

        // Vérifier les prérequis (cet appel peut provoquer la sortie de la méthode via 'throw')
        try self.assertAccountHasEnoughBalanceOrHasLargeEnoughOverdraftLimit(bankAccount: fromBankAccount, amount: thePaymentAmount);
        
        do {
            // Calcul le montant dans la devise du compte recepteur
            let convertedPaymentAmount = try PiggyBankService.shared.convertCurrency(amount: thePaymentAmount, fromCurrency: fromBankAccount.getCurrency(), toCurrency: toBankAccount.getCurrency())
            
            // Transfère l'argent entre les comptes
            try self.makePayment(fromBankAccountID: senderBankAccountID, forAnAmountOf: thePaymentAmount, withCurrency: fromBankAccount.getCurrency())
            try self.makeDeposit(toAccount: recipientBankAccountID, forAnAmountOf: thePaymentAmount, withCurrency: fromBankAccount.getCurrency())

            return fromBankAccount
        } catch {
            throw error
        }
        
    }
   
    /**
     Return the BankAccount info
     */
    public func getBankAccountInfo(forAccountId accountId:String) throws -> BankAccountDTO {
        return try PiggyBankServerDataStorageService.shared.getBankAccountInfo(accountId: accountId);
    }
    
    
    /**
     Return the list of Transactions
     */
    public func getAllTransactions(forAccountId accountId:String, withCurrency currency: String) throws -> [TransactionDTO] {
        return try PiggyBankServerDataStorageService.shared.getAllTransactions(accountId: accountId, currency: currency);
    }
    

    
    
    //
    //
    // IMPLEMENTATION
    //
    //
    
    
    /**
     Check that the account has enough balance or has large enough overdraft limit
     
     throws
        PiggyBankError.insufficientOverdraftLimitExceeded
        PiggyBankError.insufficientAccountBalance
     */
    private func assertAccountHasEnoughBalanceOrHasLargeEnoughOverdraftLimit(bankAccount: BankAccountDTO, amount: Float64) throws {
        //  - Montant découvert suffisant (si découvert autorisé)
        if ( (bankAccount.getOverdraftAuthorization()==1) && (Int((bankAccount.getAccountBalance() - amount)) < Int(bankAccount.getOverdraftLimit())) ) {
            throw PiggyBankError.insufficientOverdraftLimitExceeded }
        //  - Montant suffisant sur le compte (si pas de découvert autorisé)
        if ( (bankAccount.getOverdraftAuthorization()==0) && (bankAccount.getAccountBalance() < amount) )                       {
            throw PiggyBankError.insufficientAccountBalance(message:"You would need \(amount - bankAccount.getAccountBalance()) more \(bankAccount.getCurrency()) on your account")
        }

    }

    
    /**
     Convert from one currency to another
     */
    func convertCurrency(amount: Float64, fromCurrency oldCurrency: String, toCurrency newCurrency: String) throws -> Float64 {
        
        if oldCurrency == newCurrency {
            return amount
        }
        if oldCurrency == "EUR" {
            if newCurrency == "USD" {
                return amount*1.09
            }
            if newCurrency == "GBP" {
                return amount*0.86
            }
            if newCurrency == "JPY" {
                return amount*157.84
            }
            if newCurrency == "KRW" {
                print("KRW")
                return amount*14
                //return 3
            }
            else {
                print("unknown old currency")
            }
        }
        if oldCurrency == "KRW" {
            if newCurrency == "EUR" {
                return amount*0.0063
            }
        }
        
        throw PiggyBankError.unknownCurrency
        
    }
    
    
    
    
    //
    //
    // SINGLETON
    //
    //
    
    public static var shared = PiggyBankService()


}
