class CountryList
  # Returns a list of countries with their details
  def self.all
    [
      { name: 'United States', code: 'US', dial_code: '+1' },
      { name: 'United Kingdom', code: 'GB', dial_code: '+44' },
      { name: 'India', code: 'IN', dial_code: '+91' },
      { name: 'Pakistan', code: 'PK', dial_code: '+92' },
      { name: 'Canada', code: 'CA', dial_code: '+1' },
      { name: 'Australia', code: 'AU', dial_code: '+61' },
      { name: 'Germany', code: 'DE', dial_code: '+49' },
      { name: 'France', code: 'FR', dial_code: '+33' },
      { name: 'Italy', code: 'IT', dial_code: '+39' },
      { name: 'Spain', code: 'ES', dial_code: '+34' },
      { name: 'Brazil', code: 'BR', dial_code: '+55' },
      { name: 'China', code: 'CN', dial_code: '+86' },
      { name: 'Japan', code: 'JP', dial_code: '+81' },
      { name: 'South Korea', code: 'KR', dial_code: '+82' },
      { name: 'Russia', code: 'RU', dial_code: '+7' },
      { name: 'Mexico', code: 'MX', dial_code: '+52' },
      { name: 'Indonesia', code: 'ID', dial_code: '+62' },
      { name: 'Nigeria', code: 'NG', dial_code: '+234' },
      { name: 'South Africa', code: 'ZA', dial_code: '+27' },
      { name: 'Saudi Arabia', code: 'SA', dial_code: '+966' },
      { name: 'United Arab Emirates', code: 'AE', dial_code: '+971' },
      { name: 'Turkey', code: 'TR', dial_code: '+90' },
      { name: 'Thailand', code: 'TH', dial_code: '+66' },
      { name: 'Malaysia', code: 'MY', dial_code: '+60' },
      { name: 'Singapore', code: 'SG', dial_code: '+65' },
      # Add more countries as needed
    ].sort_by { |country| country[:name] }
  end

  # Find a country by its code
  def self.find_by_code(code)
    all.find { |country| country[:code] == code }
  end

  # Find a country by its dial code
  def self.find_by_dial_code(dial_code)
    all.find { |country| country[:dial_code] == dial_code }
  end
end
