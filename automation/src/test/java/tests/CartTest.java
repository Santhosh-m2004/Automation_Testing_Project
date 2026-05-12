package tests;

import pages.*;
import org.testng.Assert;
import org.testng.annotations.Test;

public class CartTest extends BaseTestWithLogin {

    @Test
    public void testAddToCartAndRemove() {
        HomePage home = new HomePage(driver);
        home.waitForProductGrid();
        home.clickFirstProduct();
        ProductPage product = new ProductPage(driver);
        product.addToCart(1);
        CartPage cart = new CartPage(driver);
        cart.goToCart();
        Assert.assertTrue(cart.getCartItemCount() > 0,
                "Cart should contain item");
        cart.removeFirstItem();
        Assert.assertTrue(cart.isCartEmpty(),
                "Cart should be empty after removal");
    }

    @Test
    public void testCheckoutFlow() {
        HomePage home = new HomePage(driver);
        home.waitForProductGrid();
        home.clickFirstProduct();
        ProductPage product = new ProductPage(driver);
        product.addToCart(1);
        CartPage cart = new CartPage(driver);
        cart.goToCart();
        cart.proceedToCheckout();
        CheckoutPage checkout = new CheckoutPage(driver);
        checkout.placeOrder("123 Test St", "9876543210");
        Assert.assertTrue(driver.getCurrentUrl().equals(baseUrl) ||
                driver.getCurrentUrl().equals(baseUrl + "/"),
                "Should redirect to home after order");
    }
}
