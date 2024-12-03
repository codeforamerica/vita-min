module StateFile
  class DirectFileApiResponseSampleService
    def initialize
      @json_samples = {}
      @xml_samples = {}
      @submission_id_lookup = {
        'ny_rudy_v2' => '1016422024027ate001k',
        'ny_javier' => '1016422024018atw000x',
        'ny_matthew_v2' => '1016422024026atw001u',
        'ny_khaled' => '1016422024009at0000z',
        'ny_ivy_414h' => '1016422024025atw000h',
        'az_leslie_qss_v2' => '1016422024026atw001h',
        'az_donald_v2' => '1016422024027atw0020',
        'az_robin_v2' => '1016422024028ate001q',
        'az_superman_v2' => '1016422024025ate000b',
        'nc_nala_hoh' => '1016422024326jt6oz0h',
        'nc_mickey_mfj' => '1016422024327qqldslz',
        'nc_wylie_mfs' => '10164220243274vip4ag',
        'nc_zeus_mfjdeps' => '1016422024327ahu7xl7',
        'nc_daffy_single' => '1016422024327xmcxxwy',
        'md_annabelle_single' => '1016422024326lssbe1f',
        'nc_clara_hoh' => '10164220243303quinwv',
        'az_johnny_mfj' => '101642202433073zlynk',
        'az_alexis_hoh' => '10164220243273drvnwu',
        'az_shell_hoh' => '1016422024330uizbsmb',
        'az_Tycho_Single_No_1099R' => '1016422024332rjtkoti',
        'az_Tycho_Single_With_1099R' => '1016422024332hyykc8y',
        'az_Martha_MFJ_Owe' => '1016422024332t6d92qn',
        'az_Rory_claimed_as_dep' => '1016422024334wutmbb9',
        'id_Smith_Claimed_as_Dep' => '1016422024332a3erp1m',
        'id_Grey_no_1099r' => '1016422024337kkb3get',
        'id_Klein_QSS' => '1016422024338u5svhsa',
        'id_Estrada_donations' => '10164220243389yh9q72',
        'md_Hannah_Single' => '1016422024337p0czoxg',
        'md_Drum_MFS_over_1000' => '1016422024337uhx6vkg',
        'md_Leonard_QSS' => '1016422024337luaxoi5',
        'md_Anchovies_MFJ' => '1016422024337d6xqdk3',
        'md_Grace_Dependent' => '1016422024338z12fznh',
        'md_Felicity_Single' => '1016422024338g7n9hgr',
      }
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
      @submission_id_lookup[key] || '12345202201011234570'
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
        read_xml("az_tycho_loanded")
      when :married_filing_jointly
        read_xml("az_martha_v2")
      when :qualifying_widow
        read_xml("az_leslie_qss")
      when :married_filing_separately
        read_xml("az_sherlock_mfs")
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
        StateFile::StateInformationService.active_state_codes.each do |us_state|
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

