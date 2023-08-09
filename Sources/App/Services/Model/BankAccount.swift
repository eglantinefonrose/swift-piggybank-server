//
//  BankAccount.swift
//  PiggyBankCLI
//
//  Created by Eglantine Fonrose on 02/07/2023.
//

import Foundation
import Vapor

/// DTO for the BankAccount class
public struct BankAccountDTO : Content {
    var firstName: String
    var lastName: String
    var accountId: String
    var accountBalance: Float
    var currency: String
    var isOverdraftAllowed: Bool
    var overDraftLimit: Float?
}



public class BankAccount {
    
    private var firstName: String
    private var lastName: String
    private var accountId: String
    private var accountBalance: Float
    private var currency: String
    private var isOverdraftAllowed: Bool
    private var overDraftLimit: Float?

    
    /// Construtor (for Accounts without Overdraft)
    public convenience init (theAccountId: String, theAmount: Float, theCurrency: String, theFirstName: String, theLastName: String) throws {
        try self.init(theAccountId: theAccountId, theAmount: theAmount, theCurrency: theCurrency, theFirstName: theFirstName, theLastName: theLastName, isOverdraftAllowed: false, theOverDraftLimit: nil)
    }

    /// Construtor
    public init (theAccountId: String, theAmount: Float, theCurrency: String, theFirstName: String, theLastName: String, isOverdraftAllowed: Bool, theOverDraftLimit: Float?) throws {
        self.accountId = theAccountId
        self.accountBalance = theAmount
        self.firstName = theFirstName
        self.lastName = theLastName
        self.currency = theCurrency
        self.isOverdraftAllowed = isOverdraftAllowed
        self.overDraftLimit = theOverDraftLimit
        
        if ( (isOverdraftAllowed) && (theOverDraftLimit == nil) ) { throw PiggyBankError.overDraftLimitUndefined }
        if ( (isOverdraftAllowed) && (theOverDraftLimit! > 0) )   { throw PiggyBankError.overDraftMustBeNegative }
    }

    /// Build a DTO for this object
    public func getBankAccountDTO() -> BankAccountDTO {
        return BankAccountDTO(firstName: self.firstName, lastName: self.lastName, accountId: self.accountId, accountBalance: self.accountBalance, currency: self.currency, isOverdraftAllowed: self.isOverdraftAllowed, overDraftLimit: self.overDraftLimit)
    }
    
    /// Add the amount specified to the balance of the account
    public func addAmount(theAmount: Float, theCurrency: String) throws {
        guard (theCurrency == self.currency) else { throw PiggyBankError.inconsistentCurrency }
        
        self.accountBalance = self.accountBalance + theAmount
    }
    
    public func makePayment(thePaymentAmount: Float, theCurrency: String) throws {
        guard (theCurrency == self.currency) else { throw PiggyBankError.inconsistentCurrency }
        if ( (self.isOverdraftAllowed==true) && ((self.accountBalance-thePaymentAmount) < self.overDraftLimit!) ) { throw PiggyBankError.insufficientOverdraftLimitExceeded }
        if ( (self.isOverdraftAllowed==false) && (self.accountBalance < thePaymentAmount) )                       {
            throw PiggyBankError.insufficientAccountBalance(message:"You would need \(thePaymentAmount-self.accountBalance) more \(self.currency) on your account")
        }

        self.accountBalance = self.accountBalance - thePaymentAmount
    }
    
    //
    // Property accessors
    //
    
    public func getAccountOwnerName() -> String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    public func getAccountBalance() -> Float {
        return self.accountBalance
    }
    
    public func getCurrency() -> String {
        return self.currency
    }

    public func getAccountBalanceWithCurrency() -> String {
        return "\(self.accountBalance) \(self.currency)"
    }

}




enum PiggyBankError: Error {
    case inconsistentCurrency
    case insufficientAccountBalance(message: String)
    case insufficientOverdraftLimitExceeded
    case overDraftLimitUndefined
    case overDraftMustBeNegative
}
