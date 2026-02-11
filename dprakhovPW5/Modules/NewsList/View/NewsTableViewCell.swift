/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsTableViewCell.swift
Расположение: dprakhowPW5/Modules/NewsList/View/
Назначение: Custom card-style cell for news articles.
//              Кастомная ячейка-карточка для новостей.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

final class NewsTableViewCell: UITableViewCell {
    // MARK: - Константы
    static let identifier = "NewsTableViewCell"
    
    private enum Constants {
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 28
        static let imageHeight: CGFloat = 180
        static let horizontalPadding: CGFloat = 20
        static let topSpacing: CGFloat = 15
        static let lineSpacing: CGFloat = 10
        static let bottomPadding: CGFloat = 25
        static let lineWidth: CGFloat = 40
        static let lineHeight: CGFloat = 4
        static let titleFontSize: CGFloat = 18
        static let heartSize: CGFloat = 40
        static let shadowOpacity: Float = 0.08
        static let shadowRadius: CGFloat = 8
        static let shadowOffset = CGSize(width: 0, height: 4)
    }
    
    // MARK: - UI Компоненты
    private let card = UIView()
    private let img = UIImageView()
    private let title = UILabel()
    private let line = UIView()
    private let heartBtn = JapaneseButton(iconName: "icon_heart_on", size: Constants.heartSize)
    
    // MARK: - Свойства
    var onHeartTapped: (() -> Void)?
    var isFavoriteMode: Bool = false {
        didSet { heartBtn.isHidden = !isFavoriteMode }
    }

    // MARK: - Инициализация
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    // MARK: - Верстка (Layout)
    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(card)
        card.backgroundColor = .white
        card.layer.cornerRadius = Constants.cardCornerRadius
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = Constants.shadowOpacity
        card.layer.shadowOffset = Constants.shadowOffset
        card.layer.shadowRadius = Constants.shadowRadius
        card.pin(to: contentView, Constants.cardPadding)
        
        [img, line, title].forEach { card.addSubview($0) }
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.cornerRadius = Constants.cardCornerRadius
        img.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        img.pinTop(to: card)
        img.pinHorizontal(to: card)
        img.setHeight(Constants.imageHeight)
        
        line.backgroundColor = JapaneseDesign.shobuPurple
        line.pinTop(to: img.bottomAnchor, Constants.topSpacing)
        line.pinLeft(to: card, Constants.horizontalPadding)
        line.setWidth(Constants.lineWidth)
        line.setHeight(Constants.lineHeight)
        
        title.font = JapaneseDesign.titleFont(size: Constants.titleFontSize)
        title.numberOfLines = 0
        title.textColor = JapaneseDesign.inkColor
        title.pinTop(to: line.bottomAnchor, Constants.lineSpacing)
        title.pinHorizontal(to: card, Constants.horizontalPadding)
        title.pinBottom(to: card, Constants.bottomPadding)
        
        card.addSubview(heartBtn)
        heartBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heartBtn.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            heartBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10)
        ])
        heartBtn.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
    }

    // MARK: - Действия
    @objc private func heartTapped() {
        onHeartTapped?()
    }

    // MARK: - Конфигурация
    /// Конфигурирует ячейку данными статьи.
    func configure(with article: ArticleModel, isFavorite: Bool = false) {
        self.isFavoriteMode = isFavorite
        title.text = article.title?.uppercased()
        img.image = nil
        img.startShimmer()
        
        let heartIcon = isFavorite ? "icon_heart_on" : "icon_heart_off"
        heartBtn.updateIcon(heartIcon, animated: false)
        
        if let url = article.img?.url {
            URLSession.shared.dataTask(with: url) { [weak self] d, _, _ in
                guard let d = d, let image = UIImage(data: d) else { return }
                DispatchQueue.main.async {
                    self?.img.stopShimmer()
                    self?.img.image = image
                }
            }.resume()
        }
    }
    
    /// Обновляет иконку лайка с анимацией.
    func updateHeartAction(isFavorite: Bool) {
        let heartIcon = isFavorite ? "icon_heart_on" : "icon_heart_off"
        heartBtn.updateIcon(heartIcon, animated: true)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
