module ApplicationHelper
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge :renderer => VitaMinLinkRenderer
    end
    super *[collection_or_options, options].compact
  end

  def round_meters_up_to_5_mi(meters)
    five_miles_in_meters = 8046.72
    (meters / five_miles_in_meters).ceil * 5
  end

  def you_or_spouse(intake)
    return "you or your spouse" if intake.filing_joint_yes?

    "you"
  end
end
