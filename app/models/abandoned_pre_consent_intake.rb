# == Schema Information
#
# Table name: abandoned_pre_consent_intakes
#
#  id         :bigint           not null, primary key
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
class AbandonedPreConsentIntake < ApplicationRecord
end
