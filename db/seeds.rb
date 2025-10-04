NZD = 'NZD'.freeze
NZD_SYMBOL = '$'.freeze
NZD_NAME = 'New Zealand Dollar'.freeze

# --- Currency Seed Data ---
# Only seeding NZD for now.
# We can add further currencies when we need to support other jurisdictions.
currencies = [
  { code: NZD, name: NZD_NAME, symbol: NZD_SYMBOL, divisor: 100 }
]

currencies.each do |c|
  currency = Currency.find_or_initialize_by(code: c[:code])

  currency.assign_attributes(
    name: c[:name],
    symbol: c[:symbol],
    divisor: c[:divisor]
  )

  currency.save! if currency.changed?
end

# --- Tax Brackets Seed Data ---
# Amounts are stored internally in the smallest whole unit (e.g. cents, pence)
# as integers so we can avoid floating point issues.
# Rates are stored as decimal fractions (e.g. 10.5% => 0.105)

tax_brackets = [
  { lower_cents: 0,
    upper_cents: 15_600_00, # $15,600
    rate: 0.105
  },
  { lower_cents: 15_601_00, # $15,601
    upper_cents: 53_500_00, # $53,500
    rate: 0.175
  },
  { lower_cents: 53_501_00, # $53,501
    upper_cents: 78_100_00, # $78,100
    rate: 0.30
  },
  { lower_cents: 78_101_00, # $78,101
    upper_cents: 180_000_00, # $180,000
    rate: 0.33
  },
  { lower_cents: 180_001_00, # $180,001
    upper_cents: nil,
    rate: 0.39
  }
]

currency = Currency.find_by!(code: NZD)

tax_brackets.each do |tb|
  rate = tb[:rate].to_d

  bracket = TaxBracket.find_or_initialize_by(
    currency: currency,
    lower_cents: tb[:lower_cents]
  )

  bracket.assign_attributes(
    upper_cents: tb[:upper_cents],
    rate: rate
  )

  bracket.save! if bracket.changed?
end

puts "Seeded #{TaxBracket.count} tax brackets" if defined?(Rails::Console)
