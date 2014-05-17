# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    name "role1"
    description "role1"
  end

  factory :role2, class: Role do
    name "role2"
    description "role2"
  end
end
