# == Schema Information
#
# Table name: consents
#
#  id                               :bigint           not null, primary key
#  disclose_consented_at            :datetime
#  global_carryforward_consented_at :datetime
#  ip                               :inet
#  relational_efin_consented_at     :datetime
#  use_consented_at                 :datetime
#  user_agent                       :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  client_id                        :bigint           not null
#
# Indexes
#
#  index_consents_on_client_id  (client_id)
#
FactoryBot.define do
  factory :consent do
    disclose_consented_at { DateTime.current }
    use_consented_at {  DateTime.current }
    global_carryforward_consented_at { DateTime.current }
    relational_efin_consented_at { DateTime.current }
    ip { IPAddr.new }
    user_agent { "CERN-NextStep-WorldWideWeb.app/1.1 libwww/2.07" }
  end
end
