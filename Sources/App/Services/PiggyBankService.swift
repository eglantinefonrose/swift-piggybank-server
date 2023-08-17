//
//  File.swift
//  
//
//  Created by Eglantine Fonrose on 09/08/2023.
//

import Foundation


public struct PiggyBankService {
    
    ///
    ///
    /// throws
    ///     case accountAlreadyExists
    ///
    func createBankAccount(accountId: String, amount: Float, currency: String, firstName: String, lastName: String) throws -> BankAccountDTO {
        return try createBankAccount(accountId: accountId, amount: amount, currency: currency, firstName: firstName, lastName: lastName, isOverdraftAllowed: 0, overDraftLimit: nil)
    }

    ///
    /// throws
    ///     case accountAlreadyExists
    ///     case overDraftLimitUndefined
    ///     case overDraftMustBeNegative
    ///
    func createBankAccount(accountId: String, amount: Float, currency: String, firstName: String, lastName: String, isOverdraftAllowed: Int, overDraftLimit: Float?) throws -> BankAccountDTO {
        
        if ( (isOverdraftAllowed == 1) && (overDraftLimit == nil) )                                     { throw PiggyBankError.overDraftLimitUndefined }
        if ( (isOverdraftAllowed == 1) && (overDraftLimit! > 0) )                                       { throw PiggyBankError.overDraftMustBeNegative }
        if (PiggyBankServerDataStorageService.shared.loadBankAccount(accountId: accountId) != nil) { throw PiggyBankError.accountAlreadyExists }
            
        let theNewBankAccount = BankAccountDTO(theAccountId: accountId, theAmount: Float64(amount), theCurrency: currency, theFirstName: firstName, theLastName: lastName, isOverdraftAllowed: isOverdraftAllowed, theOverDraftLimit: overDraftLimit);
        PiggyBankServerDataStorageService.shared.storeBankAccount(accountToBeStored: theNewBankAccount)
        return theNewBankAccount

    }

    
    
    
    // Permet la réalisation d'un paiement depuis un compte bancaire
    /*func makePayment(accountId:String, amount:Float, currency:String) throws -> BankAccountDTO {

        let timeEpoch = Int(NSDate().timeIntervalSince1970)
        let date = Date(timeIntervalSinceNow: 0)
        
        print("Virement effectué pour un montant de [\(amount) \(currency)] vers le compte [\(accountId)] at [\(date)]/[\(timeEpoch)]");

        do {
            // Charge l'état actuel du compte bancaire depuis la base de données
            if let bankAccount = PiggyBankServerDataStorageService.shared.loadBankAccount(accountId: accountId) {
                // Effectue le virement
                let bankAccount = try BankAccountDTO(theAccountId:accountId, theAmount: amount, theCurrency:currency, theFirstName: "", theLastName: "")
                
                // Stocke le résultat dans la base
                PiggyBankServerDataStorageService.shared.storeBankAccount(accountToBeStored: bankAccount)
                
                // Renvoie le nouvel état du compte bancaire à l'appelant
                return bankAccount
            } else {
                print("unknown account")
                throw PiggyBankError.unknownAccount
            }
            
        }

    }*/
    
    
    func makePayment(accountId: String, thePaymentAmount: Float64, currency: String) throws -> BankAccountDTO {
        
        let date = Date(timeIntervalSinceNow: 0)
        
        do {
            // Charge l'état actuel du compte bancaire depuis la base de données
            let bankAccount = try PiggyBankServerDataStorageService.shared.getBankAccountDTO(selectedAccountId: accountId)
            
            guard (currency == bankAccount.getCurrency()) else { throw PiggyBankError.inconsistentCurrency }
            if ( (bankAccount.getOverdraftAuthorization()==1) && (Int((bankAccount.getAccountBalance() - thePaymentAmount)) < Int(bankAccount.getOverdraftLimit())) ) { throw PiggyBankError.insufficientOverdraftLimitExceeded }
            if ( (bankAccount.getOverdraftAuthorization()==0) && (bankAccount.getAccountBalance() < thePaymentAmount) )                       {
                throw PiggyBankError.insufficientAccountBalance(message:"You would need \(thePaymentAmount - bankAccount.getAccountBalance()) more \(bankAccount.getCurrency()) on your account")
            }

            let bankAccountAmount = bankAccount.getAccountBalance() - thePaymentAmount
            let newBankAccountDTO = bankAccount.setAccountBalance(newAccountBalance: Float64(Float(bankAccountAmount)), bankAccountDTO: bankAccount)
            
            return newBankAccountDTO
                
        }
        catch {
            throw PiggyBankError.unknownAccount
        }
        
    }
    
    
    
    //
    //
    // IMPLEMENTATION
    //
    //
    
//    /// Add the amount specified to the balance of the account
//    private func addAmount(theAmount: Float, theCurrency: String) throws {
//        guard (theCurrency == self.currency) else { throw PiggyBankError.inconsistentCurrency }
//
//        self.accountBalance = self.accountBalance + theAmount
//    }
//
//    private func makePayment(thePaymentAmount: Float, theCurrency: String) throws {
//        guard (theCurrency == self.currency) else { throw PiggyBankError.inconsistentCurrency }
//        if ( (self.isOverdraftAllowed==true) && ((self.accountBalance-thePaymentAmount) < self.overDraftLimit!) ) { throw PiggyBankError.insufficientOverdraftLimitExceeded }
//        if ( (self.isOverdraftAllowed==false) && (self.accountBalance < thePaymentAmount) )                       {
//            throw PiggyBankError.insufficientAccountBalance(message:"You would need \(thePaymentAmount-self.accountBalance) more \(self.currency) on your account")
//        }
//
//        self.accountBalance = self.accountBalance - thePaymentAmount
//    }
    
    
    
    
    
    
    //
    //
    // SINGLETON
    //
    //
    
    public static var shared = PiggyBankService()  // PiggyBankService(shouldInjectMockedData:true)


}
