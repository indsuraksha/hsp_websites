# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :system_option_value do
    system_option_id 1
    name "MyString"
    position 1
    description "MyText"
    default false
    price 1
  end
end