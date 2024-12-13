module StateFile
  class DirectFileApiResponseSampleService
    cattr_accessor :submission_id_lookup
    self.submission_id_lookup = YAML.safe_load_file("#{__dir__}/submission_id_lookup.yml")

    def initialize
      @json_samples = {}
      @xml_samples = {}
      @old_xml_sample = "app/controllers/state_file/questions/df_return_sample.xml"
      @old_json_sample = "app/controllers/state_file/questions/df_return_sample.json"
    end

    def xml_samples
      load_samples
      @xml_samples
    end

    def self.key(us_state, sample_name)
      "#{us_state}_#{sample_name}"
    end

    def self.label(sample_name)
      sample_name.humanize
    end

    def lookup_submission_id(key)
      submission_id_lookup[key] || '12345202201011234570'
    end

    def include?(key, file_type)
      path(key, file_type).present?
    end

    def read_json(key)
      JSON.parse(File.read(path(key, 'json'))) if include?(key, 'json')
    end

    def read_xml(key)
      File.read(path(key, 'xml')) if include?(key, 'xml')
    end

    def old_xml_sample
      read_xml("abcdefg")
    end

    def old_json_sample
      read_json("abcdefg")
    end

    def az_xml_sample(filing_status)
      case filing_status.to_sym
      when :single
        read_xml("az_tycho_single_no_1099r")
      when :married_filing_jointly
        read_xml("az_martha_v2")
      when :qualifying_widow
        read_xml("az_leslie_qss")
      when :married_filing_separately
        read_xml("nc_wylie_mfs")
      when :head_of_household
        read_xml("az_alexis_hoh")
      end
    end

    private

    def base_path(file_type)
      "spec/fixtures/state_file/fed_return_#{file_type}s/".freeze
    end

    def read(key, file_type)
      File.read(path(key, file_type)) if include?(key, file_type)
    end

    def load_samples
      return if @xml_samples.present? && @json_samples.present?

      %w[json xml].each do |file_type|
        samples = file_type == 'json' ? @json_samples : @xml_samples
        (StateFile::StateInformationService.active_state_codes + ["test"]).each do |us_state|
          samples[us_state] = []
          file_path_glob = File.join(base_path(file_type), us_state, "*.#{file_type}")
          Dir.glob(file_path_glob).each do |file_path|
            samples[us_state].push(File.basename(file_path, ".#{file_type}"))
          end
        end
      end
    end

    def path(key, file_type)
      load_samples

      old_sample = file_type == 'json' ? @old_json_sample : @old_xml_sample
      return old_sample if key == 'abcdefg'

      samples = file_type == 'json' ? @json_samples : @xml_samples

      us_state, sample_name = key.split("_", 2)
      if samples.include?(us_state) && samples[us_state].include?(sample_name)
        File.join(base_path(file_type), us_state, "#{sample_name}.#{file_type}")
      end
    end
  end
end

