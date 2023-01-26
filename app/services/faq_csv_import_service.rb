require 'csv'

# faq_csv = File.read("../../Downloads/faq.csv")
# result = FaqCsvImportJob.perform_now(File.read("../../Downloads/faq.csv"))
# File.open('/tmp/test_faq.yml', 'w') {|f| f.write result.to_yaml }
class FaqCsvImportService
  def self.perform_now(faq_csv_content, write: false)
    [:en, :es].each do |locale|
      filename = "config/locales/#{locale}.yml"
      translation_data = YAML.load_file("config/locales/#{locale}.yml")
      translation_data = updated_translations(
        translation_data,
        "#{locale}.views.public_pages.faq.question_groups",
        parse(faq_csv_content, locale)
      )

      val = YAML.dump(translation_data)
      if write
        File.write(filename, val)
      end
    end
  end

  def self.updated_translations(initial_data, path, new_content)
    hash_to_modify = initial_data.dig(*path.split("."))
    raise "Unable to find data at #{path}" if hash_to_modify.blank?

    hash_to_modify.each do |question_group_key, question_group|
      question_group.each do |question_key, _|
        if new_content[question_group_key].nil?
          hash_to_modify.delete(question_group_key)
          next
        end
        new_question_content = new_content[question_group_key][question_key]

        if new_question_content == "unchanged"
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
      section_key = row["Section Key"]
      question_key = row["Question Key"]
      answer_content = row["Answer #{lang_suffix}"] || ""

      # find or create section key
      if new_copy[section_key].blank?
        new_copy[section_key] = {
          "title" => row["Section Name #{lang_suffix}"]
        }
      end

      # assign unchanged or new content
      new_copy[section_key][question_key] =
        if row["Updated?"] == "No"
          "unchanged"
        else
          answer_content = answer_content.strip
          if answer_content.split("\n").length > 1 && !answer_content.include?("<p>")
            answer_content = answer_content.split("\n").map { |content| "<p>" + content.strip + "</p>\n" }.reject { |line| line == "<p></p>\n" }.join
          end
          {
            "question" => row["Question #{lang_suffix}"].strip,
            "answer_html" => answer_content
          }
        end
    end

    new_copy
  end
end
