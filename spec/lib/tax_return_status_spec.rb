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
    context "as a greeter" do
      let(:greeter) { create :greeter_user }
      it "only provides me with limited statuses" do
        result = described_class.available_statuses_for(greeter)
        expect(result.keys.length).to eq 2
        expect(result.keys.first).to eq "intake"
        expect(result.keys.last).to eq "file"
        expect(result["intake"]).to eq TaxReturnStatus::STATUSES_BY_STAGE["intake"]
        expect(result["file"]).to eq TaxReturnStatus::GREETER_FILE_STATUSES
      end
    end

    context "as any other role" do
      let(:admin) { create :admin_user }
      it "provides all of the statuses grouped by stage" do
        result = described_class.available_statuses_for(admin)
        expect(result).to eq TaxReturnStatus::STATUSES_BY_STAGE
      end
    end

    context "with role keyword arg" do
      context "when role is GreeterRole" do
        it "only provides me with limited statuses" do
          result = described_class.available_statuses_for(role: GreeterRole::TYPE)
          expect(result.keys.length).to eq 2
          expect(result.keys.first).to eq "intake"
          expect(result.keys.last).to eq "file"
          expect(result["intake"]).to eq TaxReturnStatus::STATUSES_BY_STAGE["intake"]
          expect(result["file"]).to eq TaxReturnStatus::GREETER_FILE_STATUSES
        end
      end

      context "when role is anything else" do
        it "only provides all statuses" do
          result = described_class.available_statuses_for(role: AdminRole::TYPE)
          expect(result).to eq TaxReturnStatus::STATUSES_BY_STAGE
        end
      end
    end
  end
end