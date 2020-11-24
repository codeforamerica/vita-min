require "rails_helper"

# Question for product:
# - Do we delete the other form?

RSpec.describe Hub::DropOffClientForm do
  let(:form) do
    Hub::DropOffClientForm.new(
      preferred_name: "Gene Parmesan",
      primary_first_name: "Gene",
      primary_last_name: "Parmesan",
      email_address: "gene@example.com",
      phone_number: "+14155551212",
      street_address: "123 Main St",
      city: "Anytown",
      state: "CA",
      zip_code: "94612",
      email_notification_opt_in: "yes",
      needs_help_2019: "yes",
      signature_method: "e_signature",
      state_of_residence: "OR",
      additional_info: "FYI this client is very nice",
      certification_level: "Advanced",
      intake_site: "Adams City High School",
      organization: "thc",
      upload: fixture_file_upload("attachments/document_bundle.pdf"),
    )
  end

  context "required fields" do
    it "accepts the required parameters and creates a client etc" do
      # additional info can update notes tab
      form = Hub::DropOffClientForm.new(
        preferred_name: "Gene Parmesan",
        primary_first_name: "Gene",
        primary_last_name: "Parmesan",
        email_address: "gene@example.com",
        phone_number: "+14155551212",
        street_address: "123 Main St",
        city: "Anytown",
        state: "CA",
        zip_code: "94612",
        email_notification_opt_in: "yes",
        needs_help_2019: "yes",
        signature_method: "e_signature",
        state_of_residence: "OR",
        additional_info: "FYI this client is very nice",
        certification_level: "Advanced",
        intake_site: "Adams City High School",
        organization: "thc",
      )
      expect {
        form.save
      }.to change(Intake, :count).by(1)
        .and change(Client, :count).by(1)
        .and change(TaxReturn, :count).by(1)
        .and change(IntakeSiteDropOff, :count).by(1)
        .and change(Document, :count).by(1)
      client = Client.last
      intake = client.intake
      expect(intake.preferred_name).to eq("Gene Parmesan")
      expect(intake.primary_first_name).to eq("Gene")
      expect(intake.primary_last_name).to eq("Parmesan")
      expect(intake.email_address).to eq("gene@example.com")
      expect(intake.phone_number).to eq("+14155551212")
      expect(intake.street_address).to eq("123 Main St")
      expect(intake.city).to eq("Anytown")
      expect(intake.state).to eq("CA")
      expect(intake.zip_code).to eq("94612")
      expect(intake.email_notification_opt_in).to eq("yes")
      expect(intake.state_of_residence).to eq("OR")
      expect(intake.additional_info).to eq("FYI this client is very nice")
      expect(client.tax_returns.count).to eq(1)
      expect(client.tax_returns.first.year).to eq(2019)
      expect(client.tax_returns.first.status).to eq("intake_needs_assignment")
      expect(client.intake_site_drop_off.certification_level).to eq("Advanced")
      expect(client.intake_site_drop_off.signature_method).to eq("e_signature")
      expect(client.intake_site_drop_off.intake_site).to eq("Adams City High School")
      expect(client.intake_site_drop_off.organization).to eq("thc")
      expect(client.intake_site_drop_off.name).to eq("Gene Parmesan")
      expect(client.documents.first.upload).to be_attached
      # TODO: consider moving this and putting the validation on the original form instead (unless we want to require it)
      expect(client.intake_site_drop_off.document_bundle).to be_attached
    end
  end

  context "with multiple tax years" do

  end

  context "sms phone number" do
    context "with sms opt-in" do
      it "uses phone number as sms_phone_number" do

      end
    end

    context "without sms opt-in" do
      it "leaves sms_phone_number blank" do

      end
    end
  end
end
