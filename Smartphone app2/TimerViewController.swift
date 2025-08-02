//
//  TimerViewController.swift
//  Smartphone restriction app２
//
//  Created by Marina Kikuchi on 2025/07/12.
//

import UIKit
import RealmSwift

class TimerViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var foucsMinutesField: UITextField!
    
    var timer: Timer?
    var secondsLeft = 0
    var elapsedSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progressTintColor = UIColor.orange
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 3)
        updateProgress(0.0)
    }
    
    func updateProgress(_ progress: Float) {
        progressView.progress = progress
        progressView.setProgress(progress, animated: true)
        timerLabel.text = "\(String(format: "%.0f", progress * 100)) %"
    }
    
    func handleInterruption() {
        timer?.invalidate()
        timerLabel.text = "00:00"
        TimerManager.shared.clear()
            
        // アラート表示
        let alert = UIAlertController(
            title: "集中中断",
            message: "アプリが中断されたため、記録はリセットされました。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // 通知をキャンセル（アプリが戻ってきたとき）
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["interruptionNotice"])
    }
    
    @IBAction func startFocusButtonTapped(_ sender: UIButton) {
        let selected = modeSelector.selectedSegmentIndex
        let mode: FocusMode = (selected == 0) ? .countdown : .countup
        TimerManager.shared.startTimer(mode: mode)
        
        if mode == .countdown {
            let minutesLeft = Int(foucsMinutesField.text ?? "") ?? 20
            secondsLeft = 60 * minutesLeft
            startCountdown()
        } else {
            elapsedSeconds = 0
            startCountup()
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        // updateProgress(0.0) // ← 削除 or コメントアウト
        // timerLabel.text = "00:00" // ← 削除 or コメントアウト
        UIApplication.shared.isIdleTimerDisabled = false
        TimerManager.shared.stopTimer()
        print("タイマーを停止しました")
    }
    
    func saveFocusRecord(duration: Int, success: Bool) {
        let record = FocusRecord()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        record.date = formatter.string(from: Date())
        record.duration = duration
        record.success = success
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(record)
            }
            print("FocusRecord saved.")
        } catch {
            print("Failed to save FocusRecord: \(error)")
        }
    }

    func startCountdown() {
        if let existingTimer = timer {
            existingTimer.invalidate()
            print("既存のタイマーを破棄しました")
        }
        
        let totalSeconds = secondsLeft
        var secondsPassed = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.secondsLeft > 0 {
                self.secondsLeft -= 1
                secondsPassed += 1
                
                let progress = Float(self.secondsLeft) / Float(totalSeconds)
                self.updateProgress(progress)
                
                self.timerLabel.text = "\(self.secondsLeft / 60)分\(self.secondsLeft % 60)秒"
            } else {
                self.timer?.invalidate()
                self.updateProgress(0.0)
                self.saveFocusRecord(duration: totalSeconds / 60, success: true)
                TimerManager.shared.stopTimer()
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    func startCountup() {
        if let existingTimer = timer {
            existingTimer.invalidate()
        }
        
        elapsedSeconds = 0
        let maxSeconds = 60 * 60 * 5
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedSeconds += 1
            
            let progress = min(Float(self.elapsedSeconds) / Float(maxSeconds), 1.0)
            self.updateProgress(progress)
            
            self.timerLabel.text = "\(self.elapsedSeconds / 60)分\(self.elapsedSeconds % 60)秒"
        }
    }
}
