package tests;

import base.BaseTest;
import pages.HomePage;
import pages.LoginPage;
import org.testng.Assert;
import org.testng.annotations.Test;

public class HomePageTest extends BaseTest {

    @Test
    public void testMarketingContentWhenNotLoggedIn() {
        HomePage home = new HomePage(driver);
        Assert.assertTrue(home.isMarketingContentDisplayed(),
                "Marketing content should be visible for logged-out users");
        // Should NOT wait long; just check absence quickly
        Assert.assertFalse(home.isProductGridDisplayed(),
                "Product grid should NOT be displayed when logged out");
    }

    @Test
    public void testProductGridAfterLogin() {
        LoginPage login = new LoginPage(driver);
        driver.get(baseUrl + "/login.html");
        login.login("test@example.com", "password123");
        HomePage home = new HomePage(driver);
        home.waitForProductGrid();  // now explicitly wait for grid
        Assert.assertTrue(home.isProductGridDisplayed(),
                "Product grid should be displayed after login");
        Assert.assertTrue(home.getProductCount() > 0,
                "At least one product should be shown");
    }
}
