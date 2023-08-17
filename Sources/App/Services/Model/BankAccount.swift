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
    private var accountBalance: Float
    private var currency: String
    private var isOverdraftAllowed: Int
    private var overDraftLimit: Float?

    
    /// Construtor (for Accounts without Overdraft)
    public init (theAccountId: String, theAmount: Float, theCurrency: String, theFirstName: String, theLastName: String) {
        self.init(theAccountId: theAccountId, theAmount: theAmount, theCurrency: theCurrency, theFirstName: theFirstName, theLastName: theLastName, isOverdraftAllowed: 0, theOverDraftLimit: nil)
    }

    /// Construtor
    public init (theAccountId: String, theAmount: Float, theCurrency: String, theFirstName: String, theLastName: String, isOverdraftAllowed: Int, theOverDraftLimit: Float?) {
        self.accountId = theAccountId
        self.accountBalance = theAmount
        self.firstName = theFirstName
        self.lastName = theLastName
        self.currency = theCurrency
        self.isOverdraftAllowed = isOverdraftAllowed
        self.overDraftLimit = theOverDraftLimit
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
    
    public func getOverdraftAuthorization() -> Int {
        return self.isOverdraftAllowed
    }
    
    public func getOverdraftLimit() -> Float {
        return self.overDraftLimit ?? 0
    }

    public func getAccountBalanceWithCurrency() -> String {
        return "\(self.accountBalance) \(self.currency)"
    }
    
    public func setAccountBalance(newAccountBalance: Float, bankAccountDTO: BankAccountDTO) -> BankAccountDTO {
        var newBankAccountDTO: BankAccountDTO = BankAccountDTO(theAccountId: "", theAmount: 0, theCurrency: "", theFirstName: "", theLastName: "", isOverdraftAllowed: 0, theOverDraftLimit: 0)
        newBankAccountDTO.firstName = bankAccountDTO.firstName
        newBankAccountDTO.lastName = bankAccountDTO.lastName
        newBankAccountDTO.accountId = bankAccountDTO.accountId
        newBankAccountDTO.accountBalance = bankAccountDTO.accountBalance
        newBankAccountDTO.currency = bankAccountDTO.currency
        newBankAccountDTO.isOverdraftAllowed = bankAccountDTO.isOverdraftAllowed
        newBankAccountDTO.overDraftLimit = bankAccountDTO.overDraftLimit
        return newBankAccountDTO
    }

}




enum PiggyBankError: Error {
    case accountAlreadyExists
    case unknownAccount
    case inconsistentCurrency
    case insufficientAccountBalance(message: String)
    case insufficientOverdraftLimitExceeded
    case overDraftLimitUndefined
    case overDraftMustBeNegative
    
    case technicalError
}
