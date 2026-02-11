/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: ArticleModel.swift
Расположение: dprakhowPW5/Models/
Назначение: Data model representing a news article entity.
//              Модель данных, представляющая сущность новости.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import Foundation

struct NewsPage: Decodable, Sendable {
    let news: [ArticleModel]?
    let requestId: String?
}

struct ArticleModel: Decodable, Sendable {
    let newsId: Int?
    let title: String?
    let announce: String?
    let img: ImageContainer?
    var requestId: String?
    
    /// Ссылка для просмотра полной версии новости на сайте
    var articleUrl: URL? {
        guard let nid = newsId, let rid = requestId else { return nil }
        return URL(string: "https://news.myseldon.com/ru/news/index/\(nid)?requestId=\(rid)")
    }
}

struct ImageContainer: Decodable, Sendable {
    let url: URL?
}
