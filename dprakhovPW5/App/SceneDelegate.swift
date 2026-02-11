/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: SceneDelegate.swift
Расположение: dprakhowPW5/App/
Назначение: Scene delegate. Configures the window and the root VIPER module.
//              Делегат сцены. Настраивает окно и корневой модуль VIPER.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Сборка VIPER модуля
        let rootVC = NewsListAssembly.build()
        let nav = UINavigationController(rootViewController: rootVC)
        
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
}
