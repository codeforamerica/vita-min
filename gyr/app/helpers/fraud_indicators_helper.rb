module FraudIndicatorsHelper
  def link_to_indicator_list(fraud_indicator)
    return nil if fraud_indicator.list_model_name.nil?

    type = case fraud_indicator.indicator_type
           when "not_in_safelist"
             "safe"
           when "in_riskylist"
             "risky"
           else
             return nil
           end
    table = fraud_indicator.list_model_name.split("::").last.tableize
    path_with_type = "hub_#{type}_#{table}_path"
    path_without_type = "hub_#{table}_path"

    matching_path = nil
    matching_path = path_with_type if respond_to?(path_with_type)
    matching_path = path_without_type if respond_to?(path_without_type)

    link_to send(matching_path) do
      content_tag :i, "list_alt", class: "icon-"
    end if matching_path
  end

  def to_id_name(string)
    return "" unless string.present?
    if string.scan(/\D/).empty?
      return "id-#{string}"
    end

    string.downcase.gsub("/", "-").split(".")[0]
  end
end
