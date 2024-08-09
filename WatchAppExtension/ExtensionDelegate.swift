//
//  ExtensionDelegate.swift
//  CoinSpace WatchApp Extension
//
//  Created by Nikita Verkhovin on 13.04.2018.
//

import WatchKit
import SwiftyJSON
import Repeat

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDownloadDelegate {

    var timer: Repeater!
    let tickerApiUrl = "https://price.coin.space/api/v1/prices/public?cryptoIds=bitcoin@bitcoin,bitcoin-cash@bitcoin-cash,ethereum@ethereum,litecoin@litecoin&fiat="
    let backgroundInterval = 60.0
    let timerInterval = 60.0

    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        self.timer = Repeater(interval: .seconds(self.timerInterval), mode: .infinite) { _ in
            self.loadTicker();
        }

        let userInfo = ["reason" : "background update"] as NSDictionary
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: self.backgroundInterval), userInfo: userInfo) { (error: Error?) in
            if let error = error {
                print("Error occured while scheduling background update: \(error.localizedDescription)")
            }
        }
    }

    func loadTicker() {
        let urlRequest = URLRequest(url: URL(string: self.tickerApiUrl + AppService.sharedInstance.currencySymbol)!)
        self.dataTask?.cancel()
        self.dataTask = defaultSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            defer { self.dataTask = nil }
            if let error = error {
                print("Error dataTask \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Error dataTask statusCode: \(response.statusCode)")
            } else if data == nil {
                print("Error dataTask empty data")
            } else {
                let json = (try? JSON(data: data!)) ?? JSON(NSNull())
                if !json.isEmpty {
                    AppService.sharedInstance.setTicker(json)
                }
            }
        })
        self.dataTask?.resume()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.timer.reset(.seconds(self.timerInterval), restart: true)
        loadTicker();
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        self.timer.pause()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                _ = backgroundTask.userInfo
                let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: NSUUID().uuidString)
                let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
                let downloadTask = backgroundSession.downloadTask(with: URL(string: self.tickerApiUrl)!)
                downloadTask.resume()
                let userInfo = ["reason" : "background update"] as NSDictionary
                WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: self.backgroundInterval), userInfo: userInfo) { (error: Error?) in
                    if let error = error {
                        print("Error occured while scheduling background update: \(error.localizedDescription)")
                    }
                }
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let jsonString = try? String(contentsOf: location)
        if jsonString != nil {
            let json = JSON(parseJSON: jsonString!)
            if !json.isEmpty {
                AppService.sharedInstance.setTicker(json)
            }
        }
        // Cleaning
        let fileManager = FileManager.default
        _ = try? fileManager.removeItem(at: location)
    }
}
