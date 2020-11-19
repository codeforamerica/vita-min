require "rails_helper"

describe TaxReturnStatusHelper do
  describe "#grouped_status_options_for_select" do
    expected = [
      ["Intake",
       [
         ["In progress", "intake_in_progress"],
         ["Open", "intake_open"],
         ["In review", "intake_review"],
         ["Needs more information", "intake_more_info"],
         ["Info requested", "intake_info_requested"],
         ["Needs assignment", "intake_needs_assignment"]
       ]
      ],
      ["Tax prep",
       [
         ["Ready for call", "prep_ready_for_call"],
         ["Needs more information", "prep_more_info"],
         ["Entering in TaxSlayer", "prep_preparing"],
         ["Ready for QR", "prep_ready_for_review"]
       ]
      ],
      ["Quality review",
       [
         ["In review", "review_in_review"],
         ["Complete/Signature requested", "review_complete_signature_requested"],
         ["Needs more information", "review_more_info"]
       ]
      ],
      ["Final steps",
       [
         ["Closed", "finalize_closed"],
         ["Return signed", "finalize_signed"]
       ]
      ],
      [I18n.t("case_management.tax_returns.stage.filed"),
       [
         ["Return e-filed", "filed_e_file"],
         ["Return filed by mail", "filed_mail_file"],
         ["Rejected", "filed_rejected"],
         ["Accepted", "filed_accepted"]
       ]
      ]
    ]

    it "returns status options formatted to create select optgroups" do
      expect(helper.grouped_status_options_for_select).to eq(expected)
    end
  end

  describe "#language_options" do
    context "with a non default locale set" do
      before { allow(I18n).to receive(:locale).and_return(:es) }

      it "shows the translated locale options" do
        expect(helper.language_options).to eq({
          "Inglés"=>:en, "Español"=>:es
        })
      end
    end
  end

  describe "#stage_and_status_translation" do
    describe "with an example status" do
      let(:tax_return) { create :tax_return, status: "intake_in_progress" }
      it "returns the expected text" do
        expect(helper.stage_and_status_translation(tax_return.status)).to eq "Intake/In progress"
      end
    end
  end
end