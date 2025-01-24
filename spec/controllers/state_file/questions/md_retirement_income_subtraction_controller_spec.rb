require "rails_helper"

describe StateFile::Questions::MdRetirementIncomeSubtractionController do

  it_behaves_like :state_file_retirement_income_subtraction do
    let(:intake) { create :state_file_md_intake}
  end

end