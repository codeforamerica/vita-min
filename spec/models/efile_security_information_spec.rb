# == Schema Information
#
# Table name: efile_security_informations
#
#  id                  :bigint           not null, primary key
#  browser_language    :string
#  client_system_time  :string
#  ip_address          :inet
#  platform            :string
#  recaptcha_score     :decimal(, )
#  timezone            :string
#  timezone_offset     :string
#  user_agent          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_id           :bigint
#  device_id           :string
#  efile_submission_id :bigint
#
# Indexes
#
#  index_client_efile_security_informations_efile_submissions_id  (efile_submission_id)
#  index_efile_security_informations_on_client_id                 (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (efile_submission_id => efile_submissions.id)
#
require "rails_helper"

describe EfileSecurityInformation do
end
