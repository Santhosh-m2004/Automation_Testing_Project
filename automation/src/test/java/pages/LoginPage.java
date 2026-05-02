package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class LoginPage {
    private WebDriver driver;
    private WaitUtils waitUtils;

    private By navLoginLink = By.cssSelector("#authLinks a[href='/login.html']");
    private By emailInput = By.id("email");
    private By passwordInput = By.id("password");
    private By loginButton = By.cssSelector("button[type='submit']");
    private By errorMessage = By.cssSelector(".error-message");
    private By profileLink = By.cssSelector("a[href='/profile.html']");

    public LoginPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void goToLoginPage() {
        waitUtils.waitForElementClickable(navLoginLink).click();
        waitUtils.waitForElementVisible(emailInput);
    }

    public void login(String email, String password) {
        waitUtils.waitForElementVisible(emailInput).sendKeys(email);
        driver.findElement(passwordInput).sendKeys(password);
        waitUtils.waitForElementClickable(loginButton).click();
        waitUtils.waitForPageLoad();
    }

    public boolean isLoggedIn() {
        return driver.findElements(profileLink).size() > 0;
    }

    public boolean isErrorMessageDisplayed() {
        return waitUtils.waitForElementVisible(errorMessage).isDisplayed();
    }
}
