require "rails_helper"

describe "DocumentTypes::Identity" do
  let(:described_class) { DocumentTypes::Identity }
  it_behaves_like "a document type that provides doc help"
end