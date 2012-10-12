require "minitest_helper"

describe "BuyItNow Integration Test" do

  before do
    DatabaseCleaner.start
    @website = FactoryGirl.create(:website_with_products)
    host! @website.url
    Capybara.default_host = "http://#{@website.url}" 
    Capybara.app_host = "http://#{@website.url}" 
    @product = @website.products.first
    @online_retailer = FactoryGirl.create(:online_retailer)
    @retailer_link = FactoryGirl.create(:online_retailer_link, online_retailer: @online_retailer, product: @product, brand: @website.brand)
  end
  
  describe "product page" do

  	it "should have buy it now links" do
  		visit product_url(@product, locale: I18n.default_locale, host: @website.url)
  		must_have_xpath("//div[@id='dealers']")
  	end

    it "should have RETAILER google tracker" do
      visit product_url(@product, locale: I18n.default_locale, host: @website.url)
      # Best I match is the beginning of the tracker onclick code. The entire code is:
      # tracker = "_gaq.push(['_trackEvent', 'BuyItNow-Dealer', '#{@online_retailer.name}', '#{@product.name}'])"
      page.must_have_xpath("//a[@href='#{@retailer_link.url}'][starts-with(@onclick, '_gaq.push')]")
    end

    describe "preferred retailer" do
    	it "should appear first" do
    		preferred_retailer = FactoryGirl.create(:online_retailer, preferred: 1)
    		preferred_link = FactoryGirl.create(:online_retailer_link, online_retailer: preferred_retailer, product: @product, brand: @website.brand)
    		visit product_url(@product, locale: I18n.default_locale, host: @website.url)
    		must_have_xpath("//div[@id='dealers']/div[@id='online_retailers']/div[@class='retailer_logo preferred']/a[@href='#{preferred_link.url}']")
    	end
    end

    describe "URL param rbin=true" do
    	before do
    		visit product_url(@product, locale: I18n.default_locale, host: @website.url, rbin: true)
    	end

    	it "should select a random retailer to link directly" do
    		must_have_xpath("//div[@id='product_buy_now_box']")
    		must_have_link "Online Dealers (US)"
    	end

    	it "should not link to any other retailers" do 
    		wont_have_xpath("//div[@id='dealers']")
    	end
    end

    describe "URL param bin=dealer-id" do
    	before do
    		visit product_url(@product, locale: I18n.default_locale, host: @website.url, bin: @online_retailer.to_param)
    	end

    	it "should link directly to the retailer" do
    		must_have_xpath("//div[@id='product_buy_now_box']")
    		must_have_link "Online Dealers (US)", href: @retailer_link.url
    	end

    	it "should not link to any other retailers" do 
    		wont_have_xpath("//div[@id='dealers']")
    	end
    end

  end

  describe "product buyitnow page" do 
  	before do
  		@preferred_retailer = FactoryGirl.create(:online_retailer, preferred: 1)
    	@preferred_link = FactoryGirl.create(:online_retailer_link, online_retailer: @preferred_retailer, product: @product, brand: @website.brand)
    	visit buy_it_now_product_url(@product, locale: I18n.default_locale, host: @website.url)
    end

    it "should have buy it now links with RETAILER google tracker" do
      page.must_have_xpath("//a[@href='#{@retailer_link.url}'][starts-with(@onclick, '_gaq.push')]")
    end

	it "preferred should appear first" do
		preferred_retailer = FactoryGirl.create(:online_retailer, preferred: 1)
		preferred_link = FactoryGirl.create(:online_retailer_link, online_retailer: preferred_retailer, product: @product, brand: @website.brand)
		visit product_url(@product, locale: I18n.default_locale, host: @website.url)
		must_have_xpath("//div[@id='dealers']/div[@id='online_retailers']/div[@class='retailer_logo preferred']/a[@href='#{preferred_link.url}']")
	end

  end
  
end