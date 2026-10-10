//
//  SceneDelegate.swift
//  LitLoop
//
//  Created by Nebiyu Talefe on 2026/6/27.
//

import HotwireNative
import UIKit

let baseURL = URL(string: "https://litloop.club/")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private let tabBarController = HotwireTabBarController()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        configureTabBarAppearance()
        window?.rootViewController = tabBarController
        tabBarController.load(HotwireTab.all)

        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleIncomingURL(url)
        } else if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return }
        handleIncomingURL(url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleIncomingURL(url)
    }

    private func handleIncomingURL(_ url: URL) {
        let webURL: URL
        if url.scheme?.lowercased() == "litloop" {
            let incomingComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            let host = incomingComponents.percentEncodedHost ?? ""
            let path = incomingComponents.percentEncodedPath
            let fullPath = (host + path).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.percentEncodedPath = "/" + fullPath
            components.percentEncodedQuery = incomingComponents.percentEncodedQuery
            webURL = components.url ?? baseURL
        } else if url.scheme?.lowercased() == "https" || url.scheme?.lowercased() == "http" {
            webURL = url
        } else {
            return
        }

        let path = webURL.path.lowercased()
        let targetIndex: Int
        if path.hasPrefix("/library") || path.hasPrefix("/books") {
            targetIndex = 1
        } else if path.hasPrefix("/book_clubs") {
            targetIndex = 2
        } else if path.hasPrefix("/profile") || path.hasPrefix("/users") {
            targetIndex = 3
        } else {
            targetIndex = 0
        }

        tabBarController.selectedIndex = targetIndex
        tabBarController.activeNavigator.route(webURL)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
    }
}
