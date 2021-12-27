import Foundation

struct UserSettings {
    struct Key {
        let FIRST_RUN = "FIRST_RUN"

        let RED = "RED_COLOR"
        let GREEN = "GREEN_COLOR"
        let BLUE = "BLUE_COLOR"

        let ZOOM = "ZOOM"
        let X = "X_POSITION"
        let Y = "Y_POSITION"
    }

    let key = Key()

    func setAllToDefaultValue() {
        UserDefaults.standard.set(0, forKey: USER_SETTINGS.key.RED) // int 0 - 255
        UserDefaults.standard.set(0, forKey: USER_SETTINGS.key.GREEN) // int 0 - 255
        UserDefaults.standard.set(0, forKey: USER_SETTINGS.key.BLUE) // int 0 - 255
        UserDefaults.standard.set(0.694, forKey: USER_SETTINGS.key.ZOOM) // float 0.0 - 4.0
        UserDefaults.standard.set(0, forKey: USER_SETTINGS.key.X) // float -2.0 - 2.0
        UserDefaults.standard.set(-2.434, forKey: USER_SETTINGS.key.Y) // float -3.0 - 4.0
    }
}

let USER_SETTINGS = UserSettings()
