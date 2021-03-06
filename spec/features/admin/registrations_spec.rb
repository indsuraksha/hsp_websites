require "rails_helper"

feature "Admin Registrations" do

  before :all do
    @website = FactoryGirl.create(:website_with_products)
    @brand = @website.brand
    @user = FactoryGirl.create(:user, customer_service: true, password: "password", confirmed_at: 1.minute.ago)
    @reg = FactoryGirl.create(:warranty_registration, brand: @brand, product: @website.products.first)
  end

  before :each do
    admin_login_with(@user.email, "password", @website)
    click_on "Product Registrations"
  end

  # after :each do
  #   DatabaseCleaner.clean
  # end

  it "should search by name" do
    fill_in "q_first_name_cont", with: @reg.first_name
    fill_in "q_last_name_cont", with: ''
    fill_in "q_email_cont", with: ''
    click_on "Search"

    expect(page).to have_link "#{@reg.first_name} #{@reg.last_name}"
  end

  # it "should search by email" do
  #   fill_in "q_email_cont", with: @reg.email
  #   click_on "Search"
  #   page.must_have_content @reg.email
  # end

  # it "should have an export button" do
  #   page.must_have_link "Excel"
  # end

end
