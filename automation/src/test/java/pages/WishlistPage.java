package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class WishlistPage {
    private WebDriver driver;
    private WaitUtils waitUtils;
    private By wishlistLink = By.cssSelector("a[href='/wishlist.html']");
    private By wishlistItems = By.cssSelector(".product-card");
    private By removeBtn = By.cssSelector(".remove-wishlist");
    private By emptyMsg = By.cssSelector(".empty-cart");

    public WishlistPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void goToWishlist() {
        waitUtils.waitForElementClickable(wishlistLink).click();
        waitUtils.waitForPageLoad();
    }

    public int getWishlistItemCount() {
        return driver.findElements(wishlistItems).size();
    }

    public void removeFirstItem() {
        waitUtils.waitForElementClickable(removeBtn).click();
        waitUtils.waitForPageLoad();
    }

    public boolean isWishlistEmpty() {
        return driver.findElements(emptyMsg).size() > 0;
    }
}
