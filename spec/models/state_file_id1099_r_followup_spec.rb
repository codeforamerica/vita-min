# == Schema Information
#
# Table name: state_file_id1099_r_followups
#
#  id                           :bigint           not null, primary key
#  civil_service_account_number :integer          default("unfilled"), not null
#  eligible_income_source       :integer          default("unfilled"), not null
#  firefighter_frf              :integer          default("unfilled"), not null
#  firefighter_persi            :integer          default("unfilled"), not null
#  income_source                :integer          default("unfilled"), not null
#  police_persi                 :integer          default("unfilled"), not null
#  police_retirement_fund       :integer          default("unfilled"), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
require 'rails_helper'

RSpec.describe StateFileId1099RFollowup, type: :model do
  describe '#qualifying_retirement_income?' do
    context 'when eligible income source is present and yes' do
      let(:followup) { build(:state_file_id1099_r_followup, eligible_income_source: "yes") }

      it 'returns true for' do
        expect(followup.qualifying_retirement_income?).to be true
      end
    end
    context 'when income source is civil service employee' do
      let(:followup) { build(:state_file_id1099_r_followup, income_source: "civil_service_employee") }

      it 'returns true for zero_to_four account number' do
        followup.civil_service_account_number = "zero_to_four"
        expect(followup.qualifying_retirement_income?).to be true
      end

      it 'returns false for seven_or_nine account number' do
        followup.civil_service_account_number = "seven_or_nine"
        expect(followup.qualifying_retirement_income?).to be false
      end
      it 'returns false for eight account number' do
        followup.civil_service_account_number = "eight"
        expect(followup.qualifying_retirement_income?).to be false
      end
    end

    context 'when income source is police officer' do
      let(:followup) { build(:state_file_id1099_r_followup, income_source: "police_officer") }

      context 'when police retirement fund is yes' do
        it 'returns false' do
          followup.police_retirement_fund = "yes"
          followup.police_persi = "no"
          expect(followup.qualifying_retirement_income?).to be false
        end
      end

      context 'when police persi is yes' do
        it 'returns false' do
          followup.police_retirement_fund = "no"
          followup.police_persi = "yes"
          expect(followup.qualifying_retirement_income?).to be false
        end
      end

      context 'when both police retirement fund and persi are no' do
        it 'returns false' do
          followup.police_retirement_fund = "no"
          followup.police_persi = "no"
          expect(followup.qualifying_retirement_income?).to be false
        end
      end

      context 'when both police retirement fund and persi are yes' do
        it 'returns true' do
          followup.police_retirement_fund = "yes"
          followup.police_persi = "yes"
          expect(followup.qualifying_retirement_income?).to be true
        end
      end
    end

    context 'when income source is firefighter' do
      let(:followup) { build(:state_file_id1099_r_followup, income_source: "firefighter") }

      context 'when firefighter frf is yes' do
        it 'returns false' do
          followup.firefighter_frf = "yes"
          followup.firefighter_persi = "no"
          expect(followup.qualifying_retirement_income?).to be false
        end
      end

      context 'when firefighter persi is yes' do
        it 'returns false' do
          followup.firefighter_frf = "no"
          followup.firefighter_persi = "yes"
          expect(followup.qualifying_retirement_income?).to be false
        end
      end

      context 'when both firefighter frf and persi are no' do
        it 'returns false' do
          followup.firefighter_frf = "no"
          followup.firefighter_persi = "no"
          expect(followup.qualifying_retirement_income?).to be false
        end
      end

      context 'when both firefighter frf and persi are yes' do
        it 'returns true' do
          followup.firefighter_frf = "yes"
          followup.firefighter_persi = "yes"
          expect(followup.qualifying_retirement_income?).to be true
        end
      end
    end

    context 'when income source is military' do
      it 'returns true' do
        followup = build(:state_file_id1099_r_followup, income_source: "military")
        expect(followup.qualifying_retirement_income?).to be true
      end
    end

    context 'when income source is none' do
      it 'returns false' do
        followup = build(:state_file_id1099_r_followup, income_source: "none")
        expect(followup.qualifying_retirement_income?).to be false
      end
    end

    context 'when income source is unfilled' do
      it 'returns false' do
        followup = build(:state_file_id1099_r_followup, income_source: :unfilled)
        expect(followup.qualifying_retirement_income?).to be false
      end
    end
  end
end
