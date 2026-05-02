package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class HomePage {
    private WebDriver driver;
    private WaitUtils waitUtils;

    private By productCards = By.cssSelector(".product-card");
    private By firstProductCard = By.cssSelector(".product-card:first-child");
    private By searchInput = By.id("searchInput");
    private By searchBtn = By.id("searchBtn");

    public HomePage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void waitForProductsLoaded() {
        waitUtils.waitForProductCardsToLoad();
    }

    public int getProductCount() {
        waitUtils.waitForProductCardsToLoad();
        return driver.findElements(productCards).size();
    }

    public void clickFirstProduct() {
        waitUtils.waitForProductCardsToLoad();
        WebElement product = waitUtils.waitForElementClickable(firstProductCard);
        product.click();
        waitUtils.waitForPageLoad();
    }
}
