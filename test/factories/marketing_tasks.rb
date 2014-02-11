# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :marketing_task do
    name "MyString"
    marketing_project
    brand
    due_on 1.week.from_now
    creative_brief "Something more informational goes here"
  end
end
