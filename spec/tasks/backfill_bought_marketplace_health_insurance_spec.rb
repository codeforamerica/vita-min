require "rails_helper"

describe "backfill_bought_marketplace_health_insurance:backfill" do
  include_context "rake"

  context "when there are intakes with filled in bought_health_insurance and unfilled bought_marketplace_health_insurance" do
    before do
      5.times do
        create(:intake, bought_health_insurance: "yes", bought_marketplace_health_insurance: "unfilled")
        create(:intake, bought_health_insurance: "no", bought_marketplace_health_insurance: "unfilled")
      end
    end

    it "copies the bought_health_insurance to bought_marketplace_health_insurance" do
      task.invoke

      Intake.all.each do |intake|
        expect(intake.bought_marketplace_health_insurance).to eq intake.bought_health_insurance
      end
    end
  end
end
