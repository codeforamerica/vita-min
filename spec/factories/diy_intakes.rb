# == Schema Information
#
# Table name: diy_intakes
#
#  id                 :bigint           not null, primary key
#  email_address      :string
#  preferred_name     :string
#  state_of_residence :string
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  requester_id       :bigint
#  ticket_id          :bigint
#
# Indexes
#
#  index_diy_intakes_on_token  (token) UNIQUE
#
FactoryBot.define do
  factory :diy_intake do
    preferred_name { "Gary Gnome" }
    state_of_residence { "CA" }
  end
end
