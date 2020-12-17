require 'rails_helper'

describe TaxReturnStatus do
  context ".message_template_for" do
    context "prep_more_info" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("prep_more_info")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "en")
        expect(TaxReturnStatus.message_template_for(:prep_more_info, "es")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "es")
      end
    end

    context "intake_more_info" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("intake_more_info")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "en")
        expect(TaxReturnStatus.message_template_for(:intake_more_info, "es")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "es")
      end
    end

    context "review_more_info" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("review_more_info")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "en")
        expect(TaxReturnStatus.message_template_for(:review_more_info, "es")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "es")
      end
    end

    context "prep_ready_for_review" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("prep_ready_for_review")).to eq I18n.t("hub.status_macros.ready_for_qr", locale: "en")
        expect(TaxReturnStatus.message_template_for(:prep_ready_for_review, "es")).to eq I18n.t("hub.status_macros.ready_for_qr", locale: "es")
      end
    end

    context "filed_accepted" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("filed_accepted")).to eq I18n.t("hub.status_macros.accepted", locale: "en")
        expect(TaxReturnStatus.message_template_for(:filed_accepted, "es")).to eq I18n.t("hub.status_macros.accepted", locale: "es")
      end
    end

    context "statuses without templates" do
      it "returns an empty string" do
        expect(TaxReturnStatus.message_template_for("other_status")).to eq ""
        expect(TaxReturnStatus.message_template_for(:other_status, "es")).to eq ""
      end
    end
  end
end