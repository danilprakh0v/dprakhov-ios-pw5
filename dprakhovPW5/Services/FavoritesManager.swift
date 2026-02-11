/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: FavoritesManager.swift
Расположение: dprakhovPW5/Services/
Назначение: Storage for favorite news articles.
//              Хранилище для избранных новостей.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import Foundation

final class FavoritesManager {
    // MARK: - Singleton
    static let shared = FavoritesManager()
    private init() {}
    
    // MARK: - Properties
    private var favoriteIds: Set<Int> = []
    private var favoriteArticles: [ArticleModel] = []
    
    // MARK: - Public Methods
    
    /// Переключает состояние «избранного» для статьи.
    func toggle(_ article: ArticleModel) {
        guard let id = article.newsId else { return }
        if favoriteIds.contains(id) {
            remove(article)
        } else {
            favoriteIds.insert(id)
            favoriteArticles.append(article)
        }
    }
    
    /// Удаляет статью из списка избранного.
    func remove(_ article: ArticleModel) {
        guard let id = article.newsId else { return }
        favoriteIds.remove(id)
        favoriteArticles.removeAll { $0.newsId == id }
    }
    
    /// Проверяет, находится ли статья в списке избранного.
    func isFavorite(_ article: ArticleModel) -> Bool {
        guard let id = article.newsId else { return false }
        return favoriteIds.contains(id)
    }
    
    /// Возвращает все сохраненные статьи.
    func getAll() -> [ArticleModel] {
        return favoriteArticles
    }
}
