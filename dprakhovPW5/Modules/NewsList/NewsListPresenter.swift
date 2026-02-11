/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsListPresenter.swift
Расположение: dprakhovPW5/Modules/NewsList/
Назначение: Presenter layer coordinating data flow.
//              Слой Presenter, координирующий потоки данных.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import Foundation

final class NewsListPresenter: NewsListViewOutput, NewsListInteractorOutput {
    
    // Ссылки на слои VIPER
    weak var view: NewsListViewInput?
    var interactor: NewsListInteractorInput?
    var router: NewsListRouterInput?
    
    private var articles: [ArticleModel] = []

    // MARK: - NewsListViewOutput
    func viewDidLoad() {
        view?.showLoading()
        interactor?.loadNews()
    }
    
    func didPullToRefresh() {
        interactor?.loadNews()
    }

    func didTapJapanFilter() {
        interactor?.toggleJapanFilter()
    }
    
    func didTapRandom() {
        guard !articles.isEmpty,
              let randomArticle = articles.randomElement(),
              let url = randomArticle.articleUrl else { return }
        router?.navigateToDetail(with: url)
    }
    
    func didTapStoriesMode() {
        guard !articles.isEmpty else { return }
        router?.openStories(with: articles)
    }
    
    func didTapFavorites() {
        router?.navigateToFavorites()
    }
    
    func didTapLogo() {
        view?.showLoading()
        interactor?.loadNews()
    }
    
    func didScrollToBottom() {
        interactor?.loadMoreNews()
    }
    
    func didTapCell(at index: Int) {
        guard index < articles.count,
              let url = articles[index].articleUrl else { return }
        router?.navigateToDetail(with: url)
    }

    // MARK: - NewsListInteractorOutput
    func didLoad(news: [ArticleModel], isFiltered: Bool) {
        self.articles = news
        view?.hideLoading()
        
        // Сначала обновляем состояние фильтра для корректной отрисовки заглушки, затем данные
        view?.setJapanFilterActive(isFiltered)
        view?.update(with: news)
    }
    
    func didLoadMore(news: [ArticleModel]) {
        self.articles.append(contentsOf: news)
        view?.append(news: news)
    }

    func didFail(with error: Error) {
        view?.hideLoading()
        print("Presenter Error: \(error.localizedDescription)")
    }
}
