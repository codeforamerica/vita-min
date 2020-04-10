module States
  STATE_OPTIONS = [
    ["Alabama", "al"],
    ["Alaska", "ak"],
    ["Arizona", "az"],
    ["Arkansas", "ar"],
    ["California", "ca"],
    ["Colorado", "co"],
    ["Connecticut", "ct"],
    ["Delaware", "de"],
    ["District of Columbia", "dc"],
    ["Florida", "fl"],
    ["Georgia", "ga"],
    ["Hawaii", "hi"],
    ["Idaho", "id"],
    ["Illinois", "il"],
    ["Indiana", "in"],
    ["Iowa", "ia"],
    ["Kansas", "ks"],
    ["Kentucky", "ky"],
    ["Louisiana", "la"],
    ["Maine", "me"],
    ["Maryland", "md"],
    ["Massachusetts", "ma"],
    ["Michigan", "mi"],
    ["Minnesota", "mn"],
    ["Mississippi", "ms"],
    ["Missouri", "mo"],
    ["Montana", "mt"],
    ["Nebraska", "ne"],
    ["Nevada", "nv"],
    ["New Hampshire", "nh"],
    ["New Jersey", "nj"],
    ["New Mexico", "nm"],
    ["New York", "ny"],
    ["North Carolina", "nc"],
    ["North Dakota", "nd"],
    ["Ohio", "oh"],
    ["Oklahoma", "ok"],
    ["Oregon", "or"],
    ["Pennsylvania", "pa"],
    ["Rhode Island", "ri"],
    ["South Carolina", "sc"],
    ["South Dakota", "sd"],
    ["Tennessee", "tn"],
    ["Texas", "tx"],
    ["Utah", "ut"],
    ["Vermont", "vt"],
    ["Virginia", "va"],
    ["Washington", "wa"],
    ["West Virginia", "wv"],
    ["Wisconsin", "wi"],
    ["Wyoming", "wy"],
  ].freeze

  def self.hash
    STATE_OPTIONS.to_h.invert
  end

  def self.keys
    hash.keys
  end

  def self.name_for_key(key)
    self.hash[key]
  end

  def self.key_for_name(name)
    self.hash.key(name)
  end

  def self.name_value_pairs
    STATE_OPTIONS
  end
end
