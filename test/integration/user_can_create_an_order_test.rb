require "test_helper"

class UserCanCreateAnOrderTest < ActionDispatch::IntegrationTest
  test "logged_in user can checkout from cart to create an order" do
    user = create(:user)
    ApplicationController.any_instance.stubs(:current_user).returns(user)
    gif = create(:gif)
    visit gif_path(gif)
    click_on "Add to cart"
    visit "/cart"
    within "table" do
      click_on "Checkout"
    end

    assert_equal "/checkout", current_path
    assert page.has_content?(gif.title)
    assert page.has_content?(gif.description)
    assert page.has_content?("1")

    click_on "Accept Order"
    assert page.has_content?("Order was successfully placed.")
    assert_equal "/orders", current_path

    within "table" do
      assert page.has_content? user.orders.last.id
    end
  end

  test "logged out user prompted to log in before checkout" do
    user = create(:user)
    gif = create(:gif)
    visit gif_path(gif)
    click_on "Add to cart"
    visit "/cart"
    within "table" do
      click_on "Checkout"
    end

    assert_equal "/login", current_path
    assert page.has_content? "Please login or create a new account before checking out."

    fill_in "Username", with: "#{user.username}"
    fill_in "Password", with: "#{user.password}"

    within ".login" do
      click_on "Login"
    end

    assert_equal "/dashboard", current_path
    assert page.has_content?("Logged in as #{user.username}")

    visit "/cart"
    within "table" do
      click_on "Checkout"
    end

    assert page.has_content?(gif.title)
    assert page.has_button? "Accept Order"
  end

  test "user can create multiple orders and view them" do
    user = create(:user)
    gif = create(:gif)
    gif2 = create(:gif)
    ApplicationController.any_instance.stubs(:current_user).returns(user)

    visit gif_path(gif)

    click_button "Add to cart"

    visit "/cart"

    within "table" do
      click_on "Checkout"
    end
    click_on "Accept Order"
      # and they see all of their orders past and present
    assert page.has_content? "Order: #{user.orders.first.id}"
      # then user returns to shop and selects gif
    visit gif_path(gif2)
      # then user views cart
    click_button "Add to cart"
      # and clicks checkout
    visit "/cart"
      # then sees checkout page
    within "table" do
      click_on "Checkout"
    end

    click_on "Accept Order"

    assert page.has_content? "Order: #{user.orders.first.id}"
    assert page.has_content? "Order: #{user.orders.last.id}"
  end
end
