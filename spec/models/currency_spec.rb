# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Currency, type: :model do
  subject(:currency) { described_class.new(code: 'NZD', name: 'New Zealand Dollar', symbol: '$', divisor: 100) }

  describe 'validations' do
    it 'is valid with the default attributes' do
      expect(currency).to be_valid
    end

    it 'requires a code' do
      currency.code = nil
      expect(currency).not_to be_valid
      expect(currency.errors[:code]).to be_present
    end

    it 'enforces a unique code' do
      currency.save!
      dup = described_class.new(code: 'NZD', name: 'Something', symbol: '$', divisor: 100)
      expect(dup).not_to be_valid
      expect(dup.errors[:code]).to include('has already been taken')
    end

    it 'requires a symbol' do
      currency.symbol = nil
      expect(currency).not_to be_valid
      expect(currency.errors[:symbol]).to be_present
    end

    it 'requires a divisor greater than 0' do
      currency.divisor = 0
      expect(currency).not_to be_valid
      currency.divisor = -10
      expect(currency).not_to be_valid
    end

    describe 'divisor power-of-ten validation' do
      it 'is valid when divisor is a power of ten' do
        c = described_class.new(code: 'NZD', name: 'Bad Divisor', symbol: '$', divisor: 100)
        expect(c).to be_valid
      end

      it 'is invalid when divisor is not a power of ten' do
        c = described_class.new(code: 'NZD', name: 'Bad Divisor', symbol: '$', divisor: 12)
        expect(c).not_to be_valid
        expect(c.errors[:divisor]).to include(/power of 10/)
      end
    end
  end

  describe 'associations' do
    it 'restricts deletion when tax brackets exist' do
      currency.save!
      currency.tax_brackets.create!(lower_cents: 0, upper_cents: 1000, rate: 0.1)
      expect { currency.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe '#decimal_places' do
    it 'returns 0 for divisor 1' do
      c = described_class.new(code: 'NZD', name: 'Zero Decimals', symbol: '$', divisor: 1)
      expect(c.decimal_places).to eq(0)
    end

    it 'returns 1 for divisor 10' do
      c = described_class.new(code: 'NZD', name: 'One Decimal', symbol: '$', divisor: 10)
      expect(c.decimal_places).to eq(1)
    end

    it 'returns 2 for divisor 100' do
      c = described_class.new(code: 'NZD', name: 'Two Decimals', symbol: '$', divisor: 100)
      expect(c.decimal_places).to eq(2)
    end

    it 'returns 3 for divisor 1000' do
      c = described_class.new(code: 'NZD', name: 'Three Decimals', symbol: '$', divisor: 1000)
      expect(c.decimal_places).to eq(3)
    end
  end
end
