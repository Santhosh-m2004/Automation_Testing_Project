package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class CheckoutPage {
    private WebDriver driver;
    private WaitUtils waitUtils;
    private By addressField = By.id("address");
    private By phoneField = By.id("phone");
    private By placeOrderBtn = By.cssSelector("#checkoutForm button[type='submit']");

    public CheckoutPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void placeOrder(String address, String phone) {
        waitUtils.waitForElementVisible(addressField).sendKeys(address);
        driver.findElement(phoneField).sendKeys(phone);
        waitUtils.waitForElementClickable(placeOrderBtn).click();
        waitUtils.waitForAlertAndAccept();
        waitUtils.waitForPageLoad();
    }
}
