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
