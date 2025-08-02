//
//  FocusRecord.swift
//  Smartphone app2
//
//  Created by Marina Kikuchi on 2025/07/19.
//

import RealmSwift
import Foundation
//Realmを使って集中記録（FocusRecord）をデータベースに保存するためのモデルクラス
//プロパティを 永続化対象（保存対象） にするためのもの
class FocusRecord: Object {
    @Persisted var date: String
    @Persisted var time: String
    @Persisted var duration: Int
    @Persisted var success: Bool
}

