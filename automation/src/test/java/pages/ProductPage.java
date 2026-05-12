package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.Select;

public class ProductPage {
    private WebDriver driver;
    private WaitUtils waitUtils;
    private By addToCartBtn = By.id("addToCartBtn");
    private By wishlistBtn = By.id("wishlistBtn");
    private By quantityInput = By.id("quantity");
    private By ratingSelect = By.id("ratingSelect");
    private By reviewComment = By.id("reviewComment");
    private By submitReviewBtn = By.id("submitReviewBtn");
    private By reviewList = By.cssSelector(".review");

    public ProductPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void addToCart(int quantity) {
        waitUtils.waitForElementVisible(quantityInput).clear();
        driver.findElement(quantityInput).sendKeys(String.valueOf(quantity));
        waitUtils.waitForElementClickable(addToCartBtn).click();
        waitUtils.waitForAlertAndAccept();
        waitUtils.waitForPageLoad();
    }

    public void addToWishlist() {
        waitUtils.waitForElementClickable(wishlistBtn).click();
        waitUtils.waitForAlertAndAccept();
    }

    public void addReview(int rating, String comment) {
        waitUtils.waitForElementVisible(ratingSelect);
        new Select(driver.findElement(ratingSelect)).selectByValue(String.valueOf(rating));
        driver.findElement(reviewComment).sendKeys(comment);
        waitUtils.waitForElementClickable(submitReviewBtn).click();
        waitUtils.waitForAlertAndAccept();
        waitUtils.waitForPageLoad();
    }

    public int getReviewCount() {
        return driver.findElements(reviewList).size();
    }
}
