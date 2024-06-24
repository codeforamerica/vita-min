module StateFile
  class Constants
    def self.import(filename)
      # To compute this JSON, copy the JS function (call it f) that generates it into a Chrome console, then run
      # console.log(JSON.stringify(f()))
      # then copy to the desired file.
      self.counties = JSON.parse(File.read(filename))
    end

    class_attribute :counties
  end
end
