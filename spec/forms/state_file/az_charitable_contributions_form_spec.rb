require "rails_helper"

RSpec.describe StateFile::AzCharitableContributionsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }

    context "with no radio selected" do
      let(:invalid_params) do
        {
          charitable_contributions: "unfilled",
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include(:charitable_contributions)
      end
    end

    context "with charitable contributions" do
      let(:params) do
        { charitable_contributions: "yes" }
      end

      it "Requires all contributions to be present" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :charitable_cash_amount
        expect(form.errors).to include :charitable_noncash_amount
      end

      it "Requires all contributions to be numeric" do
        form = described_class.new(intake, params.merge({ charitable_cash_amount: "a10", charitable_noncash_amount: "b20"}))
        expect(form).not_to be_valid
        expect(form.errors).to include :charitable_cash_amount
        expect(form.errors).to include :charitable_noncash_amount
      end

      context "when non cash contributions exceed 500" do
        let(:params) do
          super().merge({
            charitable_cash_amount: 100,
            charitable_noncash_amount: 600,
          })
        end

        it "returns false" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include(:charitable_noncash_amount)
        end
      end
    end
  end



  describe "#save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        charitable_contributions: "yes",
        charitable_cash_amount: 100,
        charitable_noncash_amount: 100,
      }
    end

    it "saves the charitable contributions amount to the intake" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.charitable_cash_amount).to eq 100
      expect(intake.reload.charitable_noncash_amount).to eq 100
    end
  end

  describe "no charitable contributions to save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        charitable_contributions: "no",
        charitable_cash_amount: "",
        charitable_noncash_amount: "",
      }
    end

    it "proceeds with nil for cash and non-cash contributions" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.charitable_cash_amount).to be_nil
      expect(intake.reload.charitable_noncash_amount).to be_nil
    end
  end

  describe "going back and saying no to charitable contributions" do
    let(:intake) { create :state_file_az_intake, charitable_cash_amount: 100, charitable_noncash_amount: 100}
    let(:valid_params) do
      {
        charitable_contributions: "no",
        charitable_cash_amount: 100,
        charitable_noncash_amount: 100,
      }
    end

    it "proceeds with nil amounts for cash and noncash contributions" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.charitable_cash_amount).to be_nil
      expect(intake.reload.charitable_noncash_amount).to be_nil
    end
  end
end



