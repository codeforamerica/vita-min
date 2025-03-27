module StateFile
  module PatternMatchingHelper
    def contains_po_box(address)
      return false if address.blank?

      # Regex tested at https://regex101.com/r/V64RgG/1
      pattern = /(?i)\bp(?:[.\s]*)o(?:[.\s]*)(?:b(?:[.\s]*)(?:o(?:[.\s]*)x)?)?\b/
      address.match?(pattern)
    end
  end
end