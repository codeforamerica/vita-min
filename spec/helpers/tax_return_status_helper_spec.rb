require "rails_helper"

describe TaxReturnStatusHelper do
  describe "#grouped_status_options_for_select" do
    expected = [
      ["Intake",
       [
         ["Not ready", "intake_in_progress"],
         ["Ready for review", "intake_ready"],
         ["Reviewing", "intake_reviewing"],
         ["Ready for call", "intake_ready_for_call"],
         ["Info requested", "intake_info_requested"],
         ["Greeter - info requested", "intake_greeter_info_requested"],
         ["Needs doc help", "intake_needs_doc_help"],
       ]
      ],
      ["Tax prep",
       [
         ["Ready for prep", "prep_ready_for_prep"],
         ["Preparing", "prep_preparing"],
         ["Info requested", "prep_info_requested"]
       ]
      ],
      ["Quality review",
       [
         ["Ready for QR", "review_ready_for_qr"],
         ["Reviewing", "review_reviewing"],
         ["Ready for call", "review_ready_for_call"],
         ["Signature requested", "review_signature_requested"],
         ["Info requested", "review_info_requested"]
       ]
      ],
      [I18n.t("hub.tax_returns.stage.file"),
       [
         ["Needs review", "file_needs_review"],
         ["Ready to file", "file_ready_to_file"],
         ['E-filed', "file_efiled"],
         ["Filed by mail", "file_mailed"],
         ["Rejected", "file_rejected"],
         ["Accepted", "file_accepted"],
         ["Not filing", "file_not_filing"],
         ["Hold", "file_hold"],
         ["ID Check", "file_fraud_hold"]
       ]
      ]
    ]
    context "as a non-greeter" do
      let(:user_double) { double(User) }
      before do
        allow(helper).to receive(:current_user).and_return user_double
        allow(user_double).to receive(:role_type).and_return TeamMemberRole::TYPE
      end
      it "returns status options formatted to create select optgroups" do
        expect(helper.grouped_status_options_for_select).to eq(expected)
      end
    end

    context "as a greeter" do
      let(:user_double) { double(User) }
      before do
        allow(helper).to receive(:current_user).and_return user_double
        allow(user_double).to receive(:role_type).and_return GreeterRole::TYPE
      end

      it "returns limited statuses" do
        expect(helper.grouped_status_options_for_select)
          .to eq (
                   [["Intake",
                     [["Not ready", "intake_in_progress"],
                      ["Ready for review", "intake_ready"],
                      ["Reviewing", "intake_reviewing"],
                      ["Ready for call", "intake_ready_for_call"],
                      ["Info requested", "intake_info_requested"],
                      ["Greeter - info requested", "intake_greeter_info_requested"],
                      ["Needs doc help", "intake_needs_doc_help"]]],
                    ["Final steps", [["Not filing", "file_not_filing"], ["Hold", "file_hold"]]]]
                 )
      end
    end

  end

  describe "#language_options" do
    context "with a non default locale set" do
      before { allow(I18n).to receive(:locale).and_return(:es) }

      it "shows the translated locale options" do
        expect(helper.language_options)
          .to eq({
                   "Inglés" => :en, "Español" => :es
                 })
      end
    end
  end

  describe "#stage_and_status_translation" do
    describe "with an example status" do
      let(:tax_return) { create :tax_return, :intake_in_progress }
      it "returns the expected text" do
        expect(helper.stage_and_status_translation(tax_return.current_state)).to eq "Intake/Not ready"
      end
    end
  end
end
