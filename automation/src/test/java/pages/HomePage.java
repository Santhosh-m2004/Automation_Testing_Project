package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import java.time.Duration;

public class HomePage {
    private WebDriver driver;
    private WaitUtils waitUtils;
    private By marketingHero = By.cssSelector(".hero-section");
    private By productGrid = By.cssSelector(".product-card");
    private By searchInput = By.id("searchInput");
    private By searchBtn = By.id("searchBtn");

    public HomePage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void waitForProducts() {
        waitUtils.waitForProducts();
    }

    public boolean isMarketingContentDisplayed() {
        return driver.findElements(marketingHero).size() > 0;
    }

    // Checks if product grid is displayed WITHOUT waiting long (used for negative assertion)
    public boolean isProductGridDisplayed() {
        // Short wait to see if product cards appear, but don't fail if not found
        try {
            WebDriverWait shortWait = new WebDriverWait(driver, Duration.ofSeconds(2));
            shortWait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(productGrid));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    // For positive checks we use this after login
    public void waitForProductGrid() {
        waitUtils.waitForProducts();
    }

    public int getProductCount() {
        waitUtils.waitForProducts();
        return driver.findElements(productGrid).size();
    }

    public void clickFirstProduct() {
        waitUtils.waitForProducts();
        waitUtils.waitForElementClickable(productGrid).click();
        waitUtils.waitForPageLoad();
    }

    public void searchProduct(String keyword) {
        waitUtils.waitForElementVisible(searchInput).sendKeys(keyword);
        waitUtils.waitForElementClickable(searchBtn).click();
        waitUtils.waitForPageLoad();
        waitUtils.waitForProducts();
    }
}
