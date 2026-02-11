/*
===============================================================================
Проект: NewsApp - dprakhovPW5, (iOS UIKit Client)
Файл: DesignSystem.swift
Расположение: dprakhowPW5/Helpers/
Назначение: Core design system and custom UI components.
//              Централизованная дизайн-система и кастомные UI-компоненты.
===============================================================================
Дисциплина: НИС - Основы iOS-Разработки на UIKit
Автор: Прахов Данил, БПИ246
Дата создания: 10.02.2026
===============================================================================
*/

import UIKit

// Расширение для работы с Hex-цветами
extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

// Параметры визуального стиля приложения
enum JapaneseDesign {
    // Цветовая палитра
    static let shobuPurple = UIColor(hex: "#8F76E8") // Пурпурный акцент (Shobu-iro)
    static let paperColor = UIColor(hex: "#F5F5F0")  // Цвет традиционной бумаги
    static let inkColor = UIColor(hex: "#1A1A1A")    // Цвет туши
    static let hankoRed = UIColor(hex: "#E63946")    // Цвет печати Hanko

    // Семантические алиасы
    static let accent = shobuPurple
    static let background = paperColor
    static let cardBackground = UIColor.white

    // MARK: Шрифты
    static func titleFont(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .ultraLight)
    }

    /// Генерация текстуры «Сэйгайха» (водные волны) для фона.
    /// Используется CoreGraphics для рисования накладывающихся дуг, создающих эффект глубины.
    static func drawSeigaiha() -> UIImage? {
        let size = CGSize(width: 80, height: 45)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath()
        for r in stride(from: 40, to: 0, by: -8) {
            let circle = UIBezierPath(arcCenter: CGPoint(x: 40, y: 45), radius: CGFloat(r), startAngle: .pi, endAngle: 0, clockwise: true)
            path.append(circle)
        }
        JapaneseDesign.shobuPurple.withAlphaComponent(0.12).setStroke()
        path.lineWidth = 1.0
        path.stroke()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
    }
}

// Эффект мерцания для индикации загрузки (Skeleton View). 
// Работает через анимацию градиентной маски, создавая ощущение движения света по элементу.
extension UIView {
    func startShimmer() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        gradient.add(animation, forKey: "shimmer")
        self.layer.addSublayer(gradient)
    }
    
    func stopShimmer() {
        self.layer.sublayers?.removeAll(where: { $0.animation(forKey: "shimmer") != nil })
    }
}

// Универсальная кнопка с поддержкой теней и анимаций нажатия
final class JapaneseButton: UIButton {
    private enum Constants {
        static let shadowOpacity: Float = 0.2
        static let shadowRadius: CGFloat = 8
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let animationDuration: TimeInterval = 0.15
        static let scaleDown: CGFloat = 0.95
    }
    
    private let size: CGFloat
    
    init(iconName: String, size: CGFloat = 44) {
        self.size = size
        super.init(frame: .zero)
        setup(iconName: iconName)
    }
    
    private func setup(iconName: String) {
        self.backgroundColor = .white
        
        // Настройка теней
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = Constants.shadowOpacity
        self.layer.shadowOffset = Constants.shadowOffset
        self.layer.shadowRadius = Constants.shadowRadius
        self.layer.masksToBounds = false
        
        self.imageView?.contentMode = .scaleAspectFit
        
        // Расчет отступов иконок (сердце требует чуть больше пространства)
        let isHeart = iconName.contains("heart")
        // Составляем размеры для иконок
        // 0.20 = 20% отступа -> иконка занимает 60% ширины
        // 0.18 = для сердец -> 64% ширины
        let paddingScale: CGFloat = isHeart ? 0.18 : 0.20 
        
        let targetIconSize = size * (1.0 - paddingScale * 2)
        let targetSize = CGSize(width: targetIconSize, height: targetIconSize)
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .zero
            config.background.backgroundColor = .clear 
            
            var imageToSet: UIImage?
            
            if let image = UIImage(named: iconName) {
                imageToSet = image.withRenderingMode(.alwaysOriginal)
            } else if let sysImage = UIImage(systemName: iconName) {
                // Окрашиваем системные символы в акцентный цвет
                imageToSet = sysImage.withTintColor(JapaneseDesign.shobuPurple, renderingMode: .alwaysOriginal)
            }
            
            if let img = imageToSet {
                config.image = resizeImage(img, targetSize: targetSize)
            }
            
            self.configuration = config
        } else {
            // Legacy Fallback
            let inset = size * paddingScale
            if let image = UIImage(named: iconName) {
                self.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            } else if let sysImage = UIImage(systemName: iconName) {
                self.setImage(sysImage.withRenderingMode(.alwaysTemplate), for: .normal)
                self.tintColor = JapaneseDesign.shobuPurple
            }
            self.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }
        
        // Constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size),
            self.heightAnchor.constraint(equalToConstant: size)
        ])
    }
    
    /// Смена иконки с плавным переходом
    func updateIcon(_ name: String, animated: Bool = true) {
        let image = (UIImage(named: name) ?? UIImage(systemName: name))?.withRenderingMode(.alwaysOriginal)
        
        if animated {
            UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.updateImageInternal(image)
            }, completion: nil)
        } else {
            self.updateImageInternal(image)
        }
    }
    
    /// Масштабирует изображение до нужного размера под конкретную кнопку.
    /// Это необходимо, так как UIButton.Configuration может игнорировать стандартные режимы контента.
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private func updateImageInternal(_ image: UIImage?) {
        guard let image = image else { return }
        
        // Вычисляем целевой размер иконки (соответствует paddingScale 0.18-0.20)
        let targetIconSize = self.size * 0.62
        let resized = resizeImage(image, targetSize: CGSize(width: targetIconSize, height: targetIconSize))
        
        if #available(iOS 15.0, *) {
            var config = self.configuration ?? UIButton.Configuration.plain()
            config.image = resized
            self.configuration = config
        } else {
            self.setImage(image, for: .normal)
        }
    }
    
    /// Анимация вращения (используется для обновления контента)
    func spin() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 0.6
        self.layer.add(rotation, forKey: "rotation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.transform = self.isHighlighted ? 
                    CGAffineTransform(scaleX: Constants.scaleDown, y: Constants.scaleDown) : .identity
                self.layer.shadowOpacity = self.isHighlighted ? 0.1 : Constants.shadowOpacity
            }, completion: nil)
        }
    }
}
