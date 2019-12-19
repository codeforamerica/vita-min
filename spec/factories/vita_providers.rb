# == Schema Information
#
# Table name: vita_providers
#
#  id               :bigint           not null, primary key
#  appointment_info :string
#  coordinates      :geography({:srid point, 4326
#  dates            :string
#  details          :string
#  hours            :string
#  languages        :string
#  name             :string
#  irs_id           :string           not null
#
# Indexes
#
#  index_vita_providers_on_irs_id  (irs_id) UNIQUE
#

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
