//
//   FoucusRecorder.swift
//  Smartphone app2
//
//  Created by Marina Kikuchi on 2025/07/19.
//

import Foundation
import RealmSwift

func saveFocusRecord(duration: Int, success: Bool) {
    // 現在の日付と時刻
    let now = Date()
    let formatter = DateFormatter()
    
    formatter.dateFormat = "yyyy-MM-dd"
    let dateStr = formatter.string(from: now)

    formatter.dateFormat = "HH:mm"
    let timeStr = formatter.string(from: now)

    // durationは集中時間、successは成功したかどうか
    let record = FocusRecord()
    record.date = dateStr
    record.time = timeStr
    record.duration = duration
    record.success = success

    // Realmに保存
    do {
        let realm = try Realm()
        try realm.write {
            realm.add(record)
        }
        print("FocusRecord を保存しました。")
    } catch {
        print("保存中にエラーが発生しました: \(error.localizedDescription)")
    }
}

