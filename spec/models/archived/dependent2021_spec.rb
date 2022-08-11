# == Schema Information
#
# Table name: archived_dependents_2021
#
#  id                                          :bigint           not null, primary key
#  birth_date                                  :date             not null
#  born_in_2020                                :integer          default("unfilled"), not null
#  cant_be_claimed_by_other                    :integer          default("unfilled"), not null
#  claim_anyway                                :integer          default("unfilled"), not null
#  creation_token                              :string
#  disabled                                    :integer          default("unfilled"), not null
#  encrypted_ip_pin                            :string
#  encrypted_ip_pin_iv                         :string
#  encrypted_ssn                               :string
#  encrypted_ssn_iv                            :string
#  filed_joint_return                          :integer          default("unfilled"), not null
#  first_name                                  :string
#  full_time_student                           :integer          default("unfilled"), not null
#  has_ip_pin                                  :integer          default("unfilled"), not null
#  ip_pin                                      :text
#  last_name                                   :string
#  lived_with_more_than_six_months             :integer          default("unfilled"), not null
#  meets_misc_qualifying_relative_requirements :integer          default("unfilled"), not null
#  middle_initial                              :string
#  months_in_home                              :integer
#  no_ssn_atin                                 :integer          default("unfilled"), not null
#  north_american_resident                     :integer          default("unfilled"), not null
#  on_visa                                     :integer          default("unfilled"), not null
#  passed_away_2020                            :integer          default("unfilled"), not null
#  permanent_residence_with_client             :integer          default("unfilled"), not null
#  permanently_totally_disabled                :integer          default("unfilled"), not null
#  placed_for_adoption                         :integer          default("unfilled"), not null
#  provided_over_half_own_support              :integer          default("unfilled"), not null
#  relationship                                :string
#  soft_deleted_at                             :datetime
#  ssn                                         :text
#  suffix                                      :string
#  tin_type                                    :integer
#  was_married                                 :integer          default("unfilled"), not null
#  was_student                                 :integer          default("unfilled"), not null
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  archived_intakes_2021_id                    :bigint           not null
#
# Indexes
#
#  index_archived_dependents_2021_on_archived_intakes_2021_id  (archived_intakes_2021_id)
#  index_archived_dependents_2021_on_creation_token            (creation_token)
#
# Foreign Keys
#
#  fk_rails_...  (archived_intakes_2021_id => archived_intakes_2021.id)
#
require "rails_helper"

describe Archived::Dependent2021 do
  context "encrypted fields" do
    describe "#ip_pin" do
      let(:to_ip_pin) { create :archived_2021_dependent, intake: (create :archived_2021_ctc_intake), ip_pin: "123456" }
      let(:to_attr_encrypted_ip_pin) { create :archived_2021_dependent, intake: (create :archived_2021_ctc_intake), ip_pin: nil, attr_encrypted_ip_pin: "222333"}
      it "is an encrypted field" do
        expect(to_ip_pin.encrypted_attribute?(:ip_pin)).to be_truthy
      end

      it "reads from either the encrypts or attr_encrypted field" do
        expect(to_ip_pin.ip_pin).to eq "123456"
        expect(to_ip_pin.read_attribute(:ip_pin)).to eq "123456"
        expect(to_attr_encrypted_ip_pin.ip_pin).to eq "222333"
        expect(to_attr_encrypted_ip_pin.read_attribute(:ip_pin)).to eq "222333"
      end
    end

    describe "#ssn" do
      let(:to_ssn) { create :archived_2021_dependent, intake: (create :archived_2021_ctc_intake), ssn: "123456789" }
      let(:to_encrypted_ssn) { create :archived_2021_dependent, intake: (create :archived_2021_ctc_intake), ssn: nil, attr_encrypted_ssn: "987654321" }

      it "is an encrypted field" do
        expect(to_ssn.encrypted_attribute?(:ssn)).to be_truthy
      end

      it "reads from either the encrypts or attr_encrypted field" do
        expect(to_ssn.ssn).to eq "123456789"
        expect(to_ssn.read_attribute(:ssn)).to eq "123456789"
        expect(to_encrypted_ssn.ssn).to eq "987654321"
        expect(to_encrypted_ssn.read_attribute(:ssn)).to eq "987654321"
      end
    end
  end
end
