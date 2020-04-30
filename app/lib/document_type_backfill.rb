# Backfills document type "2018 Tax Return" with "Prior Year Tax Return". This can be removed
# once it is run once in a production console.
#
# Usage (in rails console):
# > DocumentTypeBackfill.run
#

class DocumentTypeBackfill
  def self.print_output(message)
    puts(message) unless Rails.env.test?
  end

  def self.run
    print_output "~~~~~~~~~~~~ BEGIN BACKFILL ~~~~~~~~~~~~"

    Document.where(document_type: "2018 Tax Return").each do |document|
      print_output "---------- updating document: #{document.id}"
      document.update(document_type: "Prior Year Tax Return")
    end

    print_output "~~~~~~~~~~~~ COMPLETE BACKFILL ~~~~~~~~~~~~"
  end
end