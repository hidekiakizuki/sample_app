FactoryBot.define do
  factory :article do
    title { Faker::Lorem.question }
    body { Faker::Lorem.paragraph }
  end
end
