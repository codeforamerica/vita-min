require "rails_helper"

describe Ctc::MailingAddressForm do
  let(:intake) { create :ctc_intake }

  let(:params) do
    {
      street_address: "123 Main St",
      street_address2: "STE 5",
      state: "TX",
      city: "Newton",
      zip_code: "77494"
    }
  end
  context "validations" do
    context "with all params" do
      it "is valid" do
        expect(
            described_class.new(intake, params)
        ).to be_valid
      end
    end

    context "without street address" do
      before do
        params[:street_address] = nil
      end

      it "is not valid" do
        expect(
          described_class.new(intake, params)
        ).not_to be_valid
      end
    end

    context "without a valid zip code" do
      before do
        params[:zip_code] = 1
      end

      it "is not valid" do
        expect(
          described_class.new(intake, params)
        ).not_to be_valid
      end
    end

    context "without a city" do
      before do
        params[:city] = nil
      end

      it "is not valid" do
        expect(
          described_class.new(intake, params)
        ).not_to be_valid
      end
    end

    context "without a state" do
      before do
        params[:state] = nil
      end

      it "is not valid" do
        expect(
            described_class.new(intake, params)
        ).not_to be_valid
      end
    end
  end

  context "save" do
    it "persists address fields to the intake" do
      expect {
        described_class.new(intake, params).save
      }.to change(intake, :street_address).from(nil).to("123 Main St")
       .and change(intake, :street_address2).from(nil).to("STE 5")
       .and change(intake, :city).from(nil).to("Newton")
       .and change(intake, :state).from(nil).to("TX")
       .and change(intake, :zip_code).from(nil).to("77494")
    end
  end
end