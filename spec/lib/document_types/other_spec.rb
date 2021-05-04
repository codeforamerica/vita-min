require "rails_helper"

describe "DocumentTypes::Other" do
  let(:described_class) { DocumentTypes::Other }
  it "skips i dont know option" do
    expect(described_class.skip_dont_have?).to eq true
  end
end