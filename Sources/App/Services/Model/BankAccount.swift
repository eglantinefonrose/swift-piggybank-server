//
//  BankAccount.swift
//  PiggyBankCLI
//
//  Created by Eglantine Fonrose on 02/07/2023.
//

import Foundation
import Vapor



public struct BankAccountDTO : Content {
    
    private var firstName: String
    private var lastName: String
    private var accountId: String
    private var accountBalance: Float64
    private var currency: String
    private var isOverdraftAllowed: Int64
    private var overDraftLimit: Float64?

    
    /// Construtor (for Accounts without Overdraft)
    public init (theAccountId: String, theAmount: Float, theCurrency: String, theFirstName: String, theLastName: String) {
        self.init(theAccountId: theAccountId, theAmount: Float64(theAmount), theCurrency: theCurrency, theFirstName: theFirstName, theLastName: theLastName, isOverdraftAllowed: 0, theOverDraftLimit: nil)
    }

    /// Construtor
    public init (theAccountId: String, theAmount: Float64, theCurrency: String, theFirstName: String, theLastName: String, isOverdraftAllowed: Int64, theOverDraftLimit: Float64?) {
        self.accountId = theAccountId
        self.accountBalance = theAmount
        self.firstName = theFirstName
        self.lastName = theLastName
        self.currency = theCurrency
        self.isOverdraftAllowed = Int64(isOverdraftAllowed)
        self.overDraftLimit = ((isOverdraftAllowed == 1) ? theOverDraftLimit : nil);
    }
    

    
    //
    // Property accessors
    //
    
    public func getAccountAccountId() -> String {
        return self.accountId
    }
    
    public func getAccountOwnerFirstName() -> String {
        return self.firstName
    }
    
    public func getAccountOwnerLastName() -> String {
        return self.lastName
    }
    
    public func getAccountBalance() -> Float64 {
        return self.accountBalance
    }
    
    public func getCurrency() -> String {
        return self.currency
    }
    
    public func getOverdraftAuthorization() -> Int64 {
        return self.isOverdraftAllowed
    }
    
    public func getOverdraftLimit() -> Float64? {
        return self.overDraftLimit
    }
    
    public func getOverdraftLimitOrDefaultTo0() -> Float64 {
        return Float64(self.overDraftLimit ?? 0)
    }

    public func getAccountBalanceWithCurrency() -> String {
        return "\(self.accountBalance) \(self.currency)"
    }
    
    public mutating func setAccountBalance(newAccountBalance: Float64) {
        self.accountBalance = newAccountBalance
    }

}




enum PiggyBankError: Error {
    case accountAlreadyExists
    case unknownAccount
    case inconsistentCurrency
    case differentCurrenciesInTransfer
    case insufficientAccountBalance(message: String)
    case insufficientOverdraftLimitExceeded
    case overDraftLimitUndefined
    case overDraftMustBeNegative
    case abnormallyHighSum
    case unknownCurrency
    
    case technicalError
    case invalidParameters(message: String)
}
