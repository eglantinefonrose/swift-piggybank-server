//
//  File.swift
//  
//
//  Created by Eglantine Fonrose on 09/08/2023.
//

import Foundation
import SQLite

class PiggyBankServerDataStorageService {
    
    private var dbConnection: Connection!
    
    private var bankAccountsTable: Table!
    private var accountIdColumn: Expression<String>!
    private var firstNameColumn: Expression<String>!
    private var lastNameColumn: Expression<String>!
    private var accountBalanceColumn: Expression<Float64>!
    private var currencyColumn: Expression<String>!
    private var isOverdraftAllowedColumn: Expression<Int64>!
    private var overDraftLimitColumn: Expression<Float64>!
    
    private var transactionsTable: Table!
    private var transactionSenderBankAccountIDColumn: Expression<String>!
    private var transactionRecipientAccountIDColumn: Expression<String>!
    private var transactionPaymentAmountColumn: Expression<Float64>!
    private var transactionCurrencyColumn: Expression<String>!
    private var transactionIDColumn: Expression<String>!
    private var transactionDateColumn: Expression<Int64>!

    

    /**
     Fetch the information for an account from the database
     
     throws
        case PiggyBankError.unknownAccount
        case PiggyBankError.technicalError
        case PiggyBankError.PiggyBankError
     */
    public func getBankAccountInfo(accountId:String) throws -> BankAccountDTO {
        do {
            // Requête pour récupérer la ligne où le champ "accountId" vaut "accountId"
            let query = bankAccountsTable.filter(self.accountIdColumn == accountId)
            
            // Exécution de la requête et récupération du résultat
            if let row = try dbConnection.pluck(query) {
                let bankAccountID = row[accountIdColumn]
                let bankAccountFirstName = row[firstNameColumn]
                let bankAccountLastName = row[lastNameColumn]
                let bankAccountAmount = row[accountBalanceColumn]
                let bankAccountCurrency = row[currencyColumn]
                let bankAccountisOverdraftAllowed = row[isOverdraftAllowedColumn]
                let bankAccounttheOverDraftLimit = row[overDraftLimitColumn]
                
                let bankAccountDTO = BankAccountDTO(theAccountId: bankAccountID, theAmount: Float64(Float(bankAccountAmount)), theCurrency: bankAccountCurrency, theFirstName: bankAccountFirstName, theLastName: bankAccountLastName, isOverdraftAllowed: Int64(bankAccountisOverdraftAllowed), theOverDraftLimit: Float64(bankAccounttheOverDraftLimit))
                
                return bankAccountDTO
            } else {
                throw PiggyBankError.unknownAccount
            }
        } catch let error as PiggyBankError {
            // If the error is already a PiggyBank error (ie thrown by our code), we re-throw it as-is
            throw error
        } catch {
            // If the error is any other error, we throw a 'PiggyBankError.technicalError'
            print("PiggyBankServerDataStorageService.getBankAccountInfo - Erreur technique [\(error)]")
            throw PiggyBankError.technicalError
        }
    }
  
    
    /**
     Store the data for an account into the database
     */
    func storeBankAccountInfo(accountToBeStored: BankAccountDTO) throws {
        
        do {
            print("PiggyBankServerDataStorageService.storeBankAccountInfo - accountId[\(accountToBeStored.getAccountAccountId())] ...");
            try dbConnection.run(bankAccountsTable.insert (
                accountIdColumn <- accountToBeStored.getAccountAccountId(),
                firstNameColumn <- accountToBeStored.getAccountOwnerFirstName(),
                lastNameColumn <- accountToBeStored.getAccountOwnerLastName(),
                accountBalanceColumn <- accountToBeStored.getAccountBalance(),
                currencyColumn <- accountToBeStored.getCurrency(),
                isOverdraftAllowedColumn <- accountToBeStored.getOverdraftAuthorization(),
                overDraftLimitColumn <- accountToBeStored.getOverdraftLimit()
            ))
            print("  -> DONE (account storage for accountId[\(accountToBeStored.getAccountAccountId())]");
        }
        catch {
            throw PiggyBankError.technicalError
        }
        
    }
  
    
    /**
     Get all the transactions
     */
    public func getAllTransactions(accountId:String, currency: String) throws -> [TransactionDTO] {
        
        do {
            var transactionsList : [TransactionDTO] = []

            // Requête pour récupérer la ligne où le champ "accountId" est "selectedAccountId"
            let query = transactionsTable
                //.filter(transactionSenderBankAccountID == selectedAccountId)
                .filter(transactionRecipientAccountIDColumn == accountId || transactionSenderBankAccountIDColumn == accountId)
                .order(transactionDateColumn.desc)
            
            // Exécution de la requête et récupération du résultat
            for row in try dbConnection.prepare(query) {
                let transactionID = row[transactionIDColumn]
                let transactionSenderBankAccountID = row[transactionSenderBankAccountIDColumn]
                let transactionRecipientBankAccountID = row[transactionRecipientAccountIDColumn]
                let transactionCurrency = currency
                let transactionPaymentAmount = try PiggyBankService.shared.convertCurrency(amount: row[transactionPaymentAmountColumn], fromCurrency: transactionCurrency, toCurrency: currency)
                let transactionDate = row[transactionDateColumn]
                
                transactionsList.append(TransactionDTO(theId: transactionID, theSenderAccountID: transactionSenderBankAccountID, theRecipientAccountID: transactionRecipientBankAccountID, theAmount: transactionPaymentAmount, theCurrency: transactionCurrency, theDate: transactionDate))
            }
            
            return transactionsList
            
        } catch let error as PiggyBankError {
            // If the error is already a PiggyBank error (ie thrown by our code), we re-throw it as-is
            throw error
        } catch {
            // If the error is any other error, we throw a 'PiggyBankError.technicalError'
            throw PiggyBankError.technicalError
        }

    }



    
    

    
    
    //
    //
    // DATABASE LOCKING METHODS
    //
    //

    /**
     Obtient un lock sur le BankAccount accountId
     */
    func getLockOnBankAccountInfo(accountId: String) throws {
        // On ne fait rien ici pour l'instant
    }

    /**
     Libère le lock sur le BankAccount accountId
     */
    func releaseLockOnBankAccountInfo(accountId: String) throws {
        // On ne fait rien ici pour l'instant
    }

    
    

    
    
    //
    //
    // DATABASE INITIALIZATION METHODS
    //
    //

    private func injectDataInTables() {
        if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
            do {
                try dbConnection.run(bankAccountsTable.create { (t) in
                    t.column(accountIdColumn, primaryKey: true)
                    t.column(firstNameColumn)
                    t.column(lastNameColumn)
                    t.column(accountBalanceColumn)
                    t.column(currencyColumn)
                    t.column(isOverdraftAllowedColumn)
                    t.column(overDraftLimitColumn)
                })
                
                try dbConnection.run(bankAccountsTable.insert (
                    accountIdColumn <- "58540395859",
                    firstNameColumn <- "Malo",
                    lastNameColumn <- "Fonrose",
                    accountBalanceColumn <- 0,
                    currencyColumn <- "EUR",
                    isOverdraftAllowedColumn <- 0,
                    overDraftLimitColumn <- 0
                ))
                
                try dbConnection.run(bankAccountsTable.insert (
                    accountIdColumn <- "38469403805",
                    firstNameColumn <- "Eglantine",
                    lastNameColumn <- "Fonrose",
                    accountBalanceColumn <- 0,
                    currencyColumn <- "EUR",
                    isOverdraftAllowedColumn <- 0,
                    overDraftLimitColumn <- 0
                ))
            } catch {
                print("Failed to inject data in the database with message=[\(error.localizedDescription)]")
            }

            // Stocke le fait que la base a été initialisée
            UserDefaults.standard.set(true, forKey: "is_db_created")
        }
    }

    
    

    
    
    //
    //
    // SINGLETON
    //
    //
    
    public static var shared = PiggyBankServerDataStorageService()

    private init () {
        do {
            dbConnection = try Connection("/Users/eglantine/Dev/0.perso/2.Proutechos/0.PiggyBank/0.PiggyBank/PiggyDataBase.db")
            
            bankAccountsTable = Table("BankAccountDTO")
            accountIdColumn = Expression<String>("accountId")
            firstNameColumn = Expression<String>("firstName")
            lastNameColumn = Expression<String>("lastName")
            accountBalanceColumn = Expression<Float64>("accountBalance")
            currencyColumn = Expression<String>("currency")
            isOverdraftAllowedColumn = Expression<Int64>("isOverdraftAllowed")
            overDraftLimitColumn = Expression<Float64>("overdraftLimit")
            
            transactionsTable = Table("Transactions")
            transactionIDColumn = Expression<String>("id")
            transactionSenderBankAccountIDColumn = Expression<String>("senderAccountID")
            transactionRecipientAccountIDColumn = Expression<String>("recipientAccountID")
            transactionPaymentAmountColumn = Expression<Float64>("amount")
            transactionCurrencyColumn = Expression<String>("currency")
            transactionDateColumn = Expression<Int64>("date")

            print("-- dbmanager init --")
        }
        catch {
            print(error.localizedDescription)
        }
    }


}


