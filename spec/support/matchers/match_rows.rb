RSpec::Matchers.define :match_rows do |expected|
  match do |actual|
    columns_to_check = expected.map(&:keys).flatten.uniq
    @actual = actual.map do |row|
      row.select do |column_name, _value|
        columns_to_check.include?(column_name)
      end
    end

    # Note that this cares about order, if we want order-insensitive matching
    # we have to mimic more of what's happening in the built-in ContainExactly module
    values_match?(expected, @actual)
  end

  diffable
end