class ZipCodeValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEX = /\A\d+\z/

  def initialize(options)
    @zip_code_lengths = options[:zip_code_lengths] || [5]
    super
  end

  def validate_each(record, attr_name, value)
    unless value =~ ZIP_CODE_REGEX && @zip_code_lengths.include?(value.length) && ZipCodes.has_key?(value[0,5])
      if @zip_code_lengths == [5]
        msg = "validators.zip"
      else
        msg = "validators.zip_code_with_optional_extra_digits"
      end
      record.errors.add(attr_name, I18n.t(msg))
    end
  end
end
