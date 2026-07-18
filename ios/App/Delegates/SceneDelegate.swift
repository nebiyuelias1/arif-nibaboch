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
    
    private let navigator = Navigator(configuration: .init(
        name: "main",
        startLocation: baseURL.appending(path: "/")
    ))

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        window?.rootViewController = tabBarController
        tabBarController.load(HotwireTab.all)
    }
}
