//
//  File.swift
//  
//
//  Created by Eglantine Fonrose on 29/08/2023.
//

import Foundation
import Vapor


public struct TransactionDTO: Content {
    
    private var id: String
    private var senderAccountID: String
    private var recipientAccountID: String
    private var amount: Float64
    private var currency: String
    private var date: Int64
    
    public init (theId: String, theSenderAccountID: String, theRecipientAccountID: String, theAmount: Float64, theCurrency: String, theDate: Int64) {
        self.id = theId
        self.senderAccountID = theSenderAccountID
        self.recipientAccountID = theRecipientAccountID
        self.amount = theAmount
        self.currency = theCurrency
        self.date = theDate
    }
    
    public func getTransactionID() -> String {
        return self.id
    }
    
    public func getTransactionSenderAccountID() -> String {
        return self.senderAccountID
    }
    
    public func getTransactionRecipientAccountID() -> String {
        return self.recipientAccountID
    }
    
    public func getTransactionAmount() -> Float64 {
        return self.amount
    }
    
    public func getTransactionCurrency() -> String {
        return self.currency
    }
    
    public func getTransactionDate() -> Int64 {
        return self.date
    }
    
}
