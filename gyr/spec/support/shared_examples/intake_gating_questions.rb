shared_examples :a_show_method_dependent_on_ever_owned_home do
  context "with an intake that has ever owned a home" do
    let!(:intake) { create :intake, ever_owned_home: "yes" }

    it "returns true" do
      expect(described_class.show?(intake)).to eq true
    end
  end

  context "with an intake that has not answered whether they ever owned a home" do
    let!(:intake) { create :intake, ever_owned_home: "unfilled" }

    it "returns false" do
      expect(described_class.show?(intake)).to eq false
    end
  end

  context "with an intake that has never owned a home" do
    let!(:intake) { create :intake, ever_owned_home: "no" }

    it "returns false" do
      expect(described_class.show?(intake)).to eq false
    end
  end
end