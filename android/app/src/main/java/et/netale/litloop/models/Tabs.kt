package et.netale.litloop.models

import dev.hotwire.navigation.navigator.NavigatorConfiguration
import dev.hotwire.navigation.tabs.HotwireBottomTab
import et.netale.litloop.R
import et.netale.litloop.activities.baseURL

private val home = HotwireBottomTab(
    title = "Home",
    iconResId = R.drawable.ic_home,
    configuration = NavigatorConfiguration(
        name = "home",
        navigatorHostId = R.id.home_nav_host,
        startLocation = baseURL
    )
)

private val library = HotwireBottomTab(
    title = "Library",
    iconResId = R.drawable.ic_library,
    configuration = NavigatorConfiguration(
        name = "library",
        navigatorHostId = R.id.library_nav_host,
        startLocation = "${baseURL}library"
    )
)

private val clubs = HotwireBottomTab(
    title = "Clubs",
    iconResId = R.drawable.ic_clubs,
    configuration = NavigatorConfiguration(
        name = "clubs",
        navigatorHostId = R.id.clubs_nav_host,
        startLocation = "${baseURL}book_clubs"
    )
)

private val profile = HotwireBottomTab(
    title = "Profile",
    iconResId = R.drawable.ic_profile,
    configuration = NavigatorConfiguration(
        name = "profile",
        navigatorHostId = R.id.profile_nav_host,
        startLocation = "${baseURL}profile"
    )
)

val mainTabs = listOf(
    home,
    library,
    clubs,
    profile,
)

