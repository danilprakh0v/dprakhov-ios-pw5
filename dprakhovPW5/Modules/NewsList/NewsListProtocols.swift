/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsListProtocols.swift
Расположение: dprakhovPW5/Modules/NewsList/
Назначение: Protocols defining VIPER layer communication.
//              Протоколы, определяющие взаимодействие слоев VIPER.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import Foundation

// Взаимодействие с UI-слоем

/// Управление отображением (Presenter -> View)
protocol NewsListViewInput: AnyObject {
    func update(with news: [ArticleModel])              // Обновляет весь список
    func append(news: [ArticleModel])                  // Добавляет новые элементы
    func setJapanFilterActive(_ active: Bool)          // Визуализация фильтра
    func showLoading()                                 // Показ анимации загрузки
    func hideLoading()                                 // Скрытие анимации загрузки
}

/// Обработка пользовательских событий (View -> Presenter)
protocol NewsListViewOutput: AnyObject {
    func viewDidLoad()
    func didTapCell(at index: Int)
    func didTapRandom()
    func didTapStoriesMode()
    func didTapJapanFilter()
    func didTapFavorites()
    func didTapLogo()
    func didScrollToBottom()
    func didPullToRefresh()
}

// Бизнес-логика и хранение данных

/// Входящие команды (Presenter -> Interactor)
protocol NewsListInteractorInput: AnyObject {
    func loadNews()
    func loadMoreNews()
    func toggleJapanFilter()
}

/// Ответы от интерактора (Interactor -> Presenter)
protocol NewsListInteractorOutput: AnyObject {
    func didLoad(news: [ArticleModel], isFiltered: Bool)
    func didLoadMore(news: [ArticleModel])
    func didFail(with error: Error)
}

// Навигация

/// Переходы между модулями (Presenter -> Router)
protocol NewsListRouterInput: AnyObject {
    func navigateToDetail(with url: URL)       // Переход к WebView
    func openStories(with news: [ArticleModel]) // Переход к Stories
    func navigateToFavorites()                  // Переход к избранному
}
