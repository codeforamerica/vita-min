require 'rails_helper'

describe StandardizeAddressService do
  describe '#standardize_address_on_intake' do
    before do
      stub_request(:get, /.*secure\.shippingapis\.com.*/)
        .to_return(status: 200, body: usps_api_response_body, headers: {})
    end

    let(:usps_api_response_body) { file_fixture("usps_address_validation_body.xml").read }

    let(:intake) { create(:ctc_intake, street_address: "43 Vicksburg Street", street_address2: "B", city: city, state: state, zip_code: zip_code) }
    let(:city) { "San Francisco" }
    let(:state) { "CA" }
    let(:zip_code) { "94114" }

    it 'is valid and has standardized address fields' do
      service = described_class.new(intake)
      expect(service.valid?).to eq true
      expect(service.street_address).to eq "43 VICKSBURG ST UNIT B"
      expect(service.city).to eq "SAN FRANCISCO"
      expect(service.state).to eq "CA"
      expect(service.zip_code).to eq "94114"
    end

    context 'with only a city, state' do
      let(:zip_code) { nil }

      it 'is valid and has standardized address fields' do
        service = described_class.new(intake)
        expect(service.valid?).to eq true
        expect(service.street_address).to eq "43 VICKSBURG ST UNIT B"
        expect(service.city).to eq "SAN FRANCISCO"
        expect(service.state).to eq "CA"
        expect(service.zip_code).to eq "94114"
      end
    end

    context 'with only a zipcode' do
      let(:city) { nil }
      let(:state) { nil }

      it 'is valid and has standardized address fields' do
        service = described_class.new(intake)
        expect(service.valid?).to eq true
        expect(service.street_address).to eq "43 VICKSBURG ST UNIT B"
        expect(service.city).to eq "SAN FRANCISCO"
        expect(service.state).to eq "CA"
        expect(service.zip_code).to eq "94114"
      end
    end

    context 'without a city and state and an invalid zipcode' do
      before do
        allow(Rails.logger).to receive(:error)
      end

      let(:usps_api_response_body) { file_fixture("usps_address_validation_error_body.xml").read }

      let(:city) { nil }
      let(:state) { nil }
      let(:zip_code) { "44092" }

      it 'logs an error and returns the description' do
        expect(Rails.logger).to receive(:error).with("Error returned from USPS Address API: Address Not Found.  ")
        service = described_class.new(intake)
        expect(service.valid?).to eq false
        expect(service.errors).to eq "Address Not Found.  "
      end
    end
  end
end