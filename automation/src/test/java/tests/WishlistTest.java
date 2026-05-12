package tests;

import pages.*;
import org.testng.Assert;
import org.testng.annotations.Test;

public class WishlistTest extends BaseTestWithLogin {

    @Test
    public void testAddToWishlist() {
        HomePage home = new HomePage(driver);
        home.waitForProductGrid();
        home.clickFirstProduct();
        ProductPage product = new ProductPage(driver);
        product.addToWishlist();
        WishlistPage wishlist = new WishlistPage(driver);
        wishlist.goToWishlist();
        Assert.assertTrue(wishlist.getWishlistItemCount() > 0,
                "Wishlist should contain item");
        wishlist.removeFirstItem();
        Assert.assertTrue(wishlist.isWishlistEmpty(),
                "Wishlist should be empty after removal");
    }
}
