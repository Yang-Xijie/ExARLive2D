import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func applicationDidFinishLaunching(_: UIApplication) {
        // MARK: - configure app

        // MARK: initialize user settings

        // use user's settings if it is not first run
        let isNotFirstRun = UserDefaults.standard.bool(forKey: USER_SETTINGS.key.FIRST_RUN)
        if !isNotFirstRun {
            UserDefaults.standard.set(true, forKey: USER_SETTINGS.key.FIRST_RUN)
            USER_SETTINGS.setAllToDefaultValue()
        }

        // MARK: app configuration

        // avert system sleep after long-time no operation
        UIApplication.shared.isIdleTimerDisabled = true
    }
}
