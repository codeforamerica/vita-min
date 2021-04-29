require "rails_helper"

describe "DocumentTypes::Form1099B" do
  let(:described_class) { DocumentTypes::Form1099B }
  it_behaves_like "a document type that provides doc help"
end