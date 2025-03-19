require 'rails_helper'

RSpec.describe StateFile::IdRetirementAndPensionIncomeForm, type: :model do
  describe "validations" do
    it { should validate_presence_of :income_source }

    context "must answer follow-up question" do
      let(:follow_up) { create(:state_file_id1099_r_followup) }

      context "they provided the required follow-up information" do
        it "is valid" do
          civil_service_valid_params = {
            income_source: "civil_service_employee",
            civil_service_account_number: "zero_to_four",
            police_retirement_fund: "no",
            police_persi: "no",
            police_none_apply: false,
            firefighter_frf: "no",
            firefighter_persi: "no",
            firefighter_none_apply: false,
          }
          expect(described_class.new(follow_up, civil_service_valid_params).valid?).to eq true

          police_valid_params = {
            income_source: "police_officer",
            civil_service_account_number: nil,
            police_retirement_fund: "yes",
            police_persi: "no",
            police_none_apply: false,
            firefighter_frf: "no",
            firefighter_persi: "no",
            firefighter_none_apply: false,
          }
          expect(described_class.new(follow_up, police_valid_params).valid?).to eq true

          firefighter_valid_params = {
            income_source: "firefighter",
            civil_service_account_number: nil,
            police_retirement_fund: "no",
            police_persi: "no",
            police_none_apply: false,
            firefighter_frf: "no",
            firefighter_persi: "yes",
            firefighter_none_apply: false,
          }
          expect(described_class.new(follow_up, firefighter_valid_params).valid?).to eq true
        end
      end

      context "income source is civil_service_employee" do
        let(:params) do
          {
            income_source: "civil_service_employee",
            civil_service_account_number: defined?(civil_service_account_number) ? civil_service_account_number : nil,
            police_retirement_fund: "no",
            police_persi: "no",
            police_none_apply: "no",
            firefighter_frf: "no",
            firefighter_persi: "no",
            firefighter_none_apply: "no",
          }
        end

        context "they did not provide account number" do
          let(:civil_service_account_number) { nil }

          it "is invalid" do
            form = described_class.new(follow_up, params)
            expect(form.valid?).to eq false
          end
        end

        context "they provided account number" do
          let(:civil_service_account_number) { "zero_to_four" }

          it "is valid" do
            form = described_class.new(follow_up, params)
            expect(form.valid?).to eq true
          end
        end
      end

      context "income source is police officer" do
        let(:params) do
          {
            income_source: "police_officer",
            civil_service_account_number: nil,
            police_retirement_fund: "no",
            police_persi: "no",
            police_none_apply: defined?(police_none_apply) ? police_none_apply : "no",
            firefighter_frf: "no",
            firefighter_persi: "no",
            firefighter_none_apply: "no",
          }
        end

        context "they did not check any options" do
          it "is invalid" do
            form = described_class.new(follow_up, params)
            expect(form.valid?).to eq false
          end
        end

        context "they checked none apply" do
          let(:police_none_apply) { "yes" }

          it "is valid" do
            form = described_class.new(follow_up, params)
            expect(form.valid?).to eq true
          end
        end
      end

      context "income source is firefighter" do
        let(:params) do
          {
            income_source: "firefighter",
            civil_service_account_number: nil,
            police_retirement_fund: "no",
            police_persi: "no",
            police_none_apply: defined?(police_none_apply) ? police_none_apply : "no",
            firefighter_frf: "no",
            firefighter_persi: "no",
            firefighter_none_apply: defined?(firefighter_none_apply) ? firefighter_none_apply : "no",
          }
        end

        context "they did not check any options" do
          it "is invalid" do
            form = described_class.new(follow_up, params)
            expect(form.valid?).to eq false
          end
        end

        context "they checked none apply" do
          let(:firefighter_none_apply) { "yes" }

          it "is valid" do
            form = described_class.new(follow_up, params)
            expect(form.valid?).to eq true
          end
        end
      end
    end
  end

  describe "#save" do
    it "saves the params" do
      follow_up = create(:state_file_id1099_r_followup)

      params = {
        income_source: "civil_service_employee",
        civil_service_account_number: "zero_to_four",
        police_retirement_fund: nil,
        police_persi: nil,
        police_none_apply: nil,
        firefighter_frf: nil,
        firefighter_persi: nil,
        firefighter_none_apply: nil,
      }

      form = described_class.new(follow_up, params)
      form.save

      expect(follow_up.income_source).to eq "civil_service_employee"
      expect(follow_up.civil_service_account_number).to eq "zero_to_four"
      expect(follow_up.police_retirement_fund).to eq "no"
      expect(follow_up.police_persi).to eq "no"
      expect(follow_up.firefighter_frf).to eq "no"
      expect(follow_up.firefighter_persi).to eq "no"
    end
    
    context "if user is in the flow of the old question prompt" do
      it "saves the old param" do
        follow_up = create(:state_file_id1099_r_followup)

        params = {
          eligible_income_source: "yes"
        }

        form = described_class.new(follow_up, params)
        form.save

        expect(follow_up.eligible_income_source).to eq "yes"
        expect(follow_up.income_source).to eq "unfilled"
        expect(follow_up.civil_service_account_number).to eq "unfilled"
        expect(follow_up.police_retirement_fund).to eq "no"
        expect(follow_up.police_persi).to eq "no"
        expect(follow_up.firefighter_frf).to eq "no"
        expect(follow_up.firefighter_persi).to eq "no"
      end
      
    end
  end
end
