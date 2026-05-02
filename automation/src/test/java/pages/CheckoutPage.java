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
    private By orderTotal = By.id("orderTotal");

    public CheckoutPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void fillAddress(String address) {
        waitUtils.waitForElementVisible(addressField).sendKeys(address);
    }

    public void fillPhone(String phone) {
        driver.findElement(phoneField).sendKeys(phone);
    }

    public void placeOrder(String address, String phone) {
        fillAddress(address);
        fillPhone(phone);
        waitUtils.waitForElementClickable(placeOrderBtn).click();
        waitUtils.waitForAlertAndAccept();
        waitUtils.waitForPageLoad();
    }

    public String getOrderTotal() {
        return waitUtils.waitForElementVisible(orderTotal).getText();
    }
}
