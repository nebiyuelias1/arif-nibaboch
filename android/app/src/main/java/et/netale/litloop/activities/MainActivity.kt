package et.netale.litloop.activities

import android.os.Bundle
import android.view.View
import androidx.activity.enableEdgeToEdge
import com.google.android.material.bottomnavigation.BottomNavigationView
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
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        findViewById<View>(R.id.main).applyDefaultImeWindowInsets()
        initializeBottomTabs()
    }

    private fun initializeBottomTabs() {
        val bottomNavigationView =
            findViewById<BottomNavigationView>(R.id.bottom_nav)

        bottomNavigationController =
            HotwireBottomNavigationController(this, bottomNavigationView)
        bottomNavigationController.load(mainTabs, 0)
    }
}