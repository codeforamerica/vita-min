require "rails_helper"

RSpec.describe StateFile::Questions::NcRetirementIncomeSubtractionController do
  it_behaves_like :state_file_retirement_income_subtraction do
    let(:intake) { create :state_file_nc_intake}
  end
end