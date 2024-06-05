module StateFile
  class XmlReturnSampleService
    def initialize
      @_samples = []
      @_sample_lookup = {}
      @_submission_id_lookup = {
        rudy_v2_ny: '1016422024027ate001k',
        javier_ny: '1016422024018atw000x',
        matthew_v2_ny: '1016422024026atw001u',
        khaled_ny: '1016422024009at0000z',
        ivy_414h_ny: '1016422024025atw000h',
        leslie_qss_v2_az: '1016422024026atw001h',
        donald_v2_az: '1016422024027atw0020',
        robin_v2_az: '1016422024028ate001q',
        superman_v2_az: '1016422024025ate000b'
      }
    end

    def samples
      load_samples
      @_samples
    end

    def lookup(key)
      load_samples
      @_sample_lookup[key]
    end

    def lookup_submission_id(key)
      @_submission_id_lookup[key.to_sym] || '12345202201011234570'
    end

    def read(key)
      lookup(key).read
    end

    def old_sample
      lookup("abcdefg").read
    end

    private

    def load_samples
      return if @_samples.present?

      Dir.glob("spec/fixtures/**/fed_return_*.xml").each do |path|
        sample = SampleXml.new(path)
        @_samples.push(sample)
        @_sample_lookup[sample.key] = sample
      end

      old_sample = SampleXml.new(
        "app/controllers/state_file/questions/df_return_sample.xml",
        key: "abcdefg",
        label: "NY Old Sample"
      )
      @_sample_lookup[old_sample.key] = old_sample
    end

    class SampleXml
      attr_accessor :path, :key, :label

      def initialize(path, key: nil, label: nil)
        @path = path
        @key = key || path.gsub("spec/fixtures/files/fed_return_", "").gsub(".xml", "")
        if label
          @label = label
        else
          words = @key.humanize.split(" ")
          state = words.pop.upcase
          @label = ([state] + words).join(" ")
        end
      end

      def read
        File.read(@path)
      end
    end
  end
end

