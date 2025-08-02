//
//   FoucusRecorder.swift
//  Smartphone app2
//
//  Created by Marina Kikuchi on 2025/07/19.

import UIKit
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config

        return true
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("戻りました")
        // 通知から復帰したかどうかを確認
        if TimerManager.shared.wasInterrupted,
           let rootVC = window?.rootViewController as? TimerViewController {
            rootVC.handleInterruption()
        }

    }

    func sceneWillResignActive(_ scene: UIScene) {
        if TimerManager.shared.isTimerActive {
            TimerManager.shared.handleAppExit()
            print("detected")
            TimerManager.shared.resetOnInterrupt()

            // 通知の許可があれば送信
            let content = UNMutableNotificationContent()
            content.title = "集中が中断されました"
            content.body = "記録はリセットされました"
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "interruptionNotice",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
