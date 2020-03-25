//
//  RemoteNotifications.swift
//  SimonSez
//
//  Created by localadmin on 24.03.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import SwiftJWT

private var privateKey = """
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg0uK1fEWZkZs75shU
8tWcg4MlDcjCiybENNwySMViiQWgCgYIKoZIzj0DAQehRANCAAQ7YlOMiuuhz3sd
MSzHrjPS1P8/kpNW0MwhkxUB235LdwcVTfrTmSH1isiRAp5NOb0G441qOXx7+jM2
Vc+Jltgh
-----END PRIVATE KEY-----
"""



class RemoteNotifications: NSObject, URLSessionDelegate {

func postNotification(postTo: String, jsonObject:[String: Any]) {
  print("postTo ",postTo)
  let valid = JSONSerialization.isValidJSONObject(jsonObject)
  print("valid ",valid)
  if !valid {return}

  let myHeader = Header(typ: "JWT", kid: "956UZFGJQT")
  let myClaims = ClaimsStandardJWT(iss: "CWGS87U262", sub: nil, aud: nil, exp: nil, nbf: nil, iat: Date() , jti: nil)
  let myJWT = JWT(header: myHeader, claims: myClaims)
  
  let privateKeyAsData = privateKey.data(using: .utf8)
  let signer = JWTSigner.es256(privateKey: privateKeyAsData!)
  let jwtEncoder = JWTEncoder(jwtSigner: signer)
//  do {
//  let jwtString = try jwtEncoder.encodeToString(myJWT)
//  } catch {
//  print("failed to encode")
//  }
  
  do {
      let jwtString = try jwtEncoder.encodeToString(myJWT)
      let content = "https://api.sandbox.push.apple.com/3/device/" + postTo
      var loginRequest = URLRequest(url: URL(string: content)!)
      loginRequest.allHTTPHeaderFields = ["apns-topic": "ch.cqd.SimonSez",
                                          "content-type": "application/json",
                                          "apns-priority": "5",
                                          "apns-push-type": "background",
                                          "authorization":"bearer " + jwtString]
      // code 12
      let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
      
      loginRequest.httpMethod = "POST"
      
      let data = try? JSONSerialization.data(withJSONObject: jsonObject, options:[])
      
      loginRequest.httpBody = data
      let loginTask = session.dataTask(with: loginRequest) { data, response, error in
        if error != nil {
          print("error ",error)
          return
        }
        let httpResponse = response as! HTTPURLResponse
        self.decodeReply(errorCode: httpResponse)
      }
      loginTask.resume()
      print("apns ",jsonObject)
    } catch {
      print("failed to encode")
    }
  }
  
  func decodeReply(errorCode: HTTPURLResponse) {
    switch errorCode.statusCode {
      case 200:
        print("OK")
      case 400:
        print("Bad Request")
      case 403:
        print("There was an error with the certificate or with the provider authentication token")
      case 405:
        print("The request used a bad :method value. Only POST requests are supported")
      case 410:
        print("The device token is no longer active for the topic")
      case 413:
        print("The notification payload was too large")
      case 429:
        print("The server received too many requests for the same device token")
      case 500:
        print("Internal server error")
      case 503:
        print("The server is shutting down and unavailable")
      default:
        print("Unknown error code ",errorCode.statusCode)
    }
  }
  
  
}
