require "rails_helper"

RSpec.describe StateFile::Questions::AzRetirementIncomeSubtractionController do
  it_behaves_like :state_file_retirement_income_subtraction do
    let(:intake) { create :state_file_az_intake}
  end
end