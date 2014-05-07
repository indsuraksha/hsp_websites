# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :audio_demo do
    name "MyString"
    description "MyText"
    wet_demo { File.new(Rails.root.join('test', 'fixtures', 'test.mp3')) }
    dry_demo { File.new(Rails.root.join('test', 'fixtures', 'test.mp3')) }
    # duration_in_seconds 1
    brand
  end
end
