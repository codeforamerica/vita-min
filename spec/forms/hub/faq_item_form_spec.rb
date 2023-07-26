require "rails_helper"

RSpec.describe Hub::FaqItemForm do
  subject { described_class.new(faq_item, params) }

  let(:faq_category) { create(:faq_category) }
  let(:faq_item) { create(:faq_item, faq_category: faq_category) }
  let(:params) { {} }

  describe "validations" do
    it "requires name_en" do
      expect(subject).not_to be_valid
      expect(subject.errors.attribute_names).to include(:question_en)
    end

    it "requires position" do
      expect(subject).not_to be_valid
      expect(subject.errors.attribute_names).to include(:position)
    end
  end

  describe "#save" do
    let(:params) { {
      question_en: "New category",
      question_es: "",
      answer_en: "",
      answer_es: "",
      position: 2,
      slug: "new_category",
      faq_category_id: faq_category.id
    } }

    it 'creates a new faq item' do
      expect {
        subject.save
      }.to change(FaqItem, :count).by 1
    end
  end
end
