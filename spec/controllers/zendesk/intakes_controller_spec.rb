require "rails_helper"

RSpec.describe Zendesk::IntakesController do
  let(:user) { create :user, provider: "zendesk" }
  let(:ticket) { instance_double(ZendeskAPI::Ticket) }
  let(:intake) { create :intake, intake_ticket_id: 123, zendesk_instance_domain: EitcZendeskInstance::DOMAIN }
  let(:uwtsa_intake) do
    create :intake, intake_ticket_id: 123, zendesk_instance_domain: UwtsaZendeskInstance::DOMAIN
  end

  shared_examples :an_eitc_zendesk_intake_only_page do |action:|
    context "as an authenticated eitc zendesk user with a uwtsa intake" do
      before do
        allow(subject).to receive(:current_user).and_return(user)
      end

      it "returns 404 with a not found page" do
        expect do
          get action, params: valid_params
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#intake_pdf" do
    it_behaves_like :a_protected_zendesk_ticket_page, action: :intake_pdf do
      let(:valid_params) do
        { id: intake.id, filename: intake.intake_pdf_filename }
      end
    end

    it_behaves_like :an_eitc_zendesk_intake_only_page, action: :intake_pdf do
      let(:valid_params) do
        { id: uwtsa_intake.id, filename: uwtsa_intake.intake_pdf_filename }
      end
    end

    context "as an authenticated zendesk user with ticket access" do
      let(:intake_pdf_spy) { instance_double(IntakePdf) }
      let(:fake_pdf) { StringIO.new("i am a pdf") }

      before do
        allow(subject).to receive(:current_user).and_return(user)
        allow(subject).to receive(:current_ticket).and_return(ticket)
        allow(intake_pdf_spy).to receive(:output_file).and_return(fake_pdf)
        allow(IntakePdf).to receive(:new).and_return(intake_pdf_spy)
      end

      it "returns the 13614-C pdf filled out for the intake inline" do
        get :intake_pdf, params: { id: intake.id, filename: intake.intake_pdf_filename }

        expect(assigns(:intake)).to eq intake
        expect(IntakePdf).to have_received(:new).with(intake)
        expect(response.headers["Content-Type"]).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to eq("inline")
      end
    end
  end

  describe "#consent_pdf" do
    it_behaves_like :a_protected_zendesk_ticket_page, action: :consent_pdf do
      let(:valid_params) do
        { id: intake.id, filename: intake.consent_pdf_filename }
      end
    end

    it_behaves_like :an_eitc_zendesk_intake_only_page, action: :consent_pdf do
      let(:valid_params) do
        { id: uwtsa_intake.id, filename: uwtsa_intake.consent_pdf_filename }
      end
    end

    context "as an authenticated zendesk user with ticket access" do
      let(:consent_pdf_spy) { instance_double(ConsentPdf) }
      let(:fake_pdf) { StringIO.new("i am a pdf") }

      before do
        allow(subject).to receive(:current_user).and_return(user)
        allow(subject).to receive(:current_ticket).and_return(ticket)
        allow(ConsentPdf).to receive(:new).and_return(consent_pdf_spy)
        allow(consent_pdf_spy).to receive(:output_file).and_return(fake_pdf)
      end

      it "returns the 13614-C pdf filled out for the intake inline" do
        get :consent_pdf, params: { id: intake.id, filename: intake.consent_pdf_filename }

        expect(assigns(:intake)).to eq intake
        expect(ConsentPdf).to have_received(:new).with(intake)
        expect(response.headers["Content-Type"]).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to eq("inline")
      end
    end
  end

  describe "#banking_info" do
    it_behaves_like :a_protected_zendesk_ticket_page, action: :banking_info do
      let(:valid_params) do
        { id: intake.id }
      end
    end

    it_behaves_like :an_eitc_zendesk_intake_only_page, action: :banking_info do
      let(:valid_params) do
        { id: uwtsa_intake.id }
      end
    end
  end
end
