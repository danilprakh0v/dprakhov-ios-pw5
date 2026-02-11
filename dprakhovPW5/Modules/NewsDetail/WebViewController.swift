/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: WebViewController.swift
Расположение: dprakhowPW5/Modules/NewsDetail/
Назначение: Dedicated view controller for displaying full article content.
//              Специализированный контроллер для просмотра текста статьи.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    // MARK: - Константы
    private enum Constants {
        static let navBarHeight: CGFloat = 60
        static let buttonSize: CGFloat = 44
        static let horizontalPadding: CGFloat = 16
    }
    
    // MARK: - Свойства
    var articleUrl: URL?
    private let webView = WKWebView()
    private let customNavBar = UIView()
    private let closeBtn = JapaneseButton(iconName: "chevron.left", size: Constants.buttonSize) 
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Настройка UI
    private func setupUI() {
        view.backgroundColor = JapaneseDesign.background
        
        // MARK: Фоновый паттерн для монолитности
        let bgPattern = UIView()
        view.addSubview(bgPattern)
        bgPattern.pin(to: view)
        if let pattern = JapaneseDesign.drawSeigaiha() {
            bgPattern.backgroundColor = UIColor(patternImage: pattern)
            bgPattern.alpha = 0.2
        }
        
        // MARK: Кастомный Header
        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.navBarHeight)
        ])
        
        // Паттерн в заголовке
        let headerPattern = UIView()
        customNavBar.addSubview(headerPattern)
        headerPattern.pin(to: customNavBar)
        if let pattern = JapaneseDesign.drawSeigaiha() {
            headerPattern.backgroundColor = UIColor(patternImage: pattern)
            headerPattern.alpha = 0.4
        }
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        customNavBar.addSubview(blurView)
        blurView.pin(to: customNavBar)
        
        // Кнопка закрытия
        let safeContainer = UIView()
        customNavBar.addSubview(safeContainer)
        safeContainer.pinHorizontal(to: customNavBar)
        safeContainer.pinBottom(to: customNavBar)
        safeContainer.setHeight(Constants.navBarHeight)
        
        safeContainer.addSubview(closeBtn)
        closeBtn.pinLeft(to: safeContainer, Constants.horizontalPadding)
        closeBtn.pinCenterY(to: safeContainer)
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        // MARK: Настройка WebView
        view.addSubview(webView)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        webView.pinTop(to: customNavBar.bottomAnchor)
        webView.pinBottom(to: view)
        webView.pinHorizontal(to: view)
    }
    
    // MARK: - Логика
    
    /// Загружает содержимое статьи.
    private func loadPage() {
        guard let url = articleUrl else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Действия (Actions)
    @objc private func closeTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
