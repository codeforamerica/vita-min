class DirectFileJsonData

  def initialize(json)
    @json = JSON.parse(json)
  end

  def primary_filer
    @json['filers']&.detect { |filer| filer['isPrimaryFiler'] }
  end

  def primary_first_name
    primary_filer ? primary_filer['firstName'] : nil
  end
end