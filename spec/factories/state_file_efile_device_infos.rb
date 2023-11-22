# == Schema Information
#
# Table name: state_file_efile_device_infos
#
#  id          :bigint           not null, primary key
#  event_type  :string
#  intake_type :string           not null
#  ip_address  :inet
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  device_id   :string
#  intake_id   :bigint           not null
#
# Indexes
#
#  index_state_file_efile_device_infos_on_intake  (intake_type,intake_id)
#
FactoryBot.define do
  factory :state_file_efile_device_info do
    trait :filled do
      device_id { "7BA1E530D6503F380F1496A47BEB6F33E40403D1" }
      ip_address { IPAddr.new("1.1.1.1") }
    end

    trait :initial_creation do
      event_type { "initial_creation" }
    end

    trait :submission do
      event_type { "submission" }
    end
  end
end
