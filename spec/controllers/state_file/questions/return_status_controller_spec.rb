require "rails_helper"

RSpec.describe StateFile::Questions::ReturnStatusController do
  describe "#edit" do
    context "assignment of various instance variables" do
      it "assigns them correctly" do
        az_intake = create(:state_file_az_intake)
        sign_in az_intake
        create(:efile_submission, :notified_of_rejection, :for_state, data_source: az_intake)
        get :edit, params: { us_state: "az" }

        expect(assigns(:tax_refund_url)).to eq "https://aztaxes.gov/home/checkrefund"
        expect(assigns(:tax_payment_url)).to eq "AZTaxes.gov"
        expect(assigns(:primary_tax_form_name)).to eq "Form AZ-140V"
        expect(assigns(:mail_voucher_address)).to eq "Arizona Department of Revenue<br/>"\
          "PO Box 29085<br/>"\
          "Phoenix, AZ 85038-9085"
        expect(assigns(:voucher_path)).to eq "/pdfs/AZ-140V.pdf"
        expect(assigns(:survey_link)).to eq "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey"
      end
    end

    context "AZ" do
      render_views
      let(:az_intake) { create :state_file_az_intake }
      before do
        sign_in az_intake
      end

      context "happy path" do
        let!(:efile_submission) { create(:efile_submission, :notified_of_rejection, :for_state, data_source: az_intake) }

        it "shows the most recent submission" do
          get :edit, params: { us_state: "az" }

          expect(assigns(:submission_to_show)).to eq efile_submission
        end
      end

      context "unhappy path" do
        let!(:previous_efile_submission) { create(:efile_submission, :accepted, :for_state, data_source: az_intake) }
        let!(:latest_efile_submission) { create(:efile_submission, :transmitted, :for_state, data_source: az_intake) }

        before do
          latest_efile_submission.transition_to!(:rejected)
          create(:efile_submission_transition_error, efile_error: efile_error, efile_submission_transition: latest_efile_submission.last_transition, efile_submission_id: latest_efile_submission.id)
          latest_efile_submission.transition_to!(:cancelled)
        end

        context "client got accepted and then submitted another return which got reject 901" do
          let(:efile_error) { create(:efile_error, code: "901", service_type: :state_file, expose: true) }

          it "shows the most recent accepted submission" do
            get :edit, params: { us_state: "az" }

            expect(assigns(:submission_to_show)).to eq previous_efile_submission
          end
        end

        context "client got accepted and then submitted another return which got a different rejection" do
          let(:efile_error) { create(:efile_error, code: "A LEGIT REJECTION I GUESS", service_type: :state_file, expose: true) }

          it "shows the most recent submission" do
            get :edit, params: { us_state: "az" }

            expect(assigns(:submission_to_show)).to eq latest_efile_submission
          end
        end
      end
    end

    context "NY" do
      let(:ny_intake) { create :state_file_ny_intake }
      before do
        sign_in ny_intake
      end

      context "happy path" do
        let!(:efile_submission) { create(:efile_submission, :notified_of_rejection, :for_state, data_source: ny_intake) }

        it "shows the most recent submission" do
          get :edit, params: { us_state: "ny" }

          expect(assigns(:submission_to_show)).to eq efile_submission
        end
      end
    end
  end
end