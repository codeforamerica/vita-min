require "rails_helper"

describe TaxReturnStatusHelper do
  describe "#grouped_status_options" do
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
      expect(helper.grouped_tax_return_status_options).to eq(expected)
    end
  end

  describe "#status_with_stage" do
    describe "intake_in_progress" do
      let(:tax_return) { create :tax_return, status: "intake_in_progress" }
      it "returns Intake / In progress" do
        expect(helper.status_with_stage(tax_return)).to eq "Intake / In progress"
      end
    end

    describe "prep_more_info" do
      let(:tax_return) { create :tax_return, status: "prep_more_info" }
      it "returns Tax prep / Needs more information" do
        expect(helper.status_with_stage(tax_return)).to eq "Tax prep / Needs more information"
      end
    end

    describe "review_complete_signature_requested" do
      let(:tax_return) { create :tax_return, status: "review_complete_signature_requested" }
      it "returns Review / Complete / Signature requested" do
        expect(helper.status_with_stage(tax_return)).to eq "Quality review / Complete/Signature requested"
      end
    end
  end
end