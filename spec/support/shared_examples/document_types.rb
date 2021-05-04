shared_examples "a document type that provides doc help" do
  describe ".provide_doc_help?" do
    it "is true" do
      expect(described_class.provide_doc_help?).to be_truthy
    end
  end
end
