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
