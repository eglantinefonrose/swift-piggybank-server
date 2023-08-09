//
//  File.swift
//  
//
//  Created by Eglantine Fonrose on 09/08/2023.
//

import Foundation


public struct PiggyBankService {
    
    
    // Permet la réalisation d'un paiement depuis un compte bancaire
    func makePayment(timeEpoch, date, accountId, amount, currency) -> BankAccountDTO {

        print("Virement effectué pour un montant de [\(amount) \(currency)] vers le compte [\(accountId)] at [\(date)]");

        let amountAsFloat : Float = Float(amount) ?? -13.37
        do {
            // Charge l'état actuel du compte bancaire depuis la base de données
            let bankAccount = PiggyBankServerDataStorageService.shared.loadBankAccount(accountId)
            
            // Effectue le virement
            let bankAccount = try BankAccount(theAccountId:accountId, theAmount: amountAsFloat, theCurrency:currency, theFirstName: "", theLastName: "")
            
            // Stocke le résultat dans la base
            PiggyBankServerDataStorageService.shared.storeBankAccount(bankAccount.getBankAccountDTO())
            
            // Renvoie le nouvel état du compte bancaire à l'appelant
            return bankAccount.getBankAccountDTO()
        } catch {
            return BankAccountDTO(firstName: "", lastName: "", accountId: "", accountBalance: 0.0, currency: "", isOverdraftAllowed: false)
        }

    }
    
    
    
    //
    //
    // SINGLETON
    //
    //
    
    public static var shared = PiggyBankService()  // PiggyBankService(shouldInjectMockedData:true)


}
