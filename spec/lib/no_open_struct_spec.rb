require "rails_helper"

# The ostruct gem is not in the Gemfile (it stopped being a default gem in Ruby 4.0).
# OpenStruct is only referenced inside method bodies, so neither eager loading nor
# bin/check_production_boot would notice it coming back: it would fail at runtime in
# production with NameError. Use Struct or Data instead.
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
