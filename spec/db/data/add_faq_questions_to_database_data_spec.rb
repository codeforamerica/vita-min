require "rails_helper"
require_relative "../../../db/data/20230629222742_add_faq_questions_to_database"

describe "AddFaqQuestionsToDatabase" do
  it "resets the set of answers for each filer to nil if the whole set (including prefer not to answer) was true" do
    AddFaqQuestionsToDatabase.new.up

    expect(FaqCategory.all.size).to eq(19)
    expect(FaqItem.all.size).to eq(65)
    expect(FaqQuestionGroupItem.all.size).to eq(3)
  end
end
