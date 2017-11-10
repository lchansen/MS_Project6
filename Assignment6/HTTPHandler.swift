//
//  HTTPControl.swift
//  MS_Project6
//
//  Created by Oscar on 11/9/17.
//  Copyright © 2017 Luke Hansen. All rights reserved.
//

import Foundation

let SERVER_URL = "http://162.243.151.247"    //DigitalOcean
//let SERVER_URL = "http://192.168.0.177:8000" //local


import Foundation
import UIKit

@objc public class HTTPHandler: NSObject, URLSessionDelegate {
    static let sharedInstance = HTTPHandler()
    lazy var session = URLSession()
    lazy var sampleRate = 44100
    lazy var signal = [Float]()
    lazy var label = String()
    let operationQueue = OperationQueue()

    override init(){
        super.init()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.httpMaximumConnectionsPerHost = 5
        
        self.session = URLSession(configuration: sessionConfig,
                                  delegate: self,
                                  delegateQueue:self.operationQueue)
    }
    
    func login(user: String, pass: String, vc: ViewController){
        var request = URLRequest(url: URL(string: "\(SERVER_URL)/Login")!)
        let jsonUpload:NSDictionary = ["username": user, "password": pass]
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    DispatchQueue.main.async{
                                                                        let httpRes:HTTPURLResponse = response as! HTTPURLResponse
                                                                        if(httpRes.statusCode==200){
                                                                            vc.loginSucess()
                                                                        }
                                                                        else{
                                                                            vc.loginFail()
                                                                        }
                                                                    }
        })
        postTask.resume()
    }
    
    func getDSID(vc: TrainingViewController){
        var request = URLRequest(url: URL(string: "\(SERVER_URL)/GetNewDatasetId")!)
        request.httpMethod = "GET"
        let getTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    print("Response:\n%@",response!)
                                                                    let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                    DispatchQueue.main.async{
                                                                        let httpRes:HTTPURLResponse = response as! HTTPURLResponse
                                                                        if(httpRes.statusCode==200){
                                                                            vc.initDSID(jsonDictionary["dsid"] as! Int)
                                                                        }
                                                                    }
        })
        getTask.resume()
    }
    
    func train(dsid: Int, sampleRate: Int, signal: [Float], label: String, vc:TrainingViewController){
        var request = URLRequest(url: URL(string: "\(SERVER_URL)/AddDataPoint")!)
        let jsonUpload:NSDictionary = ["sample_rate": sampleRate, "signal": signal, "label": label, "dsid":dsid]
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                    print(jsonDictionary)
                                                                    let status:String? = jsonDictionary.value(forKey: "status") as? String
                                                                    DispatchQueue.main.async{
                                                                        if(status == "success"){
                                                                            vc.callbackLabel("✅", knn:"", svm:"")
                                                                        } else {
                                                                            vc.callbackLabel("❌", knn:"", svm:"")
                                                                            print("You done got an error")
                                                                            print(error as Any)
                                                                        }
                                                                    }
                                                                    
        })
        postTask.resume()
    }
    
    func updateModel(dsid: Int, n_neighbors: Int, svm_kernel: String, vc:TrainingViewController){
        var request = URLRequest(url: URL(string: "\(SERVER_URL)/UpdateModel")!)
        let jsonUpload:NSDictionary = ["dsid": dsid, "knn": ["n_neighbors":n_neighbors], "svm": ["kernel":svm_kernel]]
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                    print(jsonDictionary)
                                                                    let status:String? = jsonDictionary.value(forKey: "status") as? String
                                                                    let knn_acc:String? = jsonDictionary.value(forKey: "knn") as? String
                                                                    let svm_acc:String? = jsonDictionary.value(forKey: "svm") as? String
                                                                    DispatchQueue.main.async{
                                                                        if(status == "success"){
                                                                            vc.callbackLabel("✅", knn:knn_acc!, svm:svm_acc!)
                                                                        } else if (status!.range(of: ">") != nil) {
                                                                            vc.callbackLabel(status, knn:"", svm:"")
                                                                        } else {
                                                                            vc.callbackLabel("❌", knn:"", svm:"")
                                                                            print("You done got an error")
                                                                            print(error as Any)
                                                                        }
                                                                    }
                                                                    
        })
        postTask.resume() // start the task
    }
    
    func test(dsid: Int, clf_name:String, sampleRate: Int, signal: [Float], vc: TestingViewController){
        var request = URLRequest(url: URL(string: "\(SERVER_URL)/PredictOne")!)
        let jsonUpload:NSDictionary = ["dsid": dsid, "clf_name":clf_name, "sample_rate": sampleRate, "signal": signal]
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                    print(jsonDictionary)
                                                                    let status:String? = jsonDictionary.value(forKey: "status") as? String
                                                                    let predLabel:String? = jsonDictionary.value(forKey: "predLabel") as? String
                                                                    DispatchQueue.main.async{
                                                                        if(status == "success"){
                                                                            print("predLabel: \(String(describing: predLabel))")
                                                                            vc.setCLFLabel(predLabel!)
                                                                        }
                                                                        else{
                                                                            vc.setCLFLabel(status)
                                                                        }
                                                                    }
        })
        postTask.resume()
    }
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do {
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                                 options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            return jsonDictionary
        } catch {
            print("json error: \(error.localizedDescription)")
            return NSDictionary()
        }
    }
    
}

