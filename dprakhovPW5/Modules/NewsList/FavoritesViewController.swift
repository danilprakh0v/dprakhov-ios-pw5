/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: FavoritesViewController.swift
Расположение: dprakhovPW5/Modules/NewsList/
Назначение: Screen for displaying favorite news articles.
//              Экран просмотра избранных новостей.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

final class FavoritesViewController: UIViewController {
    // MARK: - Константы
    private enum Constants {
        static let navBarHeight: CGFloat = 60
        static let buttonSize: CGFloat = 44
        static let horizontalPadding: CGFloat = 16
        static let jpTitleSize: CGFloat = 24
        static let ruTitleSize: CGFloat = 14
        static let emptyLabelSize: CGFloat = 22
        static let jpColor = UIColor(red: 230/255, green: 57/255, blue: 70/255, alpha: 1.0)
    }

    // MARK: - Свойства
    private let tableView = UITableView()
    private var favoriteNews: [ArticleModel] = []
    private let closeBtn = JapaneseButton(iconName: "chevron.left", size: Constants.buttonSize) 
    private let customNavBar = UIView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Настройка UI
    private func setupUI() {
        view.backgroundColor = JapaneseDesign.paperColor
        
        // MARK: Фоновый паттерн Seigaiha
        if let pattern = JapaneseDesign.drawSeigaiha() {
            let bg = UIView(frame: view.bounds)
            bg.backgroundColor = UIColor(patternImage: pattern)
            bg.alpha = 0.3
            bg.isUserInteractionEnabled = false
            view.addSubview(bg)
        }
        
        setupCustomNavBar()
        
        // MARK: Настройка таблицы
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
    }
    
    // MARK: Настройка навигационной панели
    private func setupCustomNavBar() {
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
        
        // Эффект размытия
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        customNavBar.addSubview(blur)
        blur.pin(to: customNavBar)
        
        let container = UIView()
        customNavBar.addSubview(container)
        container.pinHorizontal(to: customNavBar)
        container.pinBottom(to: customNavBar)
        container.setHeight(Constants.navBarHeight)
        
        container.addSubview(closeBtn)
        closeBtn.pinLeft(to: container, Constants.horizontalPadding)
        closeBtn.pinCenterY(to: container)
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        // Стековый заголовок (Японский + Русский)
        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.alignment = .center
        titleStack.spacing = 2
        container.addSubview(titleStack)
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        let jpTitle = UILabel()
        jpTitle.text = "お気に入り"
        jpTitle.font = JapaneseDesign.titleFont(size: Constants.jpTitleSize)
        jpTitle.textColor = Constants.jpColor
        
        let ruTitle = UILabel()
        ruTitle.text = "Любимое"
        ruTitle.font = .systemFont(ofSize: Constants.ruTitleSize, weight: .medium)
        ruTitle.textColor = jpTitle.textColor.withAlphaComponent(0.7)
        
        titleStack.addArrangedSubview(jpTitle)
        titleStack.addArrangedSubview(ruTitle)
        
        // Заглушка при отсутствии данных
        view.addSubview(emptyLabel)
        emptyLabel.text = "Любимых историй ещё нет..."
        emptyLabel.font = .systemFont(ofSize: Constants.emptyLabelSize, weight: .bold)
        emptyLabel.textColor = Constants.jpColor
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Действия (Actions)
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Логика данных
    /// Загружает список избранных новостей из менеджера.
    private func loadFavorites() {
        favoriteNews = FavoritesManager.shared.getAll()
        emptyLabel.isHidden = !favoriteNews.isEmpty
        tableView.reloadData()
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        let article = favoriteNews[indexPath.row]
        cell.configure(with: article, isFavorite: true)
        
        cell.onHeartTapped = { [weak self, weak cell] in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            // Animation first
            cell?.updateHeartAction(isFavorite: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                FavoritesManager.shared.remove(article)
                self?.favoriteNews.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self?.emptyLabel.isHidden = !(self?.favoriteNews.isEmpty ?? true)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let article = favoriteNews[indexPath.row]
            FavoritesManager.shared.remove(article)
            favoriteNews.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = favoriteNews[indexPath.row]
        if let url = article.articleUrl {
            let detailVC = WebViewController()
            detailVC.articleUrl = url
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
