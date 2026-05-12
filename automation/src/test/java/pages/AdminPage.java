package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.Select;

public class AdminPage {
    private WebDriver driver;
    private WaitUtils waitUtils;
    private By statsCards = By.cssSelector(".stat-card");
    private By orderStatusSelect = By.cssSelector(".order-status");
    private By productName = By.id("productName");
    private By productDesc = By.id("productDesc");
    private By productPrice = By.id("productPrice");
    private By productImage = By.id("productImage");
    private By productCategory = By.id("productCategory");
    private By productStock = By.id("productStock");
    private By addProductBtn = By.cssSelector("#addProductForm button");

    public AdminPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public int getStatsCount() {
        return driver.findElements(statsCards).size();
    }

    public void updateFirstOrderStatus(String status) {
        if (driver.findElements(orderStatusSelect).size() > 0) {
            Select select = new Select(driver.findElements(orderStatusSelect).get(0));
            select.selectByVisibleText(status);
            waitUtils.waitForAlertAndAccept();
        }
    }

    public void addProduct(String name, String desc, double price, String imageUrl, String category, int stock) {
        waitUtils.waitForElementVisible(productName).sendKeys(name);
        driver.findElement(productDesc).sendKeys(desc);
        driver.findElement(productPrice).sendKeys(String.valueOf(price));
        driver.findElement(productImage).sendKeys(imageUrl);
        driver.findElement(productCategory).sendKeys(category);
        driver.findElement(productStock).sendKeys(String.valueOf(stock));
        waitUtils.waitForElementClickable(addProductBtn).click();
        waitUtils.waitForAlertAndAccept();
        waitUtils.waitForPageLoad();
    }
}
