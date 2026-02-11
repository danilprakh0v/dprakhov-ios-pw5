/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsListRouter.swift
Расположение: dprakhovPW5/Modules/NewsList/
Назначение: Router directing navigation flow in VIPER.
//              Router, управляющий навигационными потоками в VIPER.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

final class NewsListRouter: NewsListRouterInput {
    
    // MARK: - Свойства
    weak var viewController: UIViewController?
    
    // MARK: - NewsListRouterInput
    
    /// Переход к подробному просмотру статьи в WebView.
    func navigateToDetail(with url: URL) {
        let detailVC = WebViewController()
        detailVC.articleUrl = url
        // Используем push для навигации
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    /// Открытие экрана Stories в полноэкранном режиме.
    func openStories(with news: [ArticleModel]) {
        let storiesVC = NewsStoryViewController(news: news)
        storiesVC.modalPresentationStyle = .fullScreen
        viewController?.present(storiesVC, animated: true)
    }
    
    /// Переход к экрану избранного.
    func navigateToFavorites() {
        let favoritesVC = FavoritesViewController()
        viewController?.navigationController?.pushViewController(favoritesVC, animated: true)
    }
}
