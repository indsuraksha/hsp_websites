require "rails_helper"

RSpec.describe MarketSegment, :type => :model do

  before do
    @market = FactoryGirl.build(:market_segment)
    @product = FactoryGirl.create(:product, brand: @market.brand)
    @product_family = FactoryGirl.create(:product_family, brand: @market.brand)
    @product_family.products << @product
    @market.product_families << @product_family
  end

  subject { @market }
  it { should respond_to(:brand) }
  it { should respond_to(:product_families) }
  it { should respond_to(:banner_image) }

  describe "related news" do

    it "collects current news" do
      news = FactoryGirl.create(:news, brand: @market.brand)
      news.products << @product

      expect(@market.related_news).to include(news)
    end

    it "excludes future news" do
      news = FactoryGirl.create(:news, brand: @market.brand, post_on: 2.weeks.from_now)
      news.products << @product

      expect(@market.related_news).not_to include(news)
    end
  end

end

