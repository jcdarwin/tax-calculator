class Api::V1::TaxBracketsController < ApplicationController
  def index
    currency = find_currency_optional
    scope = TaxBracket.includes(:currency).ordered
    scope = scope.where(currency: currency) if currency
    render json: scope.as_json(
      include: { currency: { only: [ :code, :symbol ] } },
      only: [ :id, :lower_cents, :upper_cents, :rate ]
    )
  end

  private

  # Similar to show but index can return all currencies if none specified.
  # If a currency param is provided and unknown -> 400.
  def find_currency_optional
    return nil unless params.key?(:currency)
    code = params[:currency].to_s.strip
    return nil if code.blank?
    currency = Currency.find_by(code: code.upcase)
    unless currency
      render json: { error: "Unknown currency code", provided: code }, status: :bad_request
      return
    end
    currency
  end
end
