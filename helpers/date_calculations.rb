module DateCalculations
  def age_in_years from_date
    today = Date.today
    age   = today.year - from_date.year

    age -= 1 if today.month < from_date.month
    age -= 1 if today.month == from_date.month && today.mday < from_date.mday

    age
  end
end
