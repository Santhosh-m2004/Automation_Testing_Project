#!/bin/bash

# Create folder structure
mkdir -p automation/src/test/java/base
mkdir -p automation/src/test/java/pages
mkdir -p automation/src/test/java/tests
mkdir -p automation/src/test/resources

# Create pom.xml
cat > automation/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.ecommerce</groupId>
    <artifactId>automation</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.seleniumhq.selenium</groupId>
            <artifactId>selenium-java</artifactId>
            <version>4.15.0</version>
        </dependency>
        <dependency>
            <groupId>org.testng</groupId>
            <artifactId>testng</artifactId>
            <version>7.8.0</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.github.bonigarcia</groupId>
            <artifactId>webdrivermanager</artifactId>
            <version>5.6.2</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.0.0-M7</version>
                <configuration>
                    <suiteXmlFiles>
                        <suiteXmlFile>testng.xml</suiteXmlFile>
                    </suiteXmlFiles>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# Create BaseTest.java
cat > automation/src/test/java/base/BaseTest.java << 'EOF'
package base;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;

import java.time.Duration;

public class BaseTest {
    protected WebDriver driver;
    protected String baseUrl = "http://localhost:5000";
    protected WaitUtils waitUtils;

    @BeforeMethod
    public void setUp() {
        WebDriverManager.chromedriver().setup();
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--remote-allow-origins=*");
        options.addArguments("--disable-blink-features=AutomationControlled");
        driver = new ChromeDriver(options);
        driver.manage().window().maximize();
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(2));
        driver.get(baseUrl);
        waitUtils = new WaitUtils(driver);
    }

    @AfterMethod
    public void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
EOF

# Create WaitUtils.java
cat > automation/src/test/java/base/WaitUtils.java << 'EOF'
package base;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

public class WaitUtils {
    private WebDriver driver;
    private WebDriverWait wait;

    public WaitUtils(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(15));
    }

    public WebElement waitForElementVisible(By locator) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    public WebElement waitForElementClickable(By locator) {
        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    public void waitForPageLoad() {
        wait.until(webDriver -> ((org.openqa.selenium.JavascriptExecutor) webDriver)
                .executeScript("return document.readyState").equals("complete"));
    }

    public void waitForProductCardsToLoad() {
        wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector(".product-card")));
        waitForPageLoad();
    }

    public void waitForAlertAndAccept() {
        try {
            wait.until(ExpectedConditions.alertIsPresent());
            driver.switchTo().alert().accept();
        } catch (Exception ignored) {}
    }
}
EOF

# Create LoginPage.java
cat > automation/src/test/java/pages/LoginPage.java << 'EOF'
package pages;

