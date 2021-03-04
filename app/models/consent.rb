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
class Consent < ApplicationRecord
  belongs_to :client
end
