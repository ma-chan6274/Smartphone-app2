//
//  ChartViewController.swift
//  Smartphone app2
//
//  Created by Marina Kikuchi on 2025/07/19.
//

import UIKit
import Charts
import RealmSwift
import DGCharts

class ChartViewController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var records: Results<FocusRecord>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        
        records = try! Realm().objects(FocusRecord.self)
        setupCharts()
    }
    
    func setupCharts() {
        // date文字列のフォーマット（例）を指定
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd" // 例: "2025-08-02"
        
        // dateごとにグループ化（Stringで）
        let grouped = Dictionary(grouping: records) { $0.date }
        
        // 日付文字列の配列をDateに変換してソート
        let sortedDates = grouped.keys.compactMap { inputFormatter.date(from: $0) }.sorted()
        
        // 出来たDate配列をX軸ラベル用に "MM/dd" 形式で文字列化
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd"
        let sortedDateStrings = sortedDates.map { outputFormatter.string(from: $0) }
        
        var barEntries: [BarChartDataEntry] = []
        var lineEntries: [ChartDataEntry] = []
        
        // ソートした日付順に処理
        for (index, date) in sortedDates.enumerated() {
            let dateString = inputFormatter.string(from: date) // 元の文字列に戻す
            
            let dayRecords = grouped[dateString] ?? []
            let totalDuration = dayRecords.reduce(0) { $0 + $1.duration }
            let successCount = dayRecords.filter { $0.success }.count
            let successRate = dayRecords.isEmpty ? 0.0 : Double(successCount) / Double(dayRecords.count)
            
            barEntries.append(BarChartDataEntry(x: Double(index), y: Double(totalDuration)))
            lineEntries.append(ChartDataEntry(x: Double(index), y: successRate * 100))
        }
        
        // 棒グラフ
        let barSet = BarChartDataSet(entries: barEntries, label: "合計時間（分）")
        barSet.colors = [.systemBlue]
        barChartView.data = BarChartData(dataSet: barSet)
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: sortedDateStrings)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.leftAxis.axisMinimum = 0
        barChartView.rightAxis.enabled = false
        barChartView.animate(yAxisDuration: 1.0)
        
        // 折れ線グラフ
        let lineSet = LineChartDataSet(entries: lineEntries, label: "成功率（%）")
        lineSet.colors = [.systemGreen]
        lineSet.circleColors = [.systemGreen]
        lineChartView.data = LineChartData(dataSet: lineSet)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: sortedDateStrings)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.rightAxis.enabled = false
        lineChartView.animate(yAxisDuration: 1.0)
    }

    
}
