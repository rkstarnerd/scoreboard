module DateHelpers
  DAYS_AFTER_SUNDAY = {
    'sunday' => 0, 'monday' => 1, 'tuesday' => 2, 'wednesday' => 3,
    'thursday' => 4, 'friday' => 5, 'saturday' => 6
  }.freeze

  def day
    Date.today.strftime("%A").downcase
  end

  def past_week
    from_sunday = Date.today - (7 + DAYS_AFTER_SUNDAY[day])
    to_saturday = from_sunday + DAYS_AFTER_SUNDAY['saturday']

    [from_sunday.to_time, to_saturday.to_time]
  end
end
