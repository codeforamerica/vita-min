require 'rails_helper'

describe Ctc::Dependents::ChildResidenceExceptionsForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake, lived_with_more_than_six_months: "no" }

    it "saves fields on the dependent" do
      expect {
        form = described_class.new(dependent, {
          born_in_2020: "yes",
          passed_away_2020: "no",
          placed_for_adoption: "yes",
          permanent_residence_with_client: "no"
        })
        form.save
      }.to change(dependent, :born_in_2020).to("yes")
                                           .and change(dependent, :passed_away_2020).to("no")
                                                                                          .and change(dependent, :placed_for_adoption).to("yes")
                                                                                                                                            .and change(dependent, :permanent_residence_with_client).to("no")
    end
  end
end