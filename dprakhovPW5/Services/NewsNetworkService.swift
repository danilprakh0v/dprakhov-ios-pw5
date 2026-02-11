/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsNetworkService.swift
Расположение: dprakhowPW5/Services/
Назначение: Network service for fetching and parsing news data.
//              Сетевой сервис для загрузки и парсинга новостей.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import Foundation

protocol NewsNetworkServiceProtocol: AnyObject {
    func fetchNews(pageIndex: Int, completion: @escaping (Result<[ArticleModel], Error>) -> Void)
}

final class NewsNetworkService: NewsNetworkServiceProtocol {
    
    private enum APIConstants {
        static let baseUrl = "https://news.myseldon.com/api/Section?rubricId=4&pageSize=20"
    }

    /// Загрузка порции новостей по индексу страницы
    func fetchNews(pageIndex: Int, completion: @escaping (Result<[ArticleModel], Error>) -> Void) {
        let urlString = "\(APIConstants.baseUrl)&pageIndex=\(pageIndex)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                // Декодирование данных в промежуточную структуру
                let page = try JSONDecoder().decode(NewsPage.self, from: data)
                
                // Маппим requestId в каждую статью для генерации валидного articleUrl
                let articles: [ArticleModel] = page.news?.map { item -> ArticleModel in
                    var updatedItem = item
                    updatedItem.requestId = page.requestId
                    return updatedItem
                } ?? []
                
                completion(.success(articles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
