# == Schema Information
#
# Table name: state_file_id1099_r_followups
#
#  id                     :bigint           not null, primary key
#  eligible_income_source :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
require 'rails_helper'

RSpec.describe StateFileId1099RFollowup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
