FactoryBot.define do
  factory :vita_provider do
    sequence(:irs_id) { |n| "1234#{n}" }
  end

  trait :with_coordinates do
    transient do
      lat_lon { [37.840284, -122.274668] }
    end

    before(:create) do |provider, evaluator|
      provider.set_coordinates(lat: evaluator.lat_lon[0], lon: evaluator.lat_lon[1])
    end
  end
end
