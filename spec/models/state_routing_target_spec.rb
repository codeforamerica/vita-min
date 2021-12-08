# == Schema Information
#
# Table name: state_routing_targets
#
#  id                 :bigint           not null, primary key
#  state_abbreviation :string           not null
#  target_type        :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  target_id          :bigint           not null
#
# Indexes
#
#  index_state_routing_targets_on_target  (target_type,target_id)
#
require "rails_helper"

describe StateRoutingTarget do
  describe "validations" do
    let(:state_abbreviation) { "CA" }
    let(:target) { build(:organization) }
    let(:params) {
      {
        state_abbreviation: state_abbreviation,
        target: target,
      }
    }
    let(:subject) { described_class.new(params) }

    it "can be valid" do
      expect(subject).to be_valid
    end

    context "with an invalid state" do
      let(:state_abbreviation) { "InvalidStateAbbreviation" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:state_abbreviation)
      end
    end
  end
end