import base.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class LoginPage {
    private WebDriver driver;
    private WaitUtils waitUtils;

    private By navLoginLink = By.cssSelector("#authLinks a[href='/login.html']");
    private By emailInput = By.id("email");
    private By passwordInput = By.id("password");
    private By loginButton = By.cssSelector("button[type='submit']");
    private By errorMessage = By.cssSelector(".error-message");
    private By profileLink = By.cssSelector("a[href='/profile.html']");

    public LoginPage(WebDriver driver) {
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public void goToLoginPage() {
        waitUtils.waitForElementClickable(navLoginLink).click();
        waitUtils.waitForElementVisible(emailInput);
    }

    public void login(String email, String password) {
        waitUtils.waitForElementVisible(emailInput).sendKeys(email);
        driver.findElement(passwordInput).sendKeys(password);
        waitUtils.waitForElementClickable(loginButton).click();
        waitUtils.waitForPageLoad();
    }

    public boolean isLoggedIn() {
        return driver.findElements(profileLink).size() > 0;
    }

    public boolean isErrorMessageDisplayed() {
        return waitUtils.waitForElementVisible(errorMessage).isDisplayed();
    }
}
EOF

# Create HomePage.java
cat > automation/src/test/java/pages/HomePage.java << 'EOF'
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
EOF

# Create ProductPage.java
cat > automation/src/test/java/pages/ProductPage.java << 'EOF'
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
EOF

# Create CartPage.java
cat > automation/src/test/java/pages/CartPage.java << 'EOF'
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
    private By removeButton = By.cssSelector(".remove-item");
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
EOF

# Create CheckoutPage.java
cat > automation/src/test/java/pages/CheckoutPage.java << 'EOF'
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
EOF

# Create LoginTest.java
cat > automation/src/test/java/tests/LoginTest.java << 'EOF'
package tests;

import base.BaseTest;
import pages.HomePage;
import pages.LoginPage;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

public class LoginTest extends BaseTest {
    private LoginPage loginPage;

    @BeforeMethod
    public void initPage() {
        loginPage = new LoginPage(driver);
    }

    @Test
    public void testValidLogin() {
        loginPage.goToLoginPage();
        loginPage.login("test@example.com", "password123");
        Assert.assertTrue(loginPage.isLoggedIn(), "User should be logged in");
    }

    @Test
    public void testInvalidLogin() {
        loginPage.goToLoginPage();
        loginPage.login("wrong@example.com", "wrongpass");
        Assert.assertTrue(loginPage.isErrorMessageDisplayed(), "Error message should be displayed");
    }
}
EOF

# Create AddToCartTest.java
cat > automation/src/test/java/tests/AddToCartTest.java << 'EOF'
package tests;

import base.BaseTest;
import pages.*;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

public class AddToCartTest extends BaseTest {
    private LoginPage loginPage;
    private HomePage homePage;
    private ProductPage productPage;
    private CartPage cartPage;

    @BeforeMethod
    public void setupTest() {
        loginPage = new LoginPage(driver);
        homePage = new HomePage(driver);
        productPage = new ProductPage(driver);
        cartPage = new CartPage(driver);

        // Login first
        loginPage.goToLoginPage();
        loginPage.login("test@example.com", "password123");
        Assert.assertTrue(loginPage.isLoggedIn(), "Login failed before test");
    }

    @Test
    public void testAddProductToCart() {
        homePage.waitForProductsLoaded();
        int initialCount = homePage.getProductCount();
        Assert.assertTrue(initialCount > 0, "No products displayed");

        homePage.clickFirstProduct();
        String productTitle = productPage.getProductTitle();
        productPage.addToCart(1);

        cartPage.goToCart();
        Assert.assertTrue(cartPage.getCartItemCount() > 0, "Cart should contain at least one item");
    }

    @Test
    public void testRemoveProductFromCart() {
        // First add a product
        homePage.waitForProductsLoaded();
        homePage.clickFirstProduct();
        productPage.addToCart(1);

        cartPage.goToCart();
        int beforeRemove = cartPage.getCartItemCount();
        Assert.assertTrue(beforeRemove > 0, "Cart should have items before removal");

        // Remove first item
        driver.findElement(cartPage.removeButton).click();
        waitUtils.waitForPageLoad();
        Assert.assertTrue(cartPage.isCartEmpty() || cartPage.getCartItemCount() == beforeRemove - 1,
                "Item should be removed");
    }
}
EOF

# Create CheckoutTest.java
cat > automation/src/test/java/tests/CheckoutTest.java << 'EOF'
package tests;

import base.BaseTest;
import pages.*;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

public class CheckoutTest extends BaseTest {
    private LoginPage loginPage;
    private HomePage homePage;
    private ProductPage productPage;
    private CartPage cartPage;
    private CheckoutPage checkoutPage;

    @BeforeMethod
    public void setupTest() {
        loginPage = new LoginPage(driver);
        homePage = new HomePage(driver);
        productPage = new ProductPage(driver);
        cartPage = new CartPage(driver);
        checkoutPage = new CheckoutPage(driver);

        // Login
        loginPage.goToLoginPage();
        loginPage.login("test@example.com", "password123");
        Assert.assertTrue(loginPage.isLoggedIn(), "Login failed");
    }

    @Test
    public void testCompleteCheckoutFlow() {
        // Add product to cart
        homePage.waitForProductsLoaded();
        homePage.clickFirstProduct();
        String productName = productPage.getProductTitle();
        productPage.addToCart(1);

        // Go to cart and checkout
        cartPage.goToCart();
        Assert.assertTrue(cartPage.getCartItemCount() > 0, "Cart should have items");
        cartPage.proceedToCheckout();

        // Fill checkout form
        String address = "123 Automation Street, Testing City";
        String phone = "9876543210";
        checkoutPage.placeOrder(address, phone);

        // After order placed, redirect to home page
        Assert.assertTrue(driver.getCurrentUrl().equals(baseUrl) || driver.getCurrentUrl().equals(baseUrl + "/"),
                "Should redirect to home after order");
    }
}
EOF

# Create testng.xml (parallel disabled)
cat > automation/testng.xml << 'EOF'
<!DOCTYPE suite SYSTEM "http://testng.org/testng-1.0.dtd">
<suite name="Ecommerce Automation Suite" parallel="false">
    <test name="All Tests">
        <classes>
            <class name="tests.LoginTest"/>
            <class name="tests.AddToCartTest"/>
            <class name="tests.CheckoutTest"/>
        </classes>
    </test>
</suite>
EOF

echo "✅ Fixed automation framework created successfully!"
echo ""
echo "Run with:"
echo "cd automation"
echo "mvn clean test"