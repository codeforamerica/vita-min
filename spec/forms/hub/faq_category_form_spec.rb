require "rails_helper"

RSpec.describe Hub::FaqCategoryForm do
  subject { described_class.new(faq_category, params) }

  let(:faq_category) { build(:faq_category) }
  let(:params) { {} }

  describe "validations" do
    it "requires name_en" do
      expect(subject).not_to be_valid
      expect(subject.errors.attribute_names).to include(:name_en)
    end

    it "requires position" do
      expect(subject).not_to be_valid
      expect(subject.errors.attribute_names).to include(:position)
    end
  end

  describe "#save" do
    let(:params) { {
      name_en: "New category",
      name_es: "",
      position: 2,
      slug: "new_category"
    } }

    it 'creates a new faq category' do
      expect {
        subject.save
      }.to change(FaqCategory, :count).by 1
    end
  end
end
