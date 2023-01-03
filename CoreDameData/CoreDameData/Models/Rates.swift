//
//  Rates.swift
//  CoreDameData
//
//  Created by Dameion Dismuke on 1/3/23.
//

import Foundation




struct Rates : Codable {
    
    let rates : Currency
}


struct Currency : Codable {
    
    let btc : Price
    let eth : Price
    let usd : Price
    let aud : Price
    let jpy : Price
}


struct Price : Codable {
    
    let name : String
    let unit : String
    let value : Float
    let type : String
    
}

/*
 
 "rates":{
 "btc":{
          "name":"Bitcoin",
          "unit":"BTC",
          "value":1.0,
          "type":"crypto"
       },
"eth":{
          "name":"Ether",
          "unit":"ETH",
          "value":13.748,
          "type":"crypto"
       },
 "usd":{
          "name":"US Dollar",
          "unit":"$",
          "value":16728.209,
          "type":"fiat"
       },
 "aud":{
          "name":"Australian Dollar",
          "unit":"A$",
          "value":24845.138,
          "type":"fiat"
       },
 "jpy":{
          "name":"Japanese Yen",
          "unit":"¥",
          "value":2186212.344,
          "type":"fiat"
       }
 }
 */
