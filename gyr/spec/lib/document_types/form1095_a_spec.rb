require "rails_helper"

describe "DocumentTypes::Form1095A" do
  let(:described_class) { DocumentTypes::Form1095A }
  it_behaves_like "a document type that provides doc help"
end