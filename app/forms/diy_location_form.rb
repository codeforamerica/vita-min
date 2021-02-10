class DiyLocationForm < DiyForm
  set_attributes_for :diy_intake, :zip_code

  validates :zip_code, zip_code: true
end
