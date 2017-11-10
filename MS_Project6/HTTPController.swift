//
//  HTTPController.swift
//  MS_Project6
//
//  Created by Oscar on 11/9/17.
//  Copyright © 2017 Luke Hansen. All rights reserved.
//

let SERVER_URL = "http://:8000"

import Foundation
import UIKit

class HTTPController: NSObject, URLSessionDelegate {
    
    var session = URLSession()
    var sampleRate = 0
    var signal = [Float]()
    var label = String()
    let operationQueue = OperationQueue()
    
    let animation = CATransition()
    
    
    
    func initializeTrain(sampleRate: Int, signal: [Float], label: String){
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.sampleRate = sampleRate
        self.signal = signal
        self.label = label
        
        
        self.session = URLSession(configuration: sessionConfig,
                                  delegate: self,
                                  delegateQueue:self.operationQueue)
        
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionReveal
        animation.duration = 0.5
    }
    
    func initializeTest(sampleRate: Int, signal: [Float]){
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.sampleRate = sampleRate
        self.signal = signal
        
        self.session = URLSession(configuration: sessionConfig,
                                  delegate: self,
                                  delegateQueue:self.operationQueue)
        
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionReveal
        animation.duration = 0.5
    }
    
    
    func sendTrainPostWithJsonInBody(_ sender: AnyObject) {
        
        let baseURL = "\(SERVER_URL)/PostWithJson"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["sample_rate": self.sampleRate, "signal": self.signal, "label": self.label]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    print("Response:\n%@",response!)
                                                                    let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                    let status:String? = jsonDictionary.value(forKey: "status") as? String
                                                                    DispatchQueue.main.async{
                                                                        
                                                                        if(status == "success"){
                                                                            print("we gucci")
                                                                        }
                                                                        else{
                                                                            print(error as Any)
                                                                        }
                                                                    }
        })
        
        postTask.resume() // start the task
        
    }
    
    func sendTestPostWithJsonInBody(_ sender: AnyObject) {
        
        let baseURL = "\(SERVER_URL)/PostWithJson"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["sample_rate": self.sampleRate, "signal": self.signal]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    print("Response:\n%@",response!)
                                                                    let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                    let status:String? = jsonDictionary.value(forKey: "status") as? String
                                                                    let predLabel:String? = jsonDictionary.value(forKey: "predLabel") as? String
                                                                    DispatchQueue.main.async{
                                                                        
                                                                        if(status == "success"){
                                                                            print("predLabel: \(predLabel)")
                                                                        }
                                                                        else{
                                                                            print(error as Any)
                                                                        }
                                                                    }
        
        })
        
        postTask.resume() // start the task
        
    }
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                                 options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            print("json error: \(error.localizedDescription)")
            return NSDictionary() // just return empty
        }
    }
    
}
