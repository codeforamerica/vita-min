require 'csv'

# faq_csv = File.read("../../Downloads/faq.csv")
# result = FaqCsvImportJob.perform_now(faq_csv)
# File.open('/tmp/test_faq.yml', 'w') {|f| f.write result.to_yaml }
class FaqCsvImportJob < ApplicationJob
  def perform(faq_csv_content)
    io = StringIO.new(faq_csv_content)
    io.set_encoding_by_bom
    new_copy = {}
    CSV.parse(io, headers: true).map do |row|
      section_key = row["Section Key"]
      answer_content = row["Answer (EN)"]
      if answer_content.split("\n").length > 1 &&
        !answer_content.include?("<p>")
        answer_content = answer_content.split("\n").map { |content| "<p>" + content + "</p>" }.reject{ |line| line == "<p></p>" }.join
      end
      q_a = {
        question: row["Question (EN)"].strip,
        answer_html: answer_content.strip
      }
      if !new_copy[section_key].present?
        new_copy[section_key] = {
          title: row["Section Name (EN)"]
        }
      end
      new_copy[section_key][row["Question Key"]] = q_a
    end

    return new_copy
  end
end