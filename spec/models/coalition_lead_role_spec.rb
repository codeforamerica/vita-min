# == Schema Information
#
# Table name: coalition_lead_roles
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  coalition_id :bigint           not null
#
# Indexes
#
#  index_coalition_lead_roles_on_coalition_id  (coalition_id)
#
# Foreign Keys
#
#  fk_rails_...  (coalition_id => coalitions.id)
#
require 'rails_helper'

RSpec.describe CoalitionLeadRole, type: :model do
  describe "required fields" do
    context "with a coalition" do
      it "is valid" do
        coalition = create(:coalition)
        expect(described_class.new(coalition: coalition)).to be_valid
      end
    end

    context "without a coalition" do
      it "is not valid" do
        expect(described_class.new).not_to be_valid
      end
    end
  end
end
