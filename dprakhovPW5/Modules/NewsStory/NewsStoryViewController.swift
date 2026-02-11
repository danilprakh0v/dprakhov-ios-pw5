/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsStoryViewController.swift
Расположение: dprakhowPW5/Modules/NewsStory/
Назначение: TikTok-style stories view for news articles.
//              Экран новостей в стиле Stories/TikTok.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

final class NewsStoryViewController: UIViewController {
    // MARK: - Свойства
    private var news: [ArticleModel]
    private var currentIndex = 0
    
    // MARK: - Константы
    private enum Constants {
        static let gradientHeight: CGFloat = 500
        static let titleFontSize: CGFloat = 32
        static let horizontalPadding: CGFloat = 24
        static let buttonSpacing: CGFloat = 35
        static let bottomSpacing: CGFloat = 110
        static let animationDuration: TimeInterval = 0.4
        static let buttonSize: CGFloat = 52
        static let dismissThreshold: CGFloat = 100
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.5
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let stackRightPadding: CGFloat = 20
        static let feedbackDuration: TimeInterval = 0.1
    }
    
    // MARK: - UI Компоненты
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    private let haptic = UISelectionFeedbackGenerator()
    
    private let likeBtn = JapaneseButton(iconName: "icon_heart_off", size: Constants.buttonSize)
    private let nextBtn = JapaneseButton(iconName: "icon_tick", size: Constants.buttonSize)
    private let closeBtn = JapaneseButton(iconName: "icon_cross", size: Constants.buttonSize)

    // MARK: - Инициализация
    init(news: [ArticleModel]) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        displayCurrent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: view.bounds.height - Constants.gradientHeight, 
                                   width: view.bounds.width, height: Constants.gradientHeight)
        // Поворот кнопки «крестик» для стиля
        closeBtn.transform = CGAffineTransform(rotationAngle: .pi / 4)
    }

    // MARK: - Настройка UI
    private func setupUI() {
        view.backgroundColor = .black
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.pin(to: view)
        
        // MARK: Градиент для читаемости текста
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.addSublayer(gradientLayer)

        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        // Тень для текста
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = Constants.shadowRadius
        titleLabel.layer.shadowOpacity = Constants.shadowOpacity
        titleLabel.layer.shadowOffset = Constants.shadowOffset
        
        view.addSubview(titleLabel)
        titleLabel.pinBottom(to: view, Constants.bottomSpacing)
        titleLabel.pinHorizontal(to: view, Constants.horizontalPadding)

        // MARK: Вертикальная панель кнопок
        let stack = UIStackView(arrangedSubviews: [nextBtn, likeBtn, closeBtn])
        stack.axis = .vertical
        stack.spacing = Constants.buttonSpacing
        view.addSubview(stack)
        stack.pinRight(to: view, Constants.stackRightPadding)
        stack.pinCenterY(to: view)

        nextBtn.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        likeBtn.addTarget(self, action: #selector(like), for: .touchUpInside)
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(pan)
    }

    // MARK: - Логика
    
    /// Отображает контент текущей статьи.
    private func displayCurrent() {
        guard currentIndex < news.count else { return }
        let article = news[currentIndex]
        
         UIView.transition(with: titleLabel, duration: Constants.animationDuration, options: .transitionCrossDissolve) {
            self.titleLabel.text = article.title
        }
        
        updateLikeButton(for: article, animated: false)

        if let url = article.img?.url {
            URLSession.shared.dataTask(with: url) { [weak self] d, _, _ in
                guard let d = d, let image = UIImage(data: d) else { return }
                DispatchQueue.main.async {
                    UIView.transition(with: self?.imageView ?? UIView(), duration: Constants.animationDuration, options: .transitionCrossDissolve) {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    /// Обновляет иконку лайка в зависимости от состояния статьи.
    private func updateLikeButton(for article: ArticleModel, animated: Bool = true) {
        let isFav = FavoritesManager.shared.isFavorite(article)
        let heartIcon = isFav ? "icon_heart_on" : "icon_heart_off"
        likeBtn.updateIcon(heartIcon, animated: animated)
    }
    
    // MARK: - Действия (Actions)
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let progress = translation.y / view.bounds.height
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
                view.alpha = 1 - progress
            }
        case .ended:
            if translation.y > Constants.dismissThreshold {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.view.transform = .identity
                    self.view.alpha = 1
                }
            }
        default: break
        }
    }

    @objc private func goNext() {
        currentIndex = (currentIndex + 1) % news.count
        haptic.selectionChanged()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.nextBtn.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.nextBtn.transform = .identity
            }
        }
        
        displayCurrent()
    }

    @objc private func like() {
        let article = news[currentIndex]
        FavoritesManager.shared.toggle(article)
        updateLikeButton(for: article)
        
        UIView.animate(withDuration: 0.15, animations: {
            self.likeBtn.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.likeBtn.transform = .identity
            }
        }
    }

    @objc private func close() { dismiss(animated: true) }
}
