require "rails_helper"

describe ZendeskIntakeService do
  let(:fake_eitc_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_uwtsa_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_client) { double(ZendeskAPI::Client) }
  let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 2) }
  let(:fake_zendesk_user) { double(ZendeskAPI::User, id: 1) }
  let(:state) { "ne" }
  let(:interview_timing_preference) { "" }
  let(:final_info) { "" }
  let(:intake) { create :intake, state: state, interview_timing_preference: interview_timing_preference, final_info: final_info }
  let(:service) { described_class.new(intake) }
  let(:email_opt_in) { "yes" }
  let(:sms_opt_in) { "yes" }
  let!(:user) do
    create :user,
           intake: intake,
           first_name: "Cher",
           last_name: "Cherimoya",
           email: "cash@raining.money",
           phone_number: "14155551234",
           email_notification_opt_in: email_opt_in,
           sms_notification_opt_in: sms_opt_in
  end

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(fake_zendesk_client)
    allow(ZendeskAPI::Ticket).to receive(:new).and_return(fake_zendesk_ticket)
    allow(ZendeskAPI::Ticket).to receive(:find).and_return(fake_zendesk_ticket)
  end

  describe "#client" do
    before do
      allow(EitcZendeskInstance).to receive(:client).and_return fake_eitc_zendesk_client
      allow(UwtsaZendeskInstance).to receive(:client).and_return fake_uwtsa_zendesk_client
    end

    context "when state is nil" do
      let(:state) { nil }

      it "returns a client for the EITC zendesk instance" do
        expect(service.client).to eq fake_eitc_zendesk_client
        expect(EitcZendeskInstance).to have_received(:client)
      end
    end

    context "in a state for the EITC zendesk instance" do
      let(:state) { "co" }

      it "returns a client for the EITC zendesk instance" do
        expect(service.client).to eq fake_eitc_zendesk_client
        expect(EitcZendeskInstance).to have_received(:client)
      end
    end

    context "in a state for the UW Tucson zendesk instance" do
      let(:state) { "az" }

      it "returns a client for the UW Tucson zendesk instance" do
        expect(service.client).to eq fake_uwtsa_zendesk_client
        expect(UwtsaZendeskInstance).to have_received(:client)
      end
    end
  end

  describe "#create_intake_ticket_requester" do
    before do
      allow(service).to receive(:find_or_create_end_user).and_return 1
    end

    context "when the user wants all notifications" do
      let(:email_opt_in) { "yes" }
      let(:sms_opt_in) { "yes" }

      it "returns the end user ID based on all contact info" do
        expect(service.create_intake_ticket_requester).to eq 1
        expect(service).to have_received(:find_or_create_end_user).with(
          "Cher Cherimoya", "cash@raining.money", "14155551234", exact_match: true
        )
      end
    end

    context "when the user doesn't want any notifications" do
      let(:email_opt_in) { "no" }
      let(:sms_opt_in) { "no" }

      it "returns the end user ID based on just the name" do
        expect(service.create_intake_ticket_requester).to eq 1
        expect(service).to have_received(:find_or_create_end_user).with(
          "Cher Cherimoya", nil, nil, exact_match: true
        )
      end
    end
  end

  describe "#create_intake_ticket" do
    before do
      intake.intake_ticket_requester_id = 987
      allow(service).to receive(:create_ticket).and_return(101)
      allow(service).to receive(:new_ticket_body).and_return "Body text"
    end

    context "in a state for the EITC Zendesk instance" do
      let(:state) { "co" }

      it "calls create_ticket with the right arguments" do
        result = service.create_intake_ticket
        expect(result).to eq 101
        expect(service).to have_received(:create_ticket).with(
          subject: "Cher Cherimoya",
          requester_id: 987,
          group_id: EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA,
          body: "Body text",
          fields: {
            EitcZendeskInstance::INTAKE_SITE => "online_intake",
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
          }
        )
      end
    end

    context "in a state for the UWTSA Zendesk instance" do
      let(:state) { "az" }

      it "excludes intake site, and intake status and sends a nil group_id" do
        result = service.create_intake_ticket
        expect(result).to eq 101
        expect(service).to have_received(:create_ticket).with(
          subject: "Cher Cherimoya",
          requester_id: 987,
          group_id: nil,
          body: "Body text",
          fields: {}
        )
      end
    end

    context "when the intake does not have a requester id" do
      before { intake.intake_ticket_requester_id = nil }

      it "raises an error" do
        expect do
          service.create_intake_ticket
        end.to raise_error(ZendeskIntakeService::MissingRequesterIdError)
      end
    end
  end

  describe "#new_ticket_body" do
    let(:expected_body) do
      <<~BODY
        New Online Intake Started

        Name: Cher Cherimoya
        Phone number: (415) 555-1234
        Email: cash@raining.money
        State (based on mailing address): Nebraska

        Prefers notifications by:
            • Text message
            • Email

        This filer has:
            • Verified their identity through ID.me
            • Consented to this VITA pilot
      BODY
    end

    it "adds all relevant details about the user and intake" do
      expect(service.new_ticket_body).to eq expected_body
    end
  end

  describe "#contact_preferences" do
    context "with sms and email" do
      let(:email_opt_in) { "yes" }
      let(:sms_opt_in) { "yes" }

      it "shows both" do
        expect(service.contact_preferences).to eq <<~TEXT
          Prefers notifications by:
              • Text message
              • Email
        TEXT
      end
    end

    context "with just sms" do
      let(:email_opt_in) { "no" }
      let(:sms_opt_in) { "yes" }

      it "shows just sms" do
        expect(service.contact_preferences).to eq <<~TEXT
          Prefers notifications by:
              • Text message
        TEXT
      end
    end

    context "with neither sms nor email" do
      let(:email_opt_in) { "no" }
      let(:sms_opt_in) { "no" }

      it "says they what they don't want" do
        expect(service.contact_preferences).to eq <<~TEXT
          Did not want email or text message notifications.
        TEXT
      end
    end
  end

  describe "#new_ticket_group_id" do
    context "with a Tax Help Colorado state" do
      let(:state) { "ne" }
      it "assigns to the shared Tax Help Colorado / UWBA online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
      end
    end

    context "with California" do
      let(:state) { "ca" }
      it "assigns to the shared Tax Help Colorado / UWBA online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
      end
    end

    context "with a fed-only state" do
      let(:state) { "ak" }
      it "assigns to the shared Tax Help Colorado / UWBA online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
      end
    end

    context "with a GWISR state" do
      let(:state) { "ga" }
      it "assigns to the Goodwill online intake" do
        expect(service.new_ticket_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_GWISR
      end
    end

    context "with any other state" do
      let(:state) { "ny" }
      it "assigns to the UW Tucson intake" do
        expect(service.new_ticket_group_id).to be_nil
      end
    end
  end

  describe "#send_intake_pdf" do
    let(:output) { true }
    let(:fake_file) { instance_double(File) }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:pdf).and_return(fake_file)
    end

    it "appends the intake pdf to the ticket" do
      result = service.send_intake_pdf
      expect(result).to eq true
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: 34,
        filename: "CherCherimoya_13614c.pdf",
        file: fake_file,
        comment: "New 13614-C Complete",
        fields: {
          EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS
        }
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_intake_pdf
        end.to raise_error(ZendeskIntakeService::CouldNotSendIntakePdfError)
      end
    end
  end

  describe "#send_all_docs" do
    let(:output) { true }
    let!(:documents) do
      [
        create(:document, :with_upload, intake: intake, document_type: "W-2"),
        create(:document, :with_upload, intake: intake, document_type: "1099-MISC"),
      ]
    end

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_multiple_files_to_ticket).and_return(output)
    end

    it "appends each document to the ticket" do
      result = service.send_all_docs

      expect(result).to eq true

      expect(service).to have_received(:append_multiple_files_to_ticket).with(
        ticket_id: 34,
        file_list: [
          { filename: documents[0].upload.filename, file: instance_of(Tempfile) },
          { filename: documents[1].upload.filename, file: instance_of(Tempfile) },
        ],
        comment: <<~DOCS
          Documents:
          * #{documents[0].upload.filename} (#{documents[0].document_type})
          * #{documents[1].upload.filename} (#{documents[1].document_type})
        DOCS
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_all_docs
        end.to raise_error(ZendeskIntakeService::CouldNotSendDocumentError)
      end
    end
  end

  describe "#send_final_intake_pdf" do
    let(:output) { true }
    let(:fake_file) { instance_double(File) }
    let(:interview_timing_preference) { "Monday evenings and Wednesday mornings" }
    let(:final_info) { "I want my money" }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:pdf).and_return(fake_file)
    end

    it "appends the intake pdf to the ticket with updated status and interview preferences" do
      result = service.send_final_intake_pdf
      expect(result).to eq true
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: 34,
        filename: "Final_CherCherimoya_13614c.pdf",
        file: fake_file,
        comment: "Online intake form submitted and ready for review. The taxpayer was notified that their information has been submitted. (automated_notification_submit_confirmation)\"\n\nClient's provided interview preferences: Monday evenings and Wednesday mornings\n\nAdditional information from Client: I want my money\n",
        fields: {
          EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW
        }
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_final_intake_pdf
        end.to raise_error(ZendeskIntakeService::CouldNotSendCompletedIntakePdfError)
      end
    end
  end

  describe "#send_consent_pdf" do
    let(:output) { true }
    let(:fake_consent_pdf) { instance_double(File) }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:consent_pdf).and_return(fake_consent_pdf)
    end

    it "appends the intake pdf to the ticket with updated status and interview preferences" do
      result = service.send_consent_pdf
      expect(result).to eq true
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: 34,
        filename: "CherCherimoya_Consent.pdf",
        file: fake_consent_pdf,
        comment: "Signed consent form\n",
      )
    end

    context "when the zendesk api fails" do
      let(:output){ false }

      it "raises an error" do
        expect do
          service.send_consent_pdf
        end.to raise_error(ZendeskIntakeService::CouldNotSendConsentPdfError)
      end
    end
  end

  describe "#send_additional_info_document" do
    let(:output) { true }
    let(:fake_file) { instance_double(File) }

    before do
      intake.intake_ticket_id = 34
      allow(service).to receive(:append_file_to_ticket).and_return(output)
      allow(intake).to receive(:additional_info_png).and_return(fake_file)
    end

    it "appends client and spouse (if applicable) info in png" do
      result = service.send_additional_info_document
      expect(result).to eq true
      expect(service).to have_received(:append_file_to_ticket).with(
        ticket_id: 34,
        filename: "CherCherimoya_identity_info.png",
        file: fake_file,
        comment: "Identity Info Document contains name and ssn",
      )
    end
  end
end
