/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: NewsListViewController.swift
Расположение: dprakhowPW5/Modules/NewsList/
Назначение: Main view layer with Japanese aesthetics and custom controls.
//              Главный экран со списком новостей и японской эстетикой.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

final class NewsListViewController: UIViewController, NewsListViewInput {
    // Данные и состояние фильтрации
    var presenter: NewsListViewOutput?
    private var news: [ArticleModel] = []
    private var isJapanFilterActive = false
    
    private enum Constants {
        static let buttonSize: CGFloat = 52
        static let cornerRadius: CGFloat = 32
        static let islandBottomOffset: CGFloat = -10
        static let islandWidth: CGFloat = 330
        static let islandHeight: CGFloat = 70
        static let headerHeight: CGFloat = 60
        static let nekoSize: CGSize = CGSize(width: 280, height: 320)
        static let tableTopInset: CGFloat = 15
        static let tableBottomInset: CGFloat = 130
        static let animationDuration: TimeInterval = 0.3
        static let floatingDuration: TimeInterval = 2.5
        static let filterScale: CGFloat = 1.15
        static let vestiColor = UIColor(red: 143/255, green: 118/255, blue: 232/255, alpha: 1.0)
    }
    
    // Основные элементы интерфейса
    private let tableView = UITableView()
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    private let nekoContainer = UIView()
    private let bgPattern = UIView()
    
    private let customNavBar = UIView()
    private let islandContainer = UIView()
    private let floatingIsland = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    
    // Кнопки управления (Pill markers)
    private let diceBtn = JapaneseButton(iconName: "icon_dice", size: Constants.buttonSize)
    private let japanBtn = JapaneseButton(iconName: "flag_japan", size: Constants.buttonSize)
    private let sensuBtn = JapaneseButton(iconName: "icon_sensu", size: Constants.buttonSize)
    private let heartBtn = JapaneseButton(iconName: "icon_heart_on", size: Constants.buttonSize)
    private let reloadBtn = JapaneseButton(iconName: "reload_icon", size: Constants.buttonSize) 

    private let titleLabel = UILabel()
    private let nekoLabel = UILabel()
    private let nekoImageView = UIImageView(image: UIImage(named: "maneki_neko"))

    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = JapaneseDesign.paperColor
        
        // Фоновый традиционный узор
        view.addSubview(bgPattern)
        bgPattern.translatesAutoresizingMaskIntoConstraints = false
        bgPattern.pin(to: view)
        if let pattern = JapaneseDesign.drawSeigaiha() {
            bgPattern.backgroundColor = UIColor(patternImage: pattern)
            bgPattern.alpha = 0.3
        }
        
        setupCustomHeader()
        
        // Список новостей (Таблица)
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
        
        // Закругление таблицы для эффекта «карточки»
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.clipsToBounds = true
        
        // Отступы для корректного отображения контента под навигацией и островом
        tableView.contentInset = UIEdgeInsets(top: Constants.tableTopInset, left: 0, bottom: Constants.tableBottomInset, right: 0)
        
        setupFloatingIsland()
        // Инициализируем пустые состояния сразу, чтобы избежать рывков при первом появлении котика
        setupEmptyState()
        
