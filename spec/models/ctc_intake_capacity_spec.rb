# == Schema Information
#
# Table name: ctc_intake_capacities
#
#  id         :bigint           not null, primary key
#  capacity   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ctc_intake_capacities_on_created_at  (created_at)
#  index_ctc_intake_capacities_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe CtcIntakeCapacity, type: :model do
  describe "validations" do
    it "requires user and capacity" do
      record = CtcIntakeCapacity.new
      expect(record).not_to be_valid
      expect(record.errors.attribute_names).to match_array([:user, :capacity])
      expect(CtcIntakeCapacity.new(capacity: 0, user: build(:admin_user))).to be_valid
    end
  end
end
