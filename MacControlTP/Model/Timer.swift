//
//  Timer.swift
//  MacControlTP
//
//  Created by kyle on 5/24/24.
//

import Foundation

public class Timer {
    public var startTime: Date
    public var timeToWait: TimeInterval
    public var timerFinished: (() -> Void)?
    public init(timeToWait: TimeInterval) {
        startTime = Date()
        self.timeToWait = timeToWait
    }
    public func startTimer() {
        print("starting timer")
        DispatchQueue.global(qos: .background).async {
            while (Date().timeIntervalSince(self.startTime) < self.timeToWait) {
                Thread.sleep(forTimeInterval: 0.2)
            }
            self.timerFinished?()
        }
    }
    public func resetTimer() {
        self.startTime = Date()
    }
    
}
