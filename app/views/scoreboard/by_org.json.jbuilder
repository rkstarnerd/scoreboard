json.ignore_nil!
json.contributors @contributors
json.winner (@contributors.max_by { |hash| hash.values[0][:total] }).keys.join
