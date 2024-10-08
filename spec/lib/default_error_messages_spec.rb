require "rails_helper"

describe DefaultErrorMessages do
  describe ".generate" do
    context "service_type :ctc" do
      it "creates one of each of the default e-file error types" do
        described_class.generate!(service_type: :ctc)

        expect(EfileError.count).to eq 6
        [
          "BUNDLE-FAIL",
          "USPS-2147219401",
          "PDF-1040-FAIL",
          "TRANSMISSION-SERVICE",
          "TRANSMISSION-RESPONSE",
          "BANK-DETAILS",
        ].each do |error_code|
          expect(EfileError.where(code: error_code).count).to eq 1
        end
      end
    end

    context "service_type :state_file" do
      it "creates one of each of the default e-file error types for each state" do
        described_class.generate!(service_type: :state_file)

        expect(EfileError.count).to eq (5 * StateFile::StateInformationService.active_state_codes.length) + 1

        expect(EfileError.where(code: "USPS-2147219401").count).to eq 1
        [
          "BUNDLE-FAIL",
          "PDF-1040-FAIL",
          "TRANSMISSION-SERVICE",
          "TRANSMISSION-RESPONSE",
          "BANK-DETAILS",
        ].each do |error_code|
          expect(EfileError.where(code: error_code).count).to eq StateFile::StateInformationService.active_state_codes.length

          StateFile::StateInformationService.active_state_codes.each do |state_code|
            expect(EfileError.where(code: error_code, service_type: "state_file_#{state_code}").count).to eq 1
          end
        end
      end
    end
  end
end
