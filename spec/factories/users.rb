FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_entries do
      transient do
        entries_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:entry, evaluator.entries_count, user: user)
      end
    end
  end
end