        bgPattern.isUserInteractionEnabled = false
    }

    /// Кастомный Navigation Bar. Используем собственный вью вместо системного, 
    /// чтобы иметь полный контроль над прозрачностью и интеграцией фонового узора.
    private func setupCustomHeader() {
        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.headerHeight)
        ])
        
        // Фоновый паттерн для навигационной панели (монолитность)
        let headerPatternView = UIView()
        customNavBar.addSubview(headerPatternView)
        headerPatternView.pin(to: customNavBar)
        if let pattern = JapaneseDesign.drawSeigaiha() {
            headerPatternView.backgroundColor = UIColor(patternImage: pattern)
            headerPatternView.alpha = 0.4
        }
        
        // Эффект размытия (Blured Background)
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        customNavBar.addSubview(blur)
        blur.pin(to: customNavBar)
        
        let logoImage = UIImageView(image: UIImage(named: "app_logo"))
        logoImage.contentMode = .scaleAspectFit
        customNavBar.addSubview(logoImage)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImage.leadingAnchor.constraint(equalTo: customNavBar.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            logoImage.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: -10),
            logoImage.widthAnchor.constraint(equalToConstant: 40),
            logoImage.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Нажатие на логотип/заголовок для возврата наверх
        let tap = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
        customNavBar.addGestureRecognizer(tap)
        customNavBar.isUserInteractionEnabled = true
        
        // Кастомный заголовок: 新聞 • Вести (Вести выделено цветом)
        let fullText = "新聞 • Вести"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "Вести")
        attributedString.addAttribute(.foregroundColor, value: Constants.vestiColor, range: range)
        
        titleLabel.attributedText = attributedString
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        customNavBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor)
        ])
    }
    
    /// Панель управления («Плавающий остров»). Располагается поверх контента, 
    /// используя Blur Effect для отделения интерактивной зоны от новостной ленты.
    private func setupFloatingIsland() {
        view.addSubview(islandContainer)
        islandContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Тень контейнера острова
        islandContainer.layer.shadowColor = UIColor.black.cgColor
        islandContainer.layer.shadowOpacity = 0.25
        islandContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        islandContainer.layer.shadowRadius = 15
        
        islandContainer.addSubview(floatingIsland)
        floatingIsland.pin(to: islandContainer)
        floatingIsland.layer.cornerRadius = 35 // Капсульная форма
        floatingIsland.clipsToBounds = true
        
        // Стек кнопок внутри острова
        let stack = UIStackView(arrangedSubviews: [reloadBtn, japanBtn, diceBtn, sensuBtn, heartBtn])
        stack.axis = .horizontal
        stack.spacing = 15
        stack.alignment = .center
        stack.distribution = .equalSpacing
        
        floatingIsland.contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: floatingIsland.contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: floatingIsland.contentView.centerYAnchor),
            stack.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
        
        // Размещение острова внизу экрана
        NSLayoutConstraint.activate([
            islandContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.islandBottomOffset),
            islandContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            islandContainer.heightAnchor.constraint(equalToConstant: Constants.islandHeight),
            islandContainer.widthAnchor.constraint(equalToConstant: Constants.islandWidth)
        ])
        
        // Таргеты кнопок
        reloadBtn.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        diceBtn.addTarget(self, action: #selector(diceTapped), for: .touchUpInside)
        japanBtn.addTarget(self, action: #selector(japanTapped), for: .touchUpInside)
        sensuBtn.addTarget(self, action: #selector(sensuTapped), for: .touchUpInside)
        heartBtn.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
    }

    /// Контейнер для пустых состояний и анимации загрузки
    private func setupEmptyState() {
        view.addSubview(nekoContainer)
        nekoContainer.pinCenter(to: view)
        nekoContainer.setWidth(Constants.nekoSize.width + 40)
        nekoContainer.setHeight(Constants.nekoSize.height + 80)
        
        nekoImageView.contentMode = .scaleAspectFit
        nekoContainer.addSubview(nekoImageView)
        nekoImageView.pinCenterX(to: nekoContainer)
        nekoImageView.pinTop(to: nekoContainer)
        nekoImageView.setWidth(Constants.nekoSize.width)
        nekoImageView.setHeight(Constants.nekoSize.height)
        
        nekoLabel.text = "" // Изначально текста нет, только котик
        nekoLabel.numberOfLines = 0
        nekoLabel.textAlignment = .center
        nekoLabel.font = JapaneseDesign.titleFont(size: 24)
        nekoLabel.textColor = JapaneseDesign.shobuPurple
        nekoContainer.addSubview(nekoLabel)
        nekoLabel.pinTop(to: nekoImageView.bottomAnchor, 25)
        nekoLabel.pinHorizontal(to: nekoContainer)
        
        nekoContainer.isHidden = true
        startFloatingAnimation()
    }
    
    /// Плавное парение (Idle-состояние)
    private func startFloatingAnimation() {
        if nekoImageView.layer.animation(forKey: "floating") != nil { return }
        
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = -15
        animation.duration = Constants.floatingDuration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        nekoImageView.layer.add(animation, forKey: "floating")
    }
    
    /// Режим активной загрузки. Переключаем котика из режима спокойного парения 
    /// в режим прыжков, создавая визуальный акцент на процессе подгрузки данных.
    func showLoading() {
        DispatchQueue.main.async {
            self.nekoContainer.isHidden = false
            // По требованию: надпись при загрузке должна быть "Вестей пока нет..."
            self.nekoLabel.text = "Вестей пока нет..." 
            
            // Сброс предыдущих анимаций и запуск новой (бесконечный прыжок)
            self.nekoImageView.layer.removeAllAnimations()
            
            let animation = CABasicAnimation(keyPath: "transform.translation.y")
            animation.fromValue = 0
            animation.toValue = -40
            animation.duration = 0.5
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            self.nekoImageView.layer.add(animation, forKey: "jumpLoading")
        }
    }
    
    /// Завершение загрузки с обновлением текста заглушки
    func hideLoading() {
        DispatchQueue.main.async {
            // Возврат к стандартной анимации парения, если список пуст
            self.nekoImageView.layer.removeAnimation(forKey: "jumpLoading")
            self.startFloatingAnimation()
            
            if self.news.isEmpty {
                self.nekoLabel.text = self.isJapanFilterActive ? "Новостей про Японию пока нет..." : "Вестей пока нет..."
                self.nekoContainer.isHidden = false
            } else {
                self.nekoContainer.isHidden = true
                self.nekoLabel.text = ""
            }
        }
    }
    
    // ... rest of logic
    
    @objc private func logoTapped() { 
        // Renamed to reloadTapped logic, but user might tap title to scroll top?
        tableView.setContentOffset(.zero, animated: true)
    }
    
    @objc private func reloadTapped() {
        haptic.impactOccurred()
        // Rotate animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 0.5
        reloadBtn.layer.add(rotation, forKey: "spin")
        presenter?.didTapLogo() // Re-use refresh logic
    }
    
    @objc private func diceTapped() { haptic.impactOccurred(); presenter?.didTapRandom() }
    @objc private func japanTapped() { haptic.impactOccurred(); presenter?.didTapJapanFilter() }
    @objc private func sensuTapped() { haptic.impactOccurred(); presenter?.didTapStoriesMode() }
    @objc private func favoritesTapped() { haptic.impactOccurred(); presenter?.didTapFavorites() }

    /// Полное обновление списка статей
    func update(with news: [ArticleModel]) {
        self.news = news
        DispatchQueue.main.async {
            // Если новости есть — скрываем котика, иначе показываем его с текстом об отсутствии
            if news.isEmpty {
                self.nekoLabel.text = self.isJapanFilterActive ? "Новостей про Японию пока нет..." : "Вестей пока нет..."
                self.nekoContainer.isHidden = false
                self.startFloatingAnimation()
            } else {
                self.nekoContainer.isHidden = true
                self.nekoLabel.text = ""
            }
            self.tableView.reloadData()
            self.animateTable()
        }
    }
    
    /// Каскадное появление ячеек снизу вверх
    private func animateTable() {
        let cells = tableView.visibleCells
        let tableHeight = tableView.bounds.size.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var delayCounter = 0
        for cell in cells {
            UIView.animate(withDuration: 0.8, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = .identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
    func append(news: [ArticleModel]) {
        let currentCount = self.news.count
        self.news.append(contentsOf: news)
        let indexPaths = (currentCount..<self.news.count).map { IndexPath(row: $0, section: 0) }
        DispatchQueue.main.async {
            self.tableView.insertRows(at: indexPaths, with: .fade)
        }
    }

    /// Визуальная индикация активности фильтра. Применяем Scale Transform для «вдавливания» 
    /// кнопки и меняем фон на полупрозрачный акцентный цвет.
    func setJapanFilterActive(_ active: Bool) {
        self.isJapanFilterActive = active
        UIView.animate(withDuration: Constants.animationDuration) {
            self.japanBtn.transform = active ? CGAffineTransform(scaleX: Constants.filterScale, y: Constants.filterScale) : .identity
            self.japanBtn.backgroundColor = active ? JapaneseDesign.shobuPurple.withAlphaComponent(0.1) : .white
        }
        // Force update text if showing empty state
        if news.isEmpty, !nekoContainer.isHidden {
             self.nekoLabel.text = active ? "Новостей про Японию пока нет..." : "Вестей пока нет..."
        }
    }
}

// Обработка данных и скролла таблицы
extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { news.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else { return UITableViewCell() }
        cell.configure(with: news[indexPath.row])
        return cell
    }
    
    // Свайп влево для шаринга статьи
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completion in
            guard let self = self, let url = self.news[indexPath.row].articleUrl else { return }
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(activity, animated: true)
            completion(true)
        }
        action.backgroundColor = JapaneseDesign.shobuPurple
        action.image = UIImage(systemName: "square.and.arrow.up")
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { presenter?.didTapCell(at: indexPath.row) }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        // Пагинация при прокрутке к нижнему краю
        if offsetY > contentHeight - scrollView.frame.height * 1.5 {
            presenter?.didScrollToBottom()
        }
    }
}
