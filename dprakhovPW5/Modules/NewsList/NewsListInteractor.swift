/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsListInteractor.swift
Расположение: dprakhowPW5/Modules/NewsList/
Назначение: Interactor implementation with Japan filter and pagination.
//              Реализация Interactor с фильтрацией и пагинацией.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import Foundation

final class NewsListInteractor: NewsListInteractorInput {
    
    // Ключевые слова для фильтрации «японского» контента. 
    // Поиск идет по заголовку и анонсу без учета регистра.
    private enum Constants {
        static let japanKeywords = ["япония", "япони", "токио", "kyoto", "japan", "азия"]
    }
    
    weak var output: NewsListInteractorOutput?
    private let service: NewsNetworkServiceProtocol
    
    private var allArticles: [ArticleModel] = []
    private var isJapanFilterActive = false
    private var currentPage = 1
    private var isFetching = false

    // MARK: - Инициализация
    init(service: NewsNetworkServiceProtocol) {
        self.service = service
    }

    /// Загрузка первой страницы новостей
    func loadNews() {
        guard !isFetching else { return }
        isFetching = true
        currentPage = 1
        service.fetchNews(pageIndex: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            switch result {
            case .success(let news):
                self.allArticles = news
                self.notifyPresenter()
            case .failure(let error):
                self.output?.didFail(with: error)
            }
        }
    }
    
    /// Загрузка следующей страницы. Пагинация отключается при активном фильтре, 
    /// так как фильтрация происходит на клиенте из уже загруженного пула.
    func loadMoreNews() {
        guard !isFetching, !isJapanFilterActive else { return }
        isFetching = true
        currentPage += 1
        service.fetchNews(pageIndex: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            switch result {
            case .success(let news):
                self.allArticles.append(contentsOf: news)
                self.output?.didLoadMore(news: news)
            case .failure(let error):
                self.output?.didFail(with: error)
            }
        }
    }

    /// Переключение режима фильтрации «Только Япония»
    func toggleJapanFilter() {
        isJapanFilterActive.toggle()
        notifyPresenter()
    }

    /// Подготовка данных для презентера с учетом текущих фильтров
    private func notifyPresenter() {
        if isJapanFilterActive {
            let filtered = allArticles.filter { article in
                let content = ((article.title ?? "") + (article.announce ?? "")).lowercased()
                return Constants.japanKeywords.contains { content.contains($0) }
            }
            output?.didLoad(news: filtered, isFiltered: true)
        } else {
            output?.didLoad(news: allArticles, isFiltered: false)
        }
    }
}
