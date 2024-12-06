if Object.const_defined? :LetterOpener
  LetterOpener.configure do |config|
    config.file_uri_scheme = "file://"
  end
end
