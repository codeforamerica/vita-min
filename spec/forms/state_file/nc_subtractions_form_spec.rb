require "rails_helper"

RSpec.describe StateFile::NcSubtractionsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_nc_intake }
    let(:form) { described_class.new(intake, params) }
    before do
      intake.direct_file_data.fed_agi = 1060
      allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_18).and_return 30
      intake.direct_file_data.fed_taxable_ssb = 30
    end

    context "with no radio selected" do
      let(:invalid_params) do
        {
          tribal_member: "unfilled",
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include(:tribal_member)
      end
    end

    context "no members of a federally recognized Indian tribe" do
      let(:params) do
        {
          tribal_member: "no",
          tribal_wages_amount: nil,
        }
      end

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "when primary or spouse was a member of a federally recognized Indian tribe" do
      let(:params) do
        {
          tribal_member: "yes",
        }
      end

      it "is not valid when tribal wages are not entered" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :tribal_wages_amount
      end

      it "non numeric values are invalid" do
        form = described_class.new(intake, params.merge(tribal_wages_amount: "a10"))
        expect(form).not_to be_valid
        expect(form.errors).to include :tribal_wages_amount
      end

      it "tribal wages that exceeds the federal wage total are invalid" do
        form = described_class.new(intake, params.merge(tribal_wages_amount: "1004"))
        expect(form).not_to be_valid
        expect(form.errors).to include :tribal_wages_amount
      end
    end

    context "with valid fields" do
      let(:params) do
        {
          tribal_member: "yes",
          tribal_wages_amount: 10,
        }
      end

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    let(:intake) { create :state_file_nc_intake }
    let(:params) do
      {
        tribal_member: "yes",
        tribal_wages_amount: 100,
      }
    end

    it "saves the membership and wages to the database" do
      form = described_class.new(intake, params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.tribal_member_yes?).to be true
      expect(intake.reload.tribal_wages_amount).to eq 100
    end
  end

  describe "no membership to be saved" do
    let(:intake) { create :state_file_nc_intake }
    let(:params) do
      {
        tribal_member: "no",
        tribal_wages_amount: nil,
      }
    end

    it "proceeds with nil wages and sets memberships to no" do
      form = described_class.new(intake, params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.tribal_member_no?).to be true
      expect(intake.reload.tribal_wages_amount).to be_nil
    end
  end

  describe "going back and removing memberships" do
    let(:intake) { create :state_file_nc_intake, tribal_member: "yes", tribal_wages_amount: 100 }
    let(:valid_params) do
      {
        tribal_member: "no",
        tribal_wages_amount: 100,
      }
    end

    it "proceeds with nil prior last names" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.tribal_member_no?).to be true
      expect(intake.reload.tribal_wages_amount).to be_nil
    end
  end
end