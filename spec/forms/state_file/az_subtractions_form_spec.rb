require "rails_helper"

RSpec.describe StateFile::AzSubtractionsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }

    context "with empty checkboxes for both tribal and armed forces" do
      let(:params) do
        {
          tribal_member: "no",
          tribal_wages_amount: nil,
          armed_forces_member: "no",
          armed_forces_wages_amount: nil
        }
      end

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "with all checkboxes selected" do
      let(:params) do
        {
          tribal_member: "yes",
          armed_forces_member: "yes",
        }
      end

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :tribal_wages_amount
        expect(form.errors).to include :armed_forces_wages_amount
      end

      it "non numeric values are invalid" do
        form = described_class.new(intake, params.merge(tribal_wages_amount: "a10", armed_forces_wages_amount: "b10"))
        expect(form).not_to be_valid
        expect(form.errors).to include :tribal_wages_amount
        expect(form.errors).to include :armed_forces_wages_amount
      end
    end

    context "with checkboxes selected and non numeric wages" do
      let(:params) do
        {
          tribal_member: "yes",
          tribal_wages_amount: nil,
          armed_forces_member: "yes",
          armed_forces_wages_amount: nil
        }
      end

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :tribal_wages_amount
        expect(form.errors).to include :armed_forces_wages_amount
      end
    end

    context "with just tribal member and wages" do
      let(:params) do
        {
          tribal_member: "yes",
          tribal_wages_amount: 10,
          armed_forces_member: "no",
          armed_forces_wages_amount: nil
        }
      end

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "with just armed forces member and wages" do
      let(:params) do
        {
          tribal_member: "no",
          tribal_wages_amount: nil,
          armed_forces_member: "yes",
          armed_forces_wages_amount: 10
        }
      end

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    let(:intake) { create :state_file_az_intake }
    let(:params) do
      {
        tribal_member: "yes",
        tribal_wages_amount: 10,
        armed_forces_member: "yes",
        armed_forces_wages_amount: 20
      }
    end

    it "saves the membership and wages to the database" do
      form = described_class.new(intake, params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.tribal_member_yes?).to be true
      expect(intake.reload.tribal_wages_amount).to eq 10
      expect(intake.reload.armed_forces_member_yes?).to be true
      expect(intake.reload.armed_forces_wages_amount).to eq 20
    end
  end

  describe "no membership to be saved" do
    let(:intake) { create :state_file_az_intake }
    let(:params) do
      {
        tribal_member: "no",
        tribal_wages_amount: nil,
        armed_forces_member: "no",
        armed_forces_wages_amount: nil
      }
    end

    it "proceeds with nil wages and sets memberships to no" do
      form = described_class.new(intake, params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.tribal_member_no?).to be true
      expect(intake.reload.tribal_wages_amount).to be_nil
      expect(intake.reload.armed_forces_member_no?).to be true
      expect(intake.reload.armed_forces_wages_amount).to be_nil
    end
  end

  describe "going back and removing memberships" do
    let(:intake) { create :state_file_az_intake, tribal_member: "yes", tribal_wages_amount: 10, armed_forces_member: "yes", armed_forces_wages_amount: 20 }
    let(:valid_params) do
      {
        tribal_member: "no",
        tribal_wages_amount: 10,
        armed_forces_member: "no",
        armed_forces_wages_amount: 20
      }
    end

    it "proceeds with nil wages and sets memberships to no" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.tribal_member_no?).to be true
      expect(intake.reload.tribal_wages_amount).to be_nil
      expect(intake.reload.armed_forces_member_no?).to be true
      expect(intake.reload.armed_forces_wages_amount).to be_nil
    end
  end
end