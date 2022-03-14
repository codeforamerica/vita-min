require 'rails_helper'

describe Ctc::Dependents::ChildResidenceExceptionsForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake, lived_with_more_than_six_months: "no" }

    it "saves fields on the dependent" do
      expect {
        form = described_class.new(dependent, {
          residence_exception_born: "yes",
          residence_exception_passed_away: "no",
          residence_exception_adoption: "yes",
          permanent_residence_with_client: "no"
        })
        form.save
      }.to change(dependent, :residence_exception_born).to("yes")
                                           .and change(dependent, :residence_exception_passed_away).to("no")
                                                                                          .and change(dependent, :residence_exception_adoption).to("yes")
                                                                                                                                            .and change(dependent, :permanent_residence_with_client).to("no")
    end
  end
end