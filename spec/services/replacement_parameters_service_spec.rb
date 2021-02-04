require 'rails_helper'

describe ReplacementParametersService do
  let(:client) { create :client, intake: create(:intake, preferred_name: "Preferred Name") }
  let(:user) { create :user, name: "Preparer Name" }
  let(:locale) { "en" }
  subject { ReplacementParametersService.new(body: body, client: client, preparer: user, locale: locale) }

  context "<<Client.PreferredName>>" do
    let(:body) { "Hi <<Client.PreferredName>>" }

    it "replaces with client's preferred name" do
      expect(subject.process).to eq "Hi #{client.preferred_name}"
    end

    context "client without preferred name" do
      let(:client) { build :client, intake: create(:intake) }
      it "handles as gracefully as possible" do
        expect(subject.process).to eq "Hi "
      end
    end
  end

  context "<<Preparer.FirstName>>" do
    let (:body) { "Sincerely, <<Preparer.FirstName>>" }

    it "replaces with the preparer user's first name" do
      expect(subject.process).to eq "Sincerely, #{user.first_name}"
    end

    context "when preparer is nil" do
      let(:user) { nil }
      it "uses a fallback string" do
        expect(subject.process).to eq "Sincerely, Your tax team"
      end
    end
  end

  context "<<Documents.UploadLink>>" do
    let(:body) { "Upload here: <<Documents.UploadLink>>" }
    before do
      allow(client.intake).to receive(:requested_docs_token_link).and_return "https://example.com/my-token-link"
    end

    it "replaces with the clients intake upload link" do
      expect(subject.process).to eq "Upload here: #{client.intake.requested_docs_token_link}"
    end
  end

  context "<<Documents.List>>" do
    let(:body) { "We need these: <<Documents.List>>" }
    before do
      allow(client.intake).to receive(:relevant_document_types).and_return [DocumentTypes::Identity, DocumentTypes::Selfie, DocumentTypes::SsnItin, DocumentTypes::Other]
    end

    it "replaces with necessary document types" do
      expect(subject.process).to eq "We need these:   - ID\n  - Selfie\n  - SSN or ITIN\n  - Other"
    end
  end

  context "<<Client.YouOrMaybeYourSpouse>>" do
    let(:body) { "<<Client.YouOrMaybeYourSpouse>> can sign your return at this link" }

    context "when the client is filing joint" do
      before do
        allow(client.intake).to receive(:filing_joint_yes?).and_return true
      end

      it "says 'You or your' with capitalization" do
        expect(subject.process).to eq "You or your spouse can sign your return at this link"
      end
    end

    context "when the client is not filing joint" do
      before do
        allow(client.intake).to receive(:filing_joint_yes?).and_return false
      end

      it "just says 'You' (capitalized)" do
        expect(subject.process).to eq "You can sign your return at this link"
      end
    end
  end

  context "<<Link.E-signature>>" do
    describe "#process_sensitive_data" do
      before { allow(client).to receive(:login_link).and_return("https://getyourrefund.org/portal/account/raw_token")}

      context "when <<Link.E-signature>> exists in the body" do
        let(:body) { "Click here to sign your tax return: <<Link.E-signature>>" }
        it "replaces with correct link" do
          expect(subject.process_sensitive_data).to eq "Click here to sign your tax return: https://getyourrefund.org/portal/account/raw_token"
        end
      end

      context "when <<<<Link.E-signature>> does not exist in the body" do
        let(:body) { "Just a message" }

        it "does not regenerate the login link if it is not required for the body of the message" do
          subject.process_sensitive_data

          expect(client).to_not have_received(:login_link)
        end
      end
    end
  end

  context "replacement params with extra whitespace" do
    let(:body) { "Sincerely, << Preparer.FirstName >>" }

    it "still works" do
      expect(subject.process).to eq "Sincerely, #{user.first_name}"
    end
  end

  context "replacement params with different casing" do
    let(:body) { "Sincerely, << Preparer.firstname >>" }
    it "still works" do
      expect(subject.process).to eq "Sincerely, #{user.first_name}"
    end
  end

  context "strings that look like replacement params but don't have a matching replacement" do
    let(:body) { "Sincerely, <<Sloth.Firstname>>" }
    it "leaves the original string" do
      expect(subject.process).to eq "Sincerely, <<Sloth.Firstname>>"
    end
  end

  context "translation strings with replacement params" do
    before do
      allow(client.intake).to receive(:relevant_document_types).and_return [DocumentTypes::Identity, DocumentTypes::Selfie, DocumentTypes::SsnItin, DocumentTypes::Other]
      allow(client.intake).to receive(:requested_docs_token_link).and_return "https://example.com/my-token-link"
    end

    context "needs_more_information" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.needs_more_information") }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include "- ID\n  - Selfie\n  - SSN or ITIN\n  - Other"
          expect(subject.process).to include "https://example.com/my-token-link"
          expect(subject.process).to include user.first_name
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.needs_more_information", locale: "es") }
        let(:locale){ "es" }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include "https://example.com/my-token-link"
          expect(subject.process).to include "- Identificación\n  - Selfie\n  - SSN o ITIN\n  - Otro"
          expect(subject.process).to include user.first_name
        end
      end
    end

    context "accepted" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.accepted") }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include user.first_name
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.accepted", locale: "es") }
        let(:locale){ "es" }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include user.first_name
        end
      end
    end

    context "ready_for_qr" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.ready_for_qr") }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include user.first_name
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.ready_for_qr", locale: "es") }
        let(:locale) { "es" }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include user.first_name
        end
      end
    end
  end

  context "handling percent signs in emails" do
    let(:body) { "¿Esta persona proveyo más del 50% de su propio apoyo?" }
    describe "when there is a % in an email" do
      it "does not fail" do
        expect(subject.process).to eq "¿Esta persona proveyo más del 50% de su propio apoyo?"
      end
    end

    describe "when there is a %{ not related to a replacement param in an email" do
      let(:body) { "with some weird%{ string" }
      it "does not fail" do
        expect(subject.process).to eq "with some weird%{ string"
      end
    end
  end
end