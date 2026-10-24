package et.netale.litloop.activities

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatDelegate
import com.google.android.material.bottomnavigation.BottomNavigationView
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.turbo.config.PathConfiguration
import dev.hotwire.navigation.activities.HotwireActivity
import dev.hotwire.navigation.navigator.Navigator
import dev.hotwire.navigation.tabs.HotwireBottomNavigationController
import dev.hotwire.navigation.tabs.navigatorConfigurations
import dev.hotwire.navigation.util.applyDefaultImeWindowInsets
import et.netale.litloop.R
import et.netale.litloop.models.mainTabs

const val baseURL = "https://litloop.club/"

class MainActivity : HotwireActivity() {
    private lateinit var bottomNavigationController: HotwireBottomNavigationController
    private var pendingDeepLink: DeepLink? = null

    private data class DeepLink(val url: String, val tabIndex: Int)

    override fun navigatorConfigurations() = mainTabs.navigatorConfigurations

    override fun onCreate(savedInstanceState: Bundle?) {
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        findViewById<View>(R.id.main).applyDefaultImeWindowInsets()
        initializeBottomTabs()
        Hotwire.loadPathConfiguration(
            context = this,
            location = PathConfiguration.Location(
                remoteFileUrl = "$baseURL/configurations/android_v1.json"
            )
        )

        if (savedInstanceState == null) {
            queueDeepLink(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        queueDeepLink(intent)
    }

    override fun onNavigatorReady(navigator: Navigator) {
        super.onNavigatorReady(navigator)
        val pending = pendingDeepLink ?: return
        val targetTab = mainTabs.getOrNull(pending.tabIndex) ?: return
        if (navigator.configuration.name != targetTab.configuration.name) return

        selectTabIfNeeded(pending.tabIndex)
        routeDeepLinkWhenReady(navigator, pending)
    }

    private fun queueDeepLink(intent: Intent?) {
        val uri = intent?.data ?: return
        val targetUrl = resolveTargetUrl(uri) ?: return
        val pending = DeepLink(targetUrl, findTargetTabIndex(targetUrl))
        pendingDeepLink = pending

        routeDeepLinkIfReady(pending)
    }

    private fun routeDeepLinkIfReady(pending: DeepLink) {
        if (!::bottomNavigationController.isInitialized) return

        selectTabIfNeeded(pending.tabIndex)

        val targetTab = mainTabs.getOrNull(pending.tabIndex) ?: return
        val navigator = delegate.findNavigatorHost(targetTab.configuration.navigatorHostId)
            ?.takeIf { it.isReady() }
            ?.navigator
            ?: return

        routeDeepLinkWhenReady(navigator, pending)
    }

    private fun routeDeepLinkWhenReady(navigator: Navigator, pending: DeepLink) {
        val hostView = navigator.host.view ?: window.decorView

        hostView.post {
            if (pendingDeepLink != pending || isFinishing || isDestroyed) return@post

            selectTabIfNeeded(pending.tabIndex)
            pendingDeepLink = null
            navigator.route(pending.url)
        }
    }

    private fun selectTabIfNeeded(tabIndex: Int) {
        if (bottomNavigationController.view.selectedItemId != tabIndex) {
            bottomNavigationController.selectTab(tabIndex)
        }
    }

    private fun resolveTargetUrl(uri: Uri): String? {
        return when (uri.scheme?.lowercase()) {
            "litloop" -> {
                val path = (uri.host ?: "") + (uri.encodedPath ?: "")
                val query = uri.encodedQuery?.let { "?$it" } ?: ""
                val fragment = uri.encodedFragment?.let { "#$it" } ?: ""
                "${baseURL.trimEnd('/')}/${path.trimStart('/')}$query$fragment"
            }
            "http", "https" -> uri.toString()
            else -> null
        }
    }

    private fun findTargetTabIndex(url: String): Int {
        val path = Uri.parse(url).path ?: return 0
        return when {
            path.startsWith("/library") || path.startsWith("/books") -> 1
            path.startsWith("/book_clubs") -> 2
            path.startsWith("/profile") || path.startsWith("/users") -> 3
            else -> 0
        }
    }

    private fun initializeBottomTabs() {
        val bottomNavigationView =
            findViewById<BottomNavigationView>(R.id.bottom_nav)

        bottomNavigationController =
            HotwireBottomNavigationController(this, bottomNavigationView)
        bottomNavigationController.load(mainTabs, 0)
    }
}
