package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.List;

public class CartPage {
    private WebDriver driver;
    private WaitUtils waitUtils;

    private By cartLink = By.cssSelector("a[href='/cart.html']");
    private By cartItems = By.cssSelector(".cart-item");
    private By cartItemCount = By.cssSelector(".cart-item");
    public By removeButton = By.cssSelector(".remove-item");
    private By checkoutBtn = By.cssSelector("a[href='/checkout.html']");
    private By cartTotal = By.cssSelector(".cart-total");
    private By emptyCartMsg = By.cssSelector(".empty-cart");

    public CartPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void goToCart() {
        waitUtils.waitForElementClickable(cartLink).click();
        waitUtils.waitForPageLoad();
        waitUtils.waitForElementVisible(cartItems);
    }

    public int getCartItemCount() {
        List<WebElement> items = driver.findElements(cartItems);
        return items.size();
    }

    public boolean isCartEmpty() {
        return driver.findElements(emptyCartMsg).size() > 0;
    }

    public void proceedToCheckout() {
        WebElement checkout = waitUtils.waitForElementClickable(checkoutBtn);
        checkout.click();
        waitUtils.waitForPageLoad();
    }
}
