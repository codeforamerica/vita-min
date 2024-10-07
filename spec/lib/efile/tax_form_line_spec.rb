require 'rails_helper'

RSpec.describe Efile::TaxFormLine do
  describe ".line_data" do
    it "includes a label for every symbol used in a set_line call" do
      set_line_symbols = []
      source_files = Dir.glob(Rails.root.join('app', 'lib', 'efile', '**', '*.rb'))
      source_files.each do |path|
        content = File.read(path)
        content.scan(/set_line\(:(\w+)/).each do |match|
          set_line_symbols << match.first
        end
      end

      missing = set_line_symbols.map(&:to_s) - described_class.line_data.keys
      # add lines to line_data.yml if failing
      expect(missing).to eq([])
    end
  end
end
