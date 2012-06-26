FactoryGirl.define do
   
  factory :brand do
    sequence(:name) {|n| "HSP Brand #{n}"}
    has_effects false
    has_reviews true
    has_faqs true
    has_tone_library false
    has_artists true
    has_clinics false
    has_software true
    has_registered_downloads false
    has_online_retailers true
    has_distributors true
    has_dealers true
    has_service_centers false
    has_market_segments false
    has_parts_form false
    has_rma_form false
    has_training false
    show_pricing false
    has_suggested_products false
    has_blogs false
    has_audio_demos false
    default_locale "en-US"
    dealers_from_brand_id nil
    distributors_from_brand_id nil
    service_centers_from_brand_id nil
    # rso_enabled false
    # logo_file_name "logo.png"
    # logo_content_type "application/png"
    # logo_updated_at 2.days.ago
    # logo_file_size 10000
    # news_feed_url nil
    # after(:create) do |brand|
    #   FactoryGirl.create(:setting, brand: brand, brand_id: brand.id, name: "support_email", string_value: "adam.anderson@harman.com")
    #   FactoryGirl.create(:setting, brand: brand, brand_id: brand.id, name: "default_meta_tag_description", string_value: "HSP brand website")
    #   FactoryGirl.create(:setting, brand: brand, brand_id: brand.id, name: "default_meta_tag_keywords", string_value: "HSP brand website")
    # end
    factory :lexicon_brand do
      name "Lexicon"
      has_registered_downloads true
      show_pricing true
      has_suggested_products true
      has_audio_demos true
    end
    factory :digitech_brand do
      name "DigiTech"
      has_effects true
      has_tone_library true
      has_clinics true
      has_service_centers true
      has_audio_demos true
    end
    factory :hardwire_brand do
      name "HardWire"
      has_service_centers true
      dealers_from_brand_id 1
      distributors_from_brand_id 1
      service_centers_from_brand_id 1
  	end
    factory :vocalist_brand do
      name "Vocalist"
      has_service_centers true
      dealers_from_brand_id 1
      distributors_from_brand_id 1
      service_centers_from_brand_id 1
    end
    factory :jbl_commercial_brand do
      name "JBL Commercial"
    end
    factory :idx_brand do
      name "IDX"
    end
    factory :dbx_brand do
      name "dbx"
    end
    factory :bss_brand do
      name "BSS"
    end
  end

end