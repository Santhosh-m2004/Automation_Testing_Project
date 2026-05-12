package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class CartPage {
    private WebDriver driver;
    private WaitUtils waitUtils;
    private By cartLink = By.cssSelector("a[href='/cart.html']");
    private By cartItems = By.cssSelector(".cart-item");
    private By removeBtn = By.cssSelector(".remove-item");
    private By checkoutBtn = By.cssSelector("a[href='/checkout.html']");
    private By emptyCartMsg = By.cssSelector(".empty-cart");

    public CartPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void goToCart() {
        waitUtils.waitForElementClickable(cartLink).click();
        waitUtils.waitForPageLoad();
    }

    public int getCartItemCount() {
        return driver.findElements(cartItems).size();
    }

    public void removeFirstItem() {
        waitUtils.waitForElementClickable(removeBtn).click();
        waitUtils.waitForPageLoad();
    }

    public void proceedToCheckout() {
        waitUtils.waitForElementClickable(checkoutBtn).click();
        waitUtils.waitForPageLoad();
    }

    public boolean isCartEmpty() {
        return driver.findElements(emptyCartMsg).size() > 0;
    }
}
