FactoryBot.define do
  factory :entry do
    name { Faker::App.name }
    username { Faker::Internet.username }
    password { Faker::Internet.password(min_length: 10, max_length: 20) }
    url { Faker::Internet.url }
    user

    trait :invalid do
      name { nil }
    end

    trait :invalid_url do
      url { "not-a-valid-url.com" }
    end
  end
end
