//
//  TimerManager.swift
//  Smartphone app2
//
//  Created by Marina Kikuchi on 2025/07/19.
//

import Foundation

class TimerManager {
    static let shared = TimerManager()
    private init() {}
    
    var isTimerActive = false
    var currentMode: FocusMode = .countdown
    var startTime: Date?
    var wasInterrupted = false  // ← 離脱で中断されたかどうか
    
    func startTimer(mode: FocusMode) {
        isTimerActive = true
        currentMode = mode
        startTime = Date()
    }
    func resetOnInterrupt() {
        isTimerActive = false
        startTime = nil
        wasInterrupted = true
        //wasInterrupted(中断フラグ)
    }
    func clear() {
        isTimerActive = false
        startTime = nil
        wasInterrupted = false
    }
    
    func stopTimer() {
        isTimerActive = false
        startTime = nil
        wasInterrupted = false
    }
    
    func handleAppExit() {
        guard isTimerActive, let start = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(start)
        let duration = Int(elapsed / 60)
        
        switch currentMode {
        case .countdown:
            saveFocusRecord(duration: duration, success: false)
        case .countup:
            let success = elapsed >= 1
            saveFocusRecord(duration: duration, success: success)
        }
        //.countupは1秒以上経っていれば成功、そうでなければ失敗として記録
        stopTimer()
    }
}
