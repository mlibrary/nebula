# frozen_string_literal: true

require "digest"

# generates a deterministic pseudorandom mac address, using hostname as seed
#
# prefix validated to follow the following parameters:
#   - must contain exactly 6 hex digits
#   - second digit must be one of [2,6,a,e] (per RFC7042 §2.1, see "Local bit")
#   - case is ignored
#   - may contain unlimited number of non-alphanumerics as delimeters
#
# generated address contains
#   - 3 byte fixed OUI (prefix)
#   - 3 "random" byte (seeded from hostname)
#   - XOR with up to 3 bits (index) for additonal interfaces
Puppet::Functions.create_function(:generate_mac) do
  dispatch :generate_mac do
    param "String", :prefix
    param "String", :hostname
    optional_param "Integer", :index
  end

  def generate_mac(prefix, hostname, index = 0)
    unless index.between?(0, 7)
      raise(ArgumentError, "#{index} must be between 0 and 7, I can only generate 8 mac addresses per host!")
    end

    oui = prefix.downcase.gsub(/[^0-9a-z]/, "")
    unless /^[a-f0-9][26ae][a-f0-9]{4}$/.match?(oui)
      raise(ArgumentError, "invalid mac prefix!")
    end

    integer_id = Digest::SHA256.hexdigest(hostname)[0, 6].to_i(16) ^ index
    hex_id = sprintf("%06x", integer_id)
    "#{oui}#{hex_id}".each_char.each_slice(2).map { |x| x.join }.join(":")
  end
end
