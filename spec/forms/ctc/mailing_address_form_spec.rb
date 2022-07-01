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
    let(:address_service_double) { double }
    before do
      allow(StandardizeAddressService).to receive(:new).and_return(address_service_double)
      allow(address_service_double).to receive(:valid?).and_return true
    end

    context "with all params" do
      it "is valid" do
        expect(
          described_class.new(intake, params)
        ).to be_valid
      end
    end

    context "with a puerto rico zip code" do
      it "is valid" do
        params[:zip_code] = '00931'

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
        params[:zip_code] = '1'
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

    context "when not valid with USPS service" do
      before do
        allow(address_service_double).to receive(:valid?).and_return false
        allow(address_service_double).to receive(:error_code).and_return "USPS-2147219400"
      end

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors[:city]).to eq ["Error: Invalid City"]
      end
    end
  end

  context "USPS API request" do
    context "when the API times out", do_not_stub_usps: true do
      before do
        stub_request(:get, /.*secure\.shippingapis\.com.*/).to_timeout
      end

      it "continues with client-entered values" do
        form = described_class.new(intake, params)
        form.valid?
        form.save
        expect(intake.reload.street_address).to eq("123 Main St")
      end
    end
  end

  context "save" do
    # When the address is successfully verified in this form, street_address2 will never be saved to intake,
    # as it will be combined with street_address when pulled from the API
    context "when the address was successfully verified with the USPS API" do
      let(:address_service_double) { double }
      before do
        allow(StandardizeAddressService).to receive(:new).and_return(address_service_double)
        allow(address_service_double).to receive(:valid?).and_return true
        allow(address_service_double).to receive(:street_address).and_return "123 Main Street STE 5"
        allow(address_service_double).to receive(:state).and_return "TX"
        allow(address_service_double).to receive(:zip_code).and_return "77494-1111"
        allow(address_service_double).to receive(:city).and_return "Newton-John"
        allow(address_service_double).to receive(:has_verified_address?).and_return true
      end

      it "saves the values returned from the API" do
        form = described_class.new(intake, params)
        expect {
          form.save
        }.to change(intake, :street_address).to("123 Main Street STE 5")
         .and change(intake, :city).to("Newton-John")
         .and change(intake, :state).to("TX")
         .and change(intake, :zip_code).to("77494-1111")
         .and not_change(intake, :street_address2)
        expect(intake.street_address2).to be_nil
        expect(intake.usps_address_verified_at).to be_within(1.second).of(DateTime.now)
      end
    end

    context "when the address was not successfully verified with the USPS API" do
      let(:address_service_double) { double }

      before do
        allow(StandardizeAddressService).to receive(:new).and_return(address_service_double)
        allow(address_service_double).to receive(:valid?).and_return true
        allow(address_service_double).to receive(:has_verified_address?).and_return false
      end

      it "saves the client entered values" do
        form = described_class.new(intake, params)
        expect {
          form.save
        }.to change(intake, :street_address).to("123 Main St")
         .and change(intake, :street_address2).to("STE 5")
         .and change(intake, :city).to("Newton")
         .and change(intake, :state).to("TX")
         .and change(intake, :zip_code).to("77494")
      end
    end
  end
end