# spec/factories/geo_locations.rb
FactoryBot.define do
  factory :geo_location do
    ip { Faker::Internet.ip_v4_address }
    url { Faker::Internet.url }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    country { Faker::Address.country }
    city { Faker::Address.city }
  end
end
