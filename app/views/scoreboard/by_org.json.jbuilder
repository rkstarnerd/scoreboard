json.ignore_nil!
json.contributors @contributors
json.winner (@contributors.max_by { |hash| hash[:contributor][:total] }).keys.first
