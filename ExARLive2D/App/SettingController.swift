import UIKit

class SettingController: UIViewController {
    // MARK: - Background Color

    private let setBackgroundColorButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Background Color", for: .normal)
        button.addTarget(self, action: #selector(handleChangeColor), for: .touchUpInside)
        return button
    }()

    @objc private func handleChangeColor() {
        let defaults = UserDefaults.standard

        let alert = UIAlertController(title: "Backgroud Color Panel", message: "RGB values are in [0, 255]", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Red"
            textField.text = "\(defaults.integer(forKey: SETTINGS.key.RED))"
            textField.keyboardType = .numberPad
        }

        alert.addTextField { textField in
            textField.placeholder = "Green"
            textField.text = "\(defaults.integer(forKey: SETTINGS.key.GREEN))"
            textField.keyboardType = .numberPad
        }

        alert.addTextField { textField in
            textField.placeholder = "Blue"
            textField.text = "\(defaults.integer(forKey: SETTINGS.key.BLUE))"
            textField.keyboardType = .numberPad
        }

        guard let colorTextFields = alert.textFields else {
            fatalError("Fatal Error")
        }

        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            var r = 0
            var g = 0
            var b = 0
            for colortextfield in colorTextFields {
                guard let numberstring = colortextfield.text else {
                    self.displayAlert(title: "Unsuccessful", message: "Some error occurred.")
                    return
                }

                if numberstring.isEmpty {
                    self.displayAlert(title: "Unsuccessful", message: "Please fill all fields.")
                    return
                }

                let numberOnly = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: numberstring))

                if numberOnly {
                    guard let colorvalue = Int(numberstring) else {
                        fatalError("Fatal Error")
                    }
                    if colorvalue < 0 || colorvalue > 255 {
                        self.displayAlert(title: "Unsuccessful", message: "Number is not in range [0, 255].")
                        return
                    } else {
                        guard let index = colorTextFields.firstIndex(of: colortextfield) else {
                            fatalError("Fatal Error")
                        }
                        switch index {
                        case 0:
                            r = colorvalue
                        case 1:
                            b = colorvalue
                        case 2:
                            g = colorvalue
                        default:
                            fatalError("Fatal Error")
                        }
                    }
                } else {
                    self.displayAlert(title: "Unsuccessful", message: "Please enter number only")
                }
            }

            defaults.set(r, forKey: SETTINGS.key.RED)
            defaults.set(g, forKey: SETTINGS.key.GREEN)
            defaults.set(b, forKey: SETTINGS.key.BLUE)

            self.updateInfo()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Zoom

    private let zoomTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Zoom"
        label.textColor = .white
        return label
    }()

    private let setZoomSlider: UISlider = {
        let defaults = UserDefaults.standard
        let slider = UISlider()
        slider.maximumValue = 4
        slider.value = defaults.float(forKey: SETTINGS.key.ZOOM)
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(handleSlideZoom), for: .valueChanged)
        return slider
    }()

    @objc private func handleSlideZoom() {
        let defaults = UserDefaults.standard
        defaults.set(setZoomSlider.value, forKey: SETTINGS.key.ZOOM)
        updateInfo()
    }

    // MARK: - XY position

    private let setYPositionSlider: UISlider = {
        let defaults = UserDefaults.standard
        let slider = UISlider()
        slider.maximumValue = 3
        slider.value = defaults.float(forKey: SETTINGS.key.Y)
        slider.minimumValue = -4
        slider.addTarget(self, action: #selector(handleYPos), for: .valueChanged)
        return slider
    }()

    private let yPosLabel: UILabel = {
        let label = UILabel()
        label.text = "Y"
        label.textColor = .white
        return label
    }()

    @objc private func handleYPos() {
        let defaults = UserDefaults.standard
        defaults.set(setYPositionSlider.value, forKey: SETTINGS.key.Y)
        updateInfo()
    }

    private let setXPositionSlider: UISlider = {
        let defaults = UserDefaults.standard
        let slider = UISlider()
        slider.maximumValue = 2
        slider.value = defaults.float(forKey: SETTINGS.key.X)
        slider.minimumValue = -2
        slider.addTarget(self, action: #selector(handleXPos), for: .valueChanged)
        return slider
    }()

    private let xPosLabel: UILabel = {
        let label = UILabel()
        label.text = "X"
        label.textColor = .white
        return label
    }()

    @objc private func handleXPos() {
        let defaults = UserDefaults.standard
        defaults.set(setXPositionSlider.value, forKey: SETTINGS.key.X)
        updateInfo()
    }

    // MARK: - infoTextView

    private let infoTextView: UITextView = {
        let textview = UITextView()
        textview.backgroundColor = .clear
        textview.isEditable = false
        textview.isScrollEnabled = false
        textview.textColor = .white
        textview.textAlignment = .center
        return textview
    }()

    private func generateInfo() -> String {
        let r = UserDefaults.standard.integer(forKey: SETTINGS.key.RED)
        let g = UserDefaults.standard.integer(forKey: SETTINGS.key.GREEN)
        let b = UserDefaults.standard.integer(forKey: SETTINGS.key.BLUE)

        let zoom = UserDefaults.standard.float(forKey: SETTINGS.key.ZOOM)
        let y_pos = UserDefaults.standard.float(forKey: SETTINGS.key.X)
        let x_pos = UserDefaults.standard.float(forKey: SETTINGS.key.Y)

        let info = "R: \(r) G: \(g) B: \(b)\n\nZoom: \(String(format: "%.2f", zoom))\nX-Pos: \(String(format: "%.2f", y_pos))\nY-Pos: \(String(format: "%.2f", x_pos))\n"
        return info
    }

    private func updateInfo() {
        infoTextView.text = generateInfo()
    }

    // MARK: - restore

    private let restoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("Restore Default Settings", for: .normal)
        button.addTarget(self, action: #selector(handleRestore), for: .touchUpInside)
        return button
    }()

    @objc private func handleRestore() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you to restore default settings?\n Your settings before will be stored in the pasteboard.", preferredStyle: .alert)
        alert.addAction(.init(title: "Restore", style: .destructive, handler: { _ in
            let oldInfo = self.generateInfo()
            let pasteboard = UIPasteboard.general
            pasteboard.string = oldInfo

            SETTINGS.setAllToDefaultValue()

            self.updateInfo()
        }))

        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateInfo()

        // MARK: - layout

        zoomTitleLabel.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        let zoomStackView = UIStackView(arrangedSubviews: [zoomTitleLabel, setZoomSlider])
        zoomStackView.axis = .horizontal
        zoomStackView.spacing = 8

        xPosLabel.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        let xPosStackView = UIStackView(arrangedSubviews: [xPosLabel, setXPositionSlider])
        xPosStackView.axis = .horizontal
        xPosStackView.spacing = 8

        yPosLabel.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        let yPosStackView = UIStackView(arrangedSubviews: [yPosLabel, setYPositionSlider])
        yPosStackView.axis = .horizontal
        yPosStackView.spacing = 8

        let mainStackView = UIStackView(arrangedSubviews: [zoomStackView, xPosStackView, yPosStackView, setBackgroundColorButton])
        mainStackView.axis = .vertical
        mainStackView.spacing = 12

        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24.0).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true

        let subStackView = UIStackView(arrangedSubviews: [infoTextView, restoreButton])
        subStackView.axis = .vertical
        subStackView.spacing = 12

        view.addSubview(subStackView)
        subStackView.translatesAutoresizingMaskIntoConstraints = false
        subStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24.0).isActive = true
        subStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        subStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true

        // MARK: - Other Settings
    }
}

extension SettingController {
    private func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
