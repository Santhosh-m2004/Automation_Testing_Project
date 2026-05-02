package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class ProductPage {
    private WebDriver driver;
    private WaitUtils waitUtils;

    private By productTitle = By.cssSelector(".product-detail-info h1");
    private By quantityInput = By.id("quantity");
    private By addToCartBtn = By.id("addToCartBtn");

    public ProductPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public String getProductTitle() {
        return waitUtils.waitForElementVisible(productTitle).getText();
    }

    public void addToCart(int quantity) {
        waitUtils.waitForElementVisible(quantityInput).clear();
        driver.findElement(quantityInput).sendKeys(String.valueOf(quantity));
        waitUtils.waitForElementClickable(addToCartBtn).click();
        waitUtils.waitForAlertAndAccept();
        waitUtils.waitForPageLoad();
    }
}
