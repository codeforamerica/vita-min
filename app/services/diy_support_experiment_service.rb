class DiySupportExperimentService
  def self.taxslayer_link(treatment)
    case treatment
    when "high_support_1099"
      "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23062996"
    when "low_support_1099"
      "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=34067601"
    when "high_support_w2"
      "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23069434"
    when "low_support_w2"
      "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=21061019"
    end
  end
end