require "minitest_helper"

describe "Lexicon Integration Test" do

  before do
    DatabaseCleaner.start
    @brand = FactoryGirl.create(:lexicon_brand)
    @website = FactoryGirl.create(:website_with_products, folder: "lexicon", brand: @brand)
    host! @website.url
    Capybara.default_host = "http://#{@website.url}" 
    Capybara.app_host = "http://#{@website.url}" 
  end
  
  describe "homepage" do

    before do
      visit root_url(host: @website.url)
    end

    # Would be nice to test for using the layout by filename, but I can't figure out
    # how to do that. So, check for unique attributes of that file...
    it "should use lexicon layout" do
      within(:xpath, "//div[@id='supernav']") do
        page.must_have_content "Browse Products"
      end
    end

    it "should call Artists Professionals" do
      page.must_have_link "professionals", href: artists_path(locale: I18n.default_locale)
    end
    
  end

  # Since Lexicon has different product family views
  describe "product family page" do
    before do
      @product_family = @website.product_families.first
      @multiple_parent = FactoryGirl.create(:product_family, brand: @website.brand)
      2.times { FactoryGirl.create(:product_family_with_products, brand: @website.brand, parent_id: @multiple_parent.id)}
      @single_parent = FactoryGirl.create(:product_family, brand: @website.brand)
      FactoryGirl.create(:product_family_with_products, brand: @website.brand, parent_id: @single_parent.id, products_count: 1)
      FactoryGirl.create(:product_family, brand: @website.brand, parent_id: @single_parent.id)
      visit products_url(locale: I18n.default_locale, host: @website.url)
    end

    it "should link to each parent family" do
      page.must_have_link @product_family.name, href: product_family_path(@product_family, locale: I18n.default_locale)
      page.must_have_link @multiple_parent.name, href: product_family_path(@multiple_parent, locale: I18n.default_locale)
      page.must_have_link @single_parent.name, href: product_family_path(@single_parent, locale: I18n.default_locale)
    end

  end

  describe "product pages" do
    before do
      @product = @website.products.first
      @product.features_tab_name = "Culture"
      @product.features = "This is content for the features"
      @product.demo_link = 'http://demo.lvh.me/download/the/demo/form'
      @product.save
      FactoryGirl.create(:setting, brand: @brand, name: "description_tab_name", string_value: "Overview")
      visit product_url(@product, locale: I18n.default_locale, host: @website.url)
    end

    it "should call features tab Culture sometimes" do
      page.must_have_link "Culture"
    end 

    it "should have a tab named Overview" do
      page.must_have_link "Overview"
    end

    it "should have a demo download link" do
      page.must_have_xpath("//a[@href='#{@product.demo_link}']")
    end
  end
  
end