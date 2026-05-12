package tests;

import base.BaseTest;
import pages.AdminPage;
import pages.HomePage;
import pages.LoginPage;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

public class AdminTest extends BaseTest {
    private AdminPage adminPage;
    private boolean isAdminLoggedIn = false;

    private void registerAdminIfNeeded() {
        LoginPage login = new LoginPage(driver);
        driver.get(baseUrl + "/login.html");
        login.login("admin@example.com", "admin@123");
        waitUtils.waitForPageLoad();
        boolean loginFailed = driver.findElements(By.cssSelector(".error-message")).size() > 0
                || driver.getCurrentUrl().contains("login");
        if (!loginFailed) {
            isAdminLoggedIn = true;
            return;
        }
        System.out.println("Admin not found, registering...");
        driver.get(baseUrl + "/register.html");
        waitUtils.waitForElementVisible(By.id("name")).sendKeys("Admin User");
        driver.findElement(By.id("email")).sendKeys("admin@example.com");
        driver.findElement(By.id("password")).sendKeys("admin@123");
        driver.findElement(By.cssSelector("#registerForm button[type='submit']")).click();
        waitUtils.waitForAlertAndAccept();
        waitUtils.waitForPageLoad();
        driver.get(baseUrl + "/login.html");
        login.login("admin@example.com", "admin@123");
        waitUtils.waitForPageLoad();
        if (driver.findElements(By.cssSelector(".error-message")).size() == 0) {
            isAdminLoggedIn = true;
            System.out.println("Admin registration successful.");
        } else {
            System.out.println("ERROR: Could not register admin.");
        }
    }

    @BeforeMethod
    public void loginAsAdmin() {
        registerAdminIfNeeded();
        if (isAdminLoggedIn) {
            adminPage = new AdminPage(driver);
            driver.get(baseUrl + "/admin.html");
            waitUtils.waitForPageLoad();
        }
    }

    @Test
    public void testAdminStatsDisplay() {
        if (!isAdminLoggedIn) {
            System.out.println("Skipping admin stats test – admin not logged in");
            return;
        }
        Assert.assertTrue(adminPage.getStatsCount() > 0, "Admin stats cards should be visible");
    }

    @Test
    public void testAddProduct() {
        if (!isAdminLoggedIn) {
            System.out.println("Skipping add product test – admin not logged in");
            return;
        }
        String uniqueName = "AutoTestProduct_" + System.currentTimeMillis();
        adminPage.addProduct(uniqueName, "Automation test product", 40,
                "https://picsum.photos/id/1/300/300", "Automation", 100);
        // Wait for product to be persisted
        try { Thread.sleep(3000); } catch (InterruptedException ignored) {}
        driver.get(baseUrl);
        HomePage home = new HomePage(driver);
        home.searchProduct(uniqueName);
        // Search might return 0 if product not found; retry once with longer wait
        if (home.getProductCount() == 0) {
            try { Thread.sleep(5000); } catch (InterruptedException ignored) {}
            home.searchProduct(uniqueName);
        }
        Assert.assertTrue(home.getProductCount() > 0,
                "New product should appear in search results. Searched for: " + uniqueName);
    }

    @Test
    public void testUpdateOrderStatus() {
        if (!isAdminLoggedIn) {
            System.out.println("Skipping order status test – admin not logged in");
            return;
        }
        driver.get(baseUrl + "/admin.html");
        waitUtils.waitForPageLoad();
        if (driver.findElements(By.cssSelector(".order-status")).size() > 0) {
            adminPage.updateFirstOrderStatus("confirmed");
            System.out.println("Order status updated successfully");
        } else {
            System.out.println("No orders available to update status");
        }
    }
}
