class MigrateStatuses
  STATUS_UPDATE_MAP = {
      201 => 104,
      104 => 105,
      106 => 201,
      202 => 203,
      203 => 202,
      204 => 301,
      301 => 302,
      302 => 304,
      303 => 305,
      401 => 406,
      402 => 401,
      502 => 402,
      503 => 403,
      504 => 404,
      505 => 405
  }.freeze

  def self.migrate_all
    TaxReturn.where(status: STATUS_UPDATE_MAP.keys).find_each(batch_size: 100) do |tax_return|
      new_status = STATUS_UPDATE_MAP[tax_return.read_attribute_before_type_cast(:status)]
      tax_return.update(status: new_status)
    end
  end
end