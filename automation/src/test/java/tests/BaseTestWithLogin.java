package tests;

import base.BaseTest;
import pages.LoginPage;
import org.testng.annotations.BeforeMethod;

public class BaseTestWithLogin extends BaseTest {
    protected LoginPage loginPage;

    @BeforeMethod
    public void login() {
        loginPage = new LoginPage(driver);
        driver.get(baseUrl + "/login.html");
        loginPage.login("test@example.com", "password123");
    }
}
