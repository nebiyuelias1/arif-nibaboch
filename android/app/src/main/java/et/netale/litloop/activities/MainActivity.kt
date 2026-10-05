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
import dev.hotwire.navigation.tabs.HotwireBottomNavigationController
import dev.hotwire.navigation.tabs.navigatorConfigurations
import dev.hotwire.navigation.util.applyDefaultImeWindowInsets
import et.netale.litloop.R
import et.netale.litloop.models.mainTabs

const val baseURL = "https://litloop.club/"

class MainActivity : HotwireActivity() {
    private lateinit var bottomNavigationController: HotwireBottomNavigationController

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
            handleDeepLink(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent?) {
        val uri = intent?.data ?: return
        val targetUrl = resolveTargetUrl(uri) ?: return
        val targetTabIndex = findTargetTabIndex(targetUrl)

        bottomNavigationController.selectTab(targetTabIndex)
        bottomNavigationController.route(targetUrl)
    }

    private fun resolveTargetUrl(uri: Uri): String? {
        return when (uri.scheme?.lowercase()) {
            "litloop" -> {
                val path = (uri.host ?: "") + (uri.path ?: "")
                val query = uri.query?.let { "?$it" } ?: ""
                "${baseURL.trimEnd('/')}/${path.trimStart('/')}$query"
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
