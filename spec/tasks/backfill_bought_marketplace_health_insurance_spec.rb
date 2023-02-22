require "rails_helper"

describe "backfill_bought_marketplace_health_insurance:backfill" do
  include_context "rake"

  context "when there are intakes with filled in bought_health_insurance and unfilled bought_marketplace_health_insurance" do
    let!(:bought_health_insurance_yes_intakes) { create_list(:intake, 5, bought_health_insurance: "yes", bought_marketplace_health_insurance: "unfilled") }
    let!(:bought_health_insurance_no_intakes) { create_list(:intake, 5, bought_health_insurance: "no", bought_marketplace_health_insurance: "unfilled") }
    let!(:bought_health_insurance_unfilled_intake) { create(:intake, bought_health_insurance: "unfilled", bought_marketplace_health_insurance: "unfilled") }

    it "copies the bought_health_insurance to bought_marketplace_health_insurance" do
      expect {
        task.invoke
      }.not_to change(bought_health_insurance_unfilled_intake, :bought_marketplace_health_insurance)

      bought_health_insurance_yes_intakes.each do |intake|
        expect(intake.reload.bought_marketplace_health_insurance).to eq "yes"
      end

      bought_health_insurance_no_intakes.each do |intake|
        expect(intake.reload.bought_marketplace_health_insurance).to eq "no"
      end
    end
  end
end
