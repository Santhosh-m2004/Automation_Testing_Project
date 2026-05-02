package tests;

import base.BaseTest;
import pages.HomePage;
import pages.LoginPage;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

public class LoginTest extends BaseTest {
    private LoginPage loginPage;

    @BeforeMethod
    public void initPage() {
        loginPage = new LoginPage(driver);
    }

    @Test
    public void testValidLogin() {
        loginPage.goToLoginPage();
        loginPage.login("test@example.com", "password123");
        Assert.assertTrue(loginPage.isLoggedIn(), "User should be logged in");
    }

    @Test
    public void testInvalidLogin() {
        loginPage.goToLoginPage();
        loginPage.login("wrong@example.com", "wrongpass");
        Assert.assertTrue(loginPage.isErrorMessageDisplayed(), "Error message should be displayed");
    }
}
