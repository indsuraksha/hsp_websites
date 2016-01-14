require "rails_helper"

RSpec.describe "artists/sessions/new.html.erb", as: :view do

  before do
    @brand = FactoryGirl.create(:digitech_brand)
    @website = FactoryGirl.create(:website, folder: "digitech", brand: @brand)
    @affiliate_tier = FactoryGirl.create(:affiliate_tier)
    @top_tier = FactoryGirl.create(:top_tier)

    allow(view).to receive(:website).and_return(@website)
    allow(view).to receive(:resource).and_return(Artist.new)
    allow(view).to receive(:resource_name).and_return(:artist)
    allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:artist])

    render
  end

  it "should not have a signup form" do
    expect(rendered).not_to have_link "Sign up to be a #{@brand.name} Artist"
  end
end
