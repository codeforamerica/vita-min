require 'rails_helper'

describe SubmissionBuilder::State1099R do
  StateFile::StateInformationService.active_state_codes.each do |state_code|
    describe ".document" do
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:payer_tin) { "270293117" }
      let!(:form1099r) do
        create(
          :state_file1099_r,
          payer_tin: payer_tin
          )
      end
      let(:primary_ssn) { "100000030" }
      let(:primary_first_name) { "Merlin" }
      let(:primary_middle_initial) { "A" }
      let(:primary_last_name) { "Monroe" }
      let(:intake) do
        create(
          "state_file_#{state_code}_intake".to_sym,
          primary_first_name: primary_first_name,
          primary_middle_initial: primary_middle_initial,
          primary_last_name: primary_last_name,
          )
      end
      let(:doc) { described_class.new(submission, kwargs: { form1099r: form1099r }).document }
      before do
        intake.direct_file_data.primary_ssn = primary_ssn
      end

      xit "generates xml with the right values" do
      end
    end
  end
end
