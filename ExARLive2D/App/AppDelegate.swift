import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: initialize settings

        let isNotFirstRun = UserDefaults.standard.bool(forKey: SETTINGS.key.FIRST_RUN)
        if !isNotFirstRun {
            UserDefaults.standard.set(true, forKey: SETTINGS.key.FIRST_RUN)
            SETTINGS.setAllToDefaultValue()
        }
        return true
    }
}
