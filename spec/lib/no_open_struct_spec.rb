require "rails_helper"

# Our code must not use OpenStruct: it stopped being a default gem in Ruby 4.0, and the
# ostruct gem stays in the Gemfile only for cfa-styleguide until honeycrisp-gem drops it.
# Keeping our side clean means removing the gem later needs no app changes. Use Struct
# or Data instead.
describe "OpenStruct usage" do
  it "does not appear in app/, lib/ or config/" do
    offenders = Dir[Rails.root.join("{app,lib,config}/**/*.{rb,erb,rake}")].flat_map do |path|
      File.foreach(path).with_index(1).filter_map do |line, number|
        "#{Pathname(path).relative_path_from(Rails.root)}:#{number}" if line.match?(/\bOpenStruct\b|require ["']ostruct["']/)
      end
    end

    expect(offenders).to be_empty, "Replace OpenStruct with Struct/Data in:\n#{offenders.join("\n")}"
  end
end
