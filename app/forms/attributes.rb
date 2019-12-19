class Attributes
  def initialize(attribute_names)
    @attribute_names = attribute_names
  end

  def to_s
    symbols_or_hash_keys.flatten.map(&:to_s)
  end

  def to_sym
    symbols_or_hash_keys.flatten.map(&:to_sym)
  end

  def hash_key?(attribute)
    hashes = attribute_names.select do |attr|
      attr.is_a? Hash
    end

    hashes.map(&:keys).flatten.include? attribute.to_sym
  end

  private

  attr_reader :attribute_names

  def symbols_or_hash_keys
    return [] if attribute_names.nil?

    attribute_names.map do |attr|
      if attr.class == Symbol
        attr
      else
        attr.keys
      end
    end
  end
end
