class Currency < ApplicationRecord
  has_many :tax_brackets, dependent: :restrict_with_exception, inverse_of: :currency

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :symbol, presence: true
  validates :divisor, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :divisor_is_power_of_ten

  # Number of decimal places represented by the divisor.
  # Assumes divisor is a power of ten.
  def decimal_places
    # Math.log10 returns a float; for exact powers of ten it is integral.
    Math.log10(divisor).to_i
  end

  private

  def divisor_is_power_of_ten
    return if divisor.blank? || !divisor.is_a?(Numeric)
    log = Math.log10(divisor) rescue nil
    unless log && log % 1 == 0
      errors.add(:divisor, "must be a power of 10 (e.g., 1, 10, 100, 1000)")
    end
  end
end
