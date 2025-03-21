module StateFile
  module PatternMatchingHelper
    def contains_po_box(address)
      return false if address.blank?

      # Regex tested at https://regex101.com/r/4b22vr/1
      pattern = /(?i)p(?:[.\s]*)o(?:[.\s]*)(?:b(?:[.\s]*)(?:o(?:[.\s]*)x)?)?/
      address.match?(pattern)
    end
  end
end