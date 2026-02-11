/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsListAssembly.swift
Расположение: dprakhovPW5/Modules/NewsList/
Назначение: Assembly for NewsList VIPER module.
//              Сборщик для VIPER-модуля NewsList.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

final class NewsListAssembly {
    
    // MARK: - Сборщик модуля
    /// Собирает VIPER-модуль списка новостей, устанавливая все необходимые зависимости.
    static func build() -> UIViewController {
        let view = NewsListViewController()
        let presenter = NewsListPresenter()
        let interactor = NewsListInteractor(service: NewsNetworkService())
        let router = NewsListRouter()
        
        // MARK: Внедрение зависимостей
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        router.viewController = view
        
        return view
    }
}
