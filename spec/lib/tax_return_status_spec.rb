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

  context ".available_statuses_for" do
    context "when role_type is GreeterRole type" do
      it "only provides limited statuses" do
        result = described_class.available_statuses_for(role_type: GreeterRole::TYPE)
        expect(result.keys.length).to eq 2
        expect(result.keys.first).to eq "intake"
        expect(result.keys.last).to eq "file"
        expect(result["intake"]).to eq TaxReturnStatus::STATUSES_BY_STAGE["intake"]
        expect(result["file"]).to eq TaxReturnStatus::GREETER_STATUSES_BEYOND_INTAKE["file"]
      end
    end

    context "when role is anything else" do
      it "provides all statuses" do
        result = described_class.available_statuses_for(role_type: AdminRole::TYPE)
        expect(result).to eq TaxReturnStatus::STATUSES_BY_STAGE
      end
    end
  end
end
