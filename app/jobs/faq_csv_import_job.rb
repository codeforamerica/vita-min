require 'csv'

# faq_csv = File.read("../../Downloads/faq.csv")
# result = FaqCsvImportJob.perform_now(File.read("../../Downloads/faq.csv"))
# File.open('/tmp/test_faq.yml', 'w') {|f| f.write result.to_yaml }
class FaqCsvImportJob < ApplicationJob
  def perform(faq_csv_content)
    [:en, :es].each do |locale|
      filename = "config/locales/#{locale}.yml"
      new_translations = self.class.updated_translations(
        YAML.safe_load(File.read("config/locales/#{locale}.yml")).with_indifferent_access,
        "#{locale}.views.public_pages.faq.question_groups",
        self.class.parse(faq_csv_content, locale)
      )
      File.write(filename, YAML.dump(new_translations))
    end
  end

  def self.updated_translations(initial_data, path, new_content)
    hash_to_modify = initial_data.dig(*path.split(".").map(&:to_sym))

    hash_to_modify.each do |question_group_key, question_group|
      question_group.each do |question_key, _|
        new_question_content = new_content[question_group_key][question_key]

        if new_question_content == { unchanged: true }
          next
        elsif new_question_content.nil?
          question_group.delete(question_key)
        else
          question_group[question_key] = new_question_content
        end
      end
    end

    initial_data
  end

  def self.parse(faq_csv_content, locale)
    lang_suffix = "(#{locale.to_s.upcase})"
    io = StringIO.new(faq_csv_content)
    io.set_encoding_by_bom
    new_copy = {}
    CSV.parse(io, headers: true).each do |row|
      section_key = row["Section Key"].to_sym
      question_key = row["Question Key"].to_sym
      answer_content = row["Answer #{lang_suffix}"]

      # find or create section key
      if !new_copy[section_key].present?
        new_copy[section_key] = {
          title: row["Section Name #{lang_suffix}"]
        }
      end

      new_copy[section_key][question_key] =
        if row["Updated"] == "No"
          {
            unchanged: true
          }
        else
          if answer_content.split("\n").length > 1
            answer_content = answer_content.split("\n").map { |content| "<p>" + content + "</p>" }.reject { |line| line == "<p></p>" }.join
          end
          {
            question: row["Question #{lang_suffix}"].strip,
            answer_html: answer_content.strip
          }
        end
    end

    new_copy
  end
end
