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


    init () {
        do {
            db = try Connection("/Users/eglantine/Dev/0.perso/2.Proutechos/PiggyBank/PiggyDataBase.db")
            bankAccountsDTO = Table("BankAccountDTO")
            accountId = Expression<String>("accountId")
            firstName = Expression<String>("firstName")
            lastName = Expression<String>("lastName")
            accountBalance = Expression<Float64>("accountBalance")
            currency = Expression<String>("currency")
            isOverdraftAllowed = Expression<Int64>("isOverdraftAllowed")
            overDraftLimit = Expression<Float64>("overdraftLimit")

            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
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

            }

            print("-- dbmanager init --")

        }
        catch {
            print(error.localizedDescription)
        }
    }

    public func getBankAccountDTO(selectedAccountId:String) throws -> BankAccountDTO {

        var bankAccountDTO: BankAccountDTO = BankAccountDTO(theAccountId: "", theAmount: 0, theCurrency: "", theFirstName: "", theLastName: "", isOverdraftAllowed: 0, theOverDraftLimit: 0)
        
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
                
                bankAccountDTO = BankAccountDTO(theAccountId: bankAccountID, theAmount: Float(bankAccountAmount), theCurrency: bankAccountCurrency, theFirstName: bankAccountFirstName, theLastName: bankAccountLastName, isOverdraftAllowed: Int(bankAccountisOverdraftAllowed), theOverDraftLimit: Float(bankAccounttheOverDraftLimit))
                print("firstName \(bankAccountFirstName)")
                
                return bankAccountDTO
                
            } else {
                print("Error - Aucune ligne trouvée avec l'id \(selectedAccountId)")
                throw PiggyBankError.unknownAccount
            }
            
        } catch {
            throw PiggyBankError.technicalError
        }

        //return try BankAccountDTO(theAccountId: "5140124I234", theAmount: 123.10, theCurrency: "EUR", theFirstName: "Nicolas", theLastName: "Fonrose")

    }

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

