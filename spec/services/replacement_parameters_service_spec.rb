require "rails_helper"

describe ReplacementParametersService do
  let(:client) { create :client, intake: create(:intake, preferred_name: "Preferred Name"), tax_returns: [create(:tax_return)] }
  let(:user) { create :user, name: "Preparer Name" }
  let(:locale) { "en" }
  subject { ReplacementParametersService.new(body: body, client: client, preparer: user, tax_return: client.tax_returns.first, locale: locale) }

  before do
    allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :voice_phone_number).and_return "+13444444444"
  end

  context "<<Client.PreferredName>>" do
    let(:body) { "Hi <<Client.PreferredName>>" }
    before do
      client.intake.preferred_name = "lowercased name"
    end
    
    it "replaces with client's preferred name (titleized)" do
      expect(subject.process).to eq "Hi Lowercased Name"
    end

    context "client without preferred name" do
      before do
        client.intake.preferred_name = nil
      end

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

  context "<<Client.LoginLink>>" do
    let(:body) { "Log in here: <<Client.LoginLink>>" }

    it "replaces with the login link" do
      expect(subject.process).to eq "Log in here: http://test.host/en/portal/login"
    end

    context "locale spanish" do
      let(:locale) { "es" }
      it "replaces with the login link" do
        expect(subject.process).to eq "Log in here: http://test.host/es/portal/login"
      end
    end
  end

  context "<<Documents.List>>" do
    let(:body) { "We need these: <<Documents.List>>" }
    before do
      allow(client.intake).to receive(:document_types_definitely_needed).and_return [DocumentTypes::Identity, DocumentTypes::Selfie, DocumentTypes::SsnItin, DocumentTypes::Other]
    end

    it "replaces with necessary document types" do
      expect(subject.process).to eq "We need these:   - Photo of your ID\n  - Photo of yourself, holding your ID near your chin (for identity verification)\n  - Photo of your SSN or ITIN cards for yourself, spouse, and dependents, if applicable\n  - Any other tax documents you'd like us to consider"
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
    end

    context "needs_more_information" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.needs_more_information") }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include "- Photo of your ID"
          expect(subject.process).to include "- Photo of yourself, holding your ID near your chin (for identity verification)"
          expect(subject.process).to include "- Photo of your SSN or ITIN cards for yourself, spouse, and dependents, if applicable"
          expect(subject.process).to include "http://test.host/en/portal/login"
          expect(subject.process).to include user.first_name
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.needs_more_information", locale: "es") }
        let(:locale){ "es" }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include "http://test.host/es/portal/login"
          expect(subject.process).to include "- Identificación con foto"
          expect(subject.process).to include "- Foto de usted sosteniendo su identificación con la foto cerca de su barbilla"
          expect(subject.process).to include "- Foto de la tarjeta SSN o del documento ITIN para usted, su cónyuge y sus dependientes"

          expect(subject.process).to include user.first_name
        end
      end
    end

    context "intake_greeter_info_requested" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.intake_greeter_info_requested") }
        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include "- Photo of your ID"
          expect(result).to include "- Photo of yourself, holding your ID near your chin (for identity verification)"
          expect(result).to include "- Photo of your SSN or ITIN cards for yourself, spouse, and dependents, if applicable"
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.intake_greeter_info_requested", locale: "es") }
        let(:locale){ "es" }
        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include "- Identificación con foto"
          expect(result).to include "- Foto de usted sosteniendo su identificación con la foto cerca de su barbilla"
          expect(result).to include "- Foto de la tarjeta SSN o del documento ITIN para usted, su cónyuge y sus dependientes"
        end
      end
    end

    context "intake_reviewing" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.intake_reviewing") }

        it "replaces the replacement strings in the template" do
          expect(subject.process).to include client.preferred_name
          expect(subject.process).to include user.first_name
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.intake_reviewing", locale: "es") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
        end
      end
    end

    context "intake_ready_for_call" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.intake_ready_for_call") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
          expect(result).to include "REPLACE ME"
          expect(result).to include OutboundCall.twilio_number
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.intake_ready_for_call", locale: "es") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
          expect(result).to include "REPLACE ME"
          expect(result).to include OutboundCall.twilio_number
        end
      end
    end

    context "prep_preparing" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.prep_preparing") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.prep_preparing", locale: "es") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
        end
      end
    end

    context "review_reviewing" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.review_reviewing") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.review_reviewing", locale: "es") }
        let(:locale) { "es" }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
        end
      end
    end

    context "review_ready_for_call" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.review_ready_for_call") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
          expect(result).to include "REPLACE ME"
          expect(result).to include OutboundCall.twilio_number
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.review_ready_for_call", locale: "es") }
        let(:locale) { "es" }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
          expect(result).to include "REPLACE ME"
          expect(result).to include OutboundCall.twilio_number
        end
      end
    end

    context "review signature requested" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.review_signature_requested") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include "Your #{client.tax_returns.first.year}"
          expect(result).to include "<<Link.E-signature>>"
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.review_signature_requested", locale: "es") }
        let(:locale) { "es" }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include "para #{client.tax_returns.first.year}"
          expect(result).to include "<<Link.E-signature>>"
        end
      end
    end

    context "file_accepted" do
      context "in english" do
        let(:body) { I18n.t("hub.status_macros.file_accepted") }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
          expect(result).to include "Your #{client.tax_returns.first.year}"
        end
      end

      context "in spanish" do
        let(:body) { I18n.t("hub.status_macros.file_accepted", locale: "es") }
        let(:locale) { "es" }

        it "replaces the replacement strings in the template" do
          result = subject.process
          expect(result).to include client.preferred_name
          expect(result).to include user.first_name
          expect(result).to include "de #{client.tax_returns.first.year}"
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

