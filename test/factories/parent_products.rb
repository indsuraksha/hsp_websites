# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :parent_product do
    association :parent_product, factory: :product
    product
    position 1
  end
end
