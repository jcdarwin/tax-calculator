class TaxBracket < ApplicationRecord
  belongs_to :currency

  validates :lower_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :rate, presence: true, numericality: { greater_than: 0 }
  # Note: a nil upper_cents means 'and over'
  validate :upper_greater_than_lower

  scope :ordered, -> { order(:lower_cents) }

  # Returns a human label for the tax bracket.
  def bracket_label(thousands_delimiter: ",")
    lower = format_amount(lower_cents, thousands_delimiter: thousands_delimiter)
    if upper_cents
      upper = format_amount(upper_cents, thousands_delimiter: thousands_delimiter)
      "#{lower} - #{upper}"
    else
      "#{lower} and over"
    end
  end

  private

  def upper_greater_than_lower
    # Note: we have a validation on lower_cents presence elsewhere, so this is safe
    return if upper_cents.nil? || lower_cents.nil?
    errors.add(:upper_cents, "must be greater than lower_cents") if upper_cents <= lower_cents
  end

  def format_amount(cents, thousands_delimiter: ",")
    amount = cents / currency.divisor
    formatted = amount.to_s.reverse.gsub(/\d{3}(?=\d)/, "\\&#{thousands_delimiter}").reverse

    "#{currency.symbol}#{formatted}"
  end
end
