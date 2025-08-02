//
//  ViewController.swift
//  Smartphone restriction app２
//
//  Created by Marina Kikuchi on 2025/06/21.
//

import UIKit
import FSCalendar
import RealmSwift

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var infoLabel: UILabel!

    var records: Results<FocusRecord>!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self
        records = realm.objects(FocusRecord.self)
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        //自身が設定したタイムを守れたかどうか
        let dayRecords = records.filter("date == %@", key)
        if dayRecords.isEmpty {
            return nil
        } else if dayRecords.contains(where: { $0.success }) {
            return .systemGreen
        } else {
            return .systemRed
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition:
    //カレンダーは月も定義する
                  FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        //dayRecordsはある日の記録の総合
        let dayRecords = records.filter("date == %@", key)
        if dayRecords.isEmpty {
            infoLabel.text = "\(key)：記録なし"
        } else {
            var text = "\(key)：\n"
        //rはdayRecordsのうちのどれか一つを取り上げたもの
            for r in dayRecords {
                let status = r.success ? "成功" : "失敗"
               text += "・\(r.time)  \(r.duration)分（\(status)）\n"
            }
            infoLabel.text = text
        }
    }
//カレンダーを再度読み込んで色や情報を更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        records = realm.objects(FocusRecord.self)
        calendar.reloadData()
    }
}


