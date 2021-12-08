# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  allows_greeters            :boolean
#  archived                   :boolean          default(FALSE)
#  capacity_limit             :integer
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
#  processes_ctc              :boolean          default(FALSE)
#  timezone                   :string           default("America/New_York")
#  type                       :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  coalition_id               :bigint
#  parent_organization_id     :bigint
#
# Indexes
#
#  index_vita_partners_on_coalition_id               (coalition_id)
#  index_vita_partners_on_parent_name_and_coalition  (parent_organization_id,name,coalition_id) UNIQUE
#  index_vita_partners_on_parent_organization_id     (parent_organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (coalition_id => coalitions.id)
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
