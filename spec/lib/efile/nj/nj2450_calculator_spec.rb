require 'rails_helper'

describe Efile::Nj::Nj2450Calculator do
  let(:intake) { create(:state_file_nj_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  before do
    instance.calculate
  end

  context "columnn a" do
    it "sums ui/wf/swf and ui/hc/wd" do
      
    end

    it "subtracts max contribution amount" do
      
    end
  end

  context "column c" do
    it "sums fli" do
      
    end
    
    it "subtracts max contribution amount" do
      
    end
  end
end
