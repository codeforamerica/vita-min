# == Schema Information
#
# Table name: verification_attempts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
# Indexes
#
#  index_verification_attempts_on_client_id  (client_id)
#
require 'rails_helper'

RSpec.describe VerificationAttempt, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
