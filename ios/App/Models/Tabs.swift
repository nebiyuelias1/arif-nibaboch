//
//  Tabs.swift
//  LitLoop
//
//  Created by Nebiyu Talefe on 2026/7/18.
//

import HotwireNative
import UIKit

private let homeTab = HotwireTab(
    title: "Home",
    image: UIImage(systemName: "house")!,
    url: baseURL.appending(path: "")
)

private let libraryTab = HotwireTab(
    title: "Library",
    image: UIImage(systemName: "books.vertical")!,
    url: baseURL.appending(path: "library")
)

private let clubsTab = HotwireTab(
    title: "Clubs",
    image: UIImage(systemName: "person.3")!,
    url: baseURL.appending(path: "book_clubs")
)

private let profileTab = HotwireTab(
    title: "Profile",
    image: UIImage(systemName: "person.crop.circle")!,
    url: baseURL.appending(path: "profile")
)

extension HotwireTab {
    static let all = [
        homeTab,
        libraryTab,
        clubsTab,
        profileTab,
    ]
}
