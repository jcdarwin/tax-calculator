class Api::V1::TaxCalculationController < ApplicationController
  # GET /api/v1/tax_bracket?income=15600.50
  def show
    income_param = params[:income]
    unless income_param.present?
      return render json: { error: "Missing required parameter 'income'" }, status: :bad_request
    end

    begin
      income = BigDecimal(income_param.to_s)
    rescue ArgumentError
      return render json: { error: "Invalid income format" }, status: :bad_request
    end

    if income.negative?
      return render json: { error: "Income must not be negative" }, status: :bad_request
    end

    code = find_currency_code
    unless code
      return render json: { error: "Invalid currency code: #{code}" }, status: :bad_request
    end

    currency = find_currency(code)
    unless currency
      return render json: { error: "Unknown currency code: #{code}" }, status: :bad_request
    end

    # Reject if user supplies more fractional digits than currency supports.
    decimal_places_allowed = currency.decimal_places
    decimal_places_actual = determine_decimal_places(income)
    if decimal_places_actual > decimal_places_allowed
      return render json: { error: "Decimal places (#{decimal_places_actual}) greater than allowed (#{decimal_places_allowed})" }, status: :bad_request
    end

    # We perform our calculations in cents to avoid floating point / rounding issues.
    income_cents = (income * currency.divisor).to_i

    brackets = TaxBracket.where(currency: currency).order(:lower_cents)

    if brackets.empty?
      return render json: { error: "No brackets found for currency #{currency.code}" }, status: :not_found
    end

    # Calculate the tax across all brackets up to the provided income.
    total_tax_cents = 0
    breakdown = []

    brackets.each do |bracket|
      tax_cents_for_bracket = calculate_bracket_tax_cents(income_cents, bracket)
      tax_for_bracket = format_amount(tax_cents_for_bracket, currency)
      total_tax_cents += tax_cents_for_bracket

      breakdown << {
        bracket_id: bracket.id,
        lower_cents: bracket.lower_cents,
        upper_cents: bracket.upper_cents,
        rate: bracket.rate.to_s,
        tax: tax_for_bracket
      }
    end

    render json: {
      income: income_param,
      total_tax: format_amount(total_tax_cents, currency),
      breakdown: breakdown,
      currency: { code: currency.code, symbol: currency.symbol }
    }
  end

  private

  def find_currency(code)
    Currency.find_by(code: code.upcase)
  end

  # Note: Defaults to NZD.
  def find_currency_code
    code = params[:currency].presence || "NZD"

    return nil if code.blank?

    code.upcase
  end

  def determine_decimal_places(income)
    return 0 if income.frac.abs.zero?

    income.to_s.split(".").last&.size.to_i
  end

  def calculate_bracket_tax_cents(income_cents, bracket)
    upper_cents = bracket.upper_cents || income_cents
    bracket_highwater_cents = [ income_cents, upper_cents ].min
    income_cents_in_bracket = bracket_highwater_cents - bracket.lower_cents
    return 0 if income_cents_in_bracket <= 0

    (BigDecimal(income_cents_in_bracket.to_s) * bracket.rate)
      .round(0, BigDecimal::ROUND_HALF_UP)
      .to_i
  end

  def format_amount(cents, currency)
    amount = BigDecimal(cents.to_s) / currency.divisor
    format("%0.#{currency.decimal_places}f", amount)
  end
end
