//
//  File.swift
//  
//
//  Created by Eglantine Fonrose on 09/08/2023.
//

import Foundation
//import SQLite

class PiggyBankServerDataStorageService {
    
//    private var db: Connection!
//    private var bankAccountsDTO: Table!
//    private var accountId: Expression<Int64>!
//    private var firstName: Expression<String>!
//    private var lastName: Expression<String>!
//    private var accountBalance: Expression<Float64>!
//    private var currency: Expression<String>!
//    private var isOverdraftAllowed: Expression<Int64>!
//    private var overDraftLimit: Expression<Float64>!
//
//    init () {
//        do {
//            db = try Connection("/Users/eglantine/Dev/0.perso/2.Proutechos/PiggyBank/PiggyDataBase.db")
//            bankAccountsDTO = Table("BankAccountDTO")
//            accountId = Expression<Int64>("accountId")
//            firstName = Expression<String>("firstName")
//            lastName = Expression<String>("lastName")
//            accountBalance = Expression<Float64>("accountBalance")
//            currency = Expression<String>("currency")
//            isOverdraftAllowed = Expression<Int64>("isOverdraftAllowed")
//            overDraftLimit = Expression<Float64>("overdraftLimit")
//
//            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
//                try db.run(bankAccountsDTO.create { (t) in
//                    t.column(accountId, primaryKey: true)
//                    t.column(firstName)
//                    t.column(lastName)
//                    t.column(accountBalance)
//                    t.column(currency)
//                    t.column(isOverdraftAllowed)
//                    t.column(overDraftLimit)
//                })
//
//                try db.run(bankAccountsDTO.insert (
//                    accountId <- Int64(Int.random(in: 0..<10000000)),
//                    firstName <- "Malo",
//                    lastName <- "Fonrose",
//                    accountBalance <- 0,
//                    currency <- "EUR",
//                    isOverdraftAllowed <- 0,
//                    overDraftLimit <- 0
//                ))
//
//                try db.run(bankAccountsDTO.insert (
//                    accountId <- Int64(Int.random(in: 0..<10000000)),
//                    firstName <- "Eglantine",
//                    lastName <- "Fonrose",
//                    accountBalance <- 0,
//                    currency <- "EUR",
//                    isOverdraftAllowed <- 0,
//                    overDraftLimit <- 0
//                ))
//
//                UserDefaults.standard.set(true, forKey: "is_db_created")
//
//            }
//
//            print("-- dbmanager init --")
//
//        }
//        catch {
//            print(error.localizedDescription)
//        }
//    }

    public func getBankAccountDTO(accountId:String) -> BankAccountDTO {

//        var bankAccountsDTOModel: BankAccountDTOModel;
//
//        bankAccountsDTO = bankAccountsDTO.order(accountId.desc)
//
//        do {
//
//            print("🎸")
//
//            for bankAccountDTO in try db.prepare(bankAccountsDTO) {
//                print("🌳")
//                let bankAccountDTOModel: BankAccountDTOModel = BankAccountDTOModel()
//
//                bankAccountDTOModel.accountId = bankAccountDTO[accountId]
//                bankAccountDTOModel.firstName = bankAccountDTO[firstName]
//                bankAccountDTOModel.lastName = bankAccountDTO[lastName]
//                bankAccountDTOModel.accountBalance = bankAccountDTO[accountBalance]
//                bankAccountDTOModel.currency = bankAccountDTO[currency]
//                bankAccountDTOModel.isOverdraftAllowed = bankAccountDTO[isOverdraftAllowed]
//                bankAccountDTOModel.overDraftLimit = bankAccountDTO[overDraftLimit]
//
//                bankAccountsDTOModel.append(bankAccountDTOModel)
//
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        return bankAccountsDTOModel
        return BankAccountDTO(firstName: "Nicolas", lastName: "Fonrose", accountId: "5140124I234", accountBalance: 123.10, currency: "EUR", isOverdraftAllowed: false)

    }
    
    
    //
    //
    // SINGLETON
    //
    //
    
    public static var shared = PiggyBankServerDataStorageService()  // BigModel(shouldInjectMockedData:true)


}

