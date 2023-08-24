require 'rails_helper'

describe TaxReturnStatus do
  context ".message_template_for" do
    context "prep_more_info" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("prep_info_requested")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "en")
        expect(TaxReturnStatus.message_template_for(:prep_info_requested, "es")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "es")
      end
    end

    context "intake_more_info" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("intake_info_requested")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "en")
        expect(TaxReturnStatus.message_template_for(:intake_info_requested, "es")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "es")
      end
    end

    context "review_more_info" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("review_info_requested")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "en")
        expect(TaxReturnStatus.message_template_for(:review_info_requested, "es")).to eq I18n.t("hub.status_macros.needs_more_information", locale: "es")
      end
    end

    context "review_reviewing" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("review_reviewing")).to eq I18n.t("hub.status_macros.review_reviewing", locale: "en")
        expect(TaxReturnStatus.message_template_for(:review_reviewing, "es")).to eq I18n.t("hub.status_macros.review_reviewing", locale: "es")
      end
    end

    context "filed_accepted" do
      it "returns a template" do
        expect(TaxReturnStatus.message_template_for("file_accepted")).to eq I18n.t("hub.status_macros.file_accepted", locale: "en")
        expect(TaxReturnStatus.message_template_for(:file_accepted, "es")).to eq I18n.t("hub.status_macros.file_accepted", locale: "es")
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
