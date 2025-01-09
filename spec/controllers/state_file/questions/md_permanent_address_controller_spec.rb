require "rails_helper"

describe StateFile::Questions::MdPermanentAddressController do
  let(:intake) { create :state_file_md_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it "succeeds" do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "Did you live at this address"
    end
  end

  describe "#update" do
    # the disqualifying param here is permanent_address_outside_md but this is set in the form based on:
    # * whether they are using the address from DF
    # * if so, whether that address is in MD
    # so we have to mock the DF data
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_md_intake do
      let(:eligible_params) do
        allow_any_instance_of(DirectFileData).to receive(:mailing_state).and_return "MD"
        {
          state_file_md_permanent_address_form: {
            confirmed_permanent_address: "yes",
          }
        }
      end

      let(:ineligible_params) do
        allow_any_instance_of(DirectFileData).to receive(:mailing_state).and_return "NC"
        {
          state_file_md_permanent_address_form: {
            confirmed_permanent_address: "yes",
          }
        }
      end
    end
  end
end