require "rails_helper"

RSpec.describe Questions::SsnItinController do
  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe ".show?" do
    context "when a client said they need help getting an ITIN during triage" do
      let(:intake) { create :intake, need_itin_help: "yes" }

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when a client did not say they need help getting an ITIN during triage" do
      let(:intake) { create :intake, need_itin_help: "no" }

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end
  end

  describe "#update" do
    let(:intake) { create :intake, source: "SourceParam", primary_birth_date: 25.years.ago }
    let(:params) do
      {
        ssn_itin_form: {
          primary_ssn: "123455678",
          primary_ssn_confirmation: "123455678",
          primary_tin_type: "ssn_no_employment"
        }
      }
    end

    before do
      allow(MixpanelService).to receive(:send_event)
    end

    it "sends an event to mixpanel without PII" do
      post :update, params: params

      expect(MixpanelService)
        .to have_received(:send_event)
              .with(hash_including(
                      event_name: "question_answered",
                      data: hash_excluding(
                        :primary_ssn
                      )
                    ))
    end

    context "with invalid params" do
      let(:params) do
        {
          ssn_itin_form: {
            primary_ssn: nil,
            primary_tin_type: nil
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:primary_ssn].first).to eq "An SSN or ITIN is required."
        expect(error_messages[:primary_tin_type].first).to eq "Identification type is required."
      end
    end

    context "there is a matching_previous_year_intake" do
      let!(:matching_previous_year_intake) do
        _intake = build(:intake, primary_ssn: "123455678", primary_birth_date: intake.primary_birth_date, product_year: Rails.configuration.product_year - 1)
        create(:client, :with_gyr_return, tax_return_state: :file_accepted, intake: _intake).intake
      end

      it "saves it onto the intake" do
        post :update, params: params

        expect(intake.reload.matching_previous_year_intake).to eq matching_previous_year_intake
      end
    end
  end
end

