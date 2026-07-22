require "rails_helper"

RSpec.describe EligibilityHouseholdForm do
  subject(:form) { described_class.new(intake, params) }

  let(:intake) { create :intake }

  let(:params) do
    {
      triage_filing_status: "single",
      state_of_residence: "CO",
      had_qualifying_child_under_17: "yes",
      had_qualifying_child_under_6: "yes"
    }
  end

  describe "validations" do
    it "is valid with valid Colorado attributes" do
      expect(form).to be_valid
    end

    it "requires a filing status" do
      params[:triage_filing_status] = nil

      expect(form).not_to be_valid
      expect(form.errors[:triage_filing_status]).to include("Can't be blank.")
    end

    it "requires a state of residence" do
      params[:state_of_residence] = nil

      expect(form).not_to be_valid
      expect(form.errors[:state_of_residence]).to include("Can't be blank.")
    end

    context "when the state is Colorado" do
      before do
        params[:state_of_residence] = "CO"
      end

      it "requires an answer to the under-17 question" do
        params[:had_qualifying_child_under_17] = "unfilled"

        expect(form).not_to be_valid
        expect(form.errors[:had_qualifying_child_under_17]).to be_present
      end

      it "accepts yes for the under-17 question" do
        params[:had_qualifying_child_under_17] = "yes"

        expect(form).to be_valid
      end

      it "accepts no for the under-17 question" do
        params[:had_qualifying_child_under_17] = "no"

        expect(form).to be_valid
      end

      it "does not require the under-6 question" do
        params[:had_qualifying_child_under_6] = "unfilled"

        expect(form).to be_valid
      end
    end

    context "when the state is New Jersey" do
      before do
        params[:state_of_residence] = "NJ"
        params[:had_qualifying_child_under_6] = "yes"
      end

      it "requires an answer to the under-6 question" do
        params[:had_qualifying_child_under_6] = "unfilled"

        expect(form).not_to be_valid
        expect(form.errors[:had_qualifying_child_under_6]).to be_present
      end

      it "accepts yes for the under-6 question" do
        params[:had_qualifying_child_under_6] = "yes"

        expect(form).to be_valid
      end

      it "accepts no for the under-6 question" do
        params[:had_qualifying_child_under_6] = "no"

        expect(form).to be_valid
      end

      it "does not require the under-17 question" do
        params[:had_qualifying_child_under_17] = "unfilled"

        expect(form).to be_valid
      end
    end
  end

  describe "clearing inapplicable child answers" do
    context "when the state is Colorado" do
      before do
        params[:state_of_residence] = "CO"
        params[:had_qualifying_child_under_17] = "yes"
        params[:had_qualifying_child_under_6] = "yes"
      end

      it "keeps the under-17 answer" do
        form.valid?

        expect(form.had_qualifying_child_under_17).to eq("yes")
      end

      it "clears the under-6 answer" do
        form.valid?

        expect(form.had_qualifying_child_under_6).to eq("unfilled")
      end
    end

    context "when the state is New Jersey" do
      before do
        params[:state_of_residence] = "NJ"
        params[:had_qualifying_child_under_17] = "yes"
        params[:had_qualifying_child_under_6] = "yes"
      end

      it "keeps the under-6 answer" do
        form.valid?

        expect(form.had_qualifying_child_under_6).to eq("yes")
      end

      it "clears the under-17 answer" do
        form.valid?

        expect(form.had_qualifying_child_under_17).to eq("unfilled")
      end
    end

    context "when the state is neither Colorado nor New Jersey" do
      before do
        params[:state_of_residence] = "NY"
        params[:had_qualifying_child_under_17] = "yes"
        params[:had_qualifying_child_under_6] = "yes"
      end

      it "clears both child answers" do
        form.valid?

        expect(form.had_qualifying_child_under_17).to eq("unfilled")
        expect(form.had_qualifying_child_under_6).to eq("unfilled")
      end
    end
  end

  describe "#save" do
    let(:intake) { create :intake }

    it "updates the intake with the form attributes" do
      expect(form).to be_valid

      form.save
      intake.reload

      expect(intake).to have_attributes(
                          triage_filing_status: "single",
                          state_of_residence: "CO",
                          had_qualifying_child_under_17: "yes",
                          had_qualifying_child_under_6: "unfilled"
                        )
    end
  end
end