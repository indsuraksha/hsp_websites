require "rails_helper"

feature "Digitech brand layout" do

  before :each do
    @brand = FactoryGirl.create(:digitech_brand)
    @website = FactoryGirl.create(:website_with_products, folder: "digitech", brand: @brand)
    Capybara.default_host = "http://#{@website.url}"
    Capybara.app_host = "http://#{@website.url}"
  end

  scenario "correct layout is used" do
    visit root_path

    expect(page).to have_xpath("//body[@data-brand='#{@brand.name}']")
    expect(page).to have_xpath("//div[@id='big_bottom_box_container']")
  end

end
