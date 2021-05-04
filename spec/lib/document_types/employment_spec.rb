require "rails_helper"

describe "DocumentTypes::Employment" do
  let(:described_class) { DocumentTypes::Employment }
  it_behaves_like "a document type that provides doc help"
end