# == Schema Information
#
# Table name: state_efile_submissions
#
#  id                      :bigint           not null, primary key
#  intake_type             :string           not null
#  last_checked_for_ack_at :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  intake_id               :bigint           not null
#  irs_submission_id       :string
#
# Indexes
#
#  index_state_efile_submissions_on_intake  (intake_type,intake_id)
#
require 'rails_helper'

RSpec.describe StateEfileSubmission, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
