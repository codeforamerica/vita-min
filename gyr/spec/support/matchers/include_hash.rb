RSpec::Matchers.define :include_hash do |expected|
  match do |actual|
    # When trying to match a hash subset, "expect(actual).to include(expected)" gives a very messy
    # diff if 'foo' has a lot of stuff in it.

    # This matcher filters 'actual' to only contain the keys from 'expected' before comparing,
    # which will produce a much leaner diff
    @actual = @actual.select { |k,_v| expected.has_key?(k) }

    values_match?(expected, @actual)
  end

  diffable
end