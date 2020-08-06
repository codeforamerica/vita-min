class DocumentPresenter < BasePresenter
  COMMON_TYPES =
    %w{
      image/jpeg
      application/pdf
      image/png
      image/heic
      image/bmp
      text/plain
      image/tiff
      text/csv
      image/gif
    }

  def self.grouped_documents(intakes)
    Document
      .where(intake: intakes)
      .order(:created_at)
      .group_by(&:document_type)
      .sort_by(&:first)
      .each_with_object({}) do |(doc_type, documents), groups|
        groups[doc_type] = wrap_collection(documents)
      end
  end

  def uploaded_ago
    "#{h.time_ago_in_words(created_at)} ago"
  end

  def notes
    [uncommon_file_type, large_file_size].compact.join(", ")
  end

  private

  def uncommon_file_type
    "Uncommon File Type" if COMMON_TYPES.exclude?(content_type)
  end

  def large_file_size
    "Large file size" if byte_size > 20 * 1_000_000
  end

  def content_type
    upload.content_type
  end

  def byte_size
    upload.byte_size
  end
end
