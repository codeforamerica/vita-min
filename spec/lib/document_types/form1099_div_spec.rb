require "rails_helper"

describe "DocumentTypes::Form1099Div" do
  let(:described_class) { DocumentTypes::Form1099Div}
  it_behaves_like "a document type that provides doc help"
end