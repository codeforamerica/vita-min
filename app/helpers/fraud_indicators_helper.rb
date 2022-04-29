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
    table = fraud_indicator.list_model_name.split("::").last.downcase
    
    if respond_to?("hub_#{type}_#{table}s_path")
      link_to send("hub_#{type}_#{table}s_path") do
        content_tag :i, "list_alt", class: "icon-"
      end
    end
  end
end
