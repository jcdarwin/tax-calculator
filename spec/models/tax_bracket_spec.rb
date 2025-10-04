# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaxBracket, type: :model do
  let(:currency) { Currency.create!(code: 'NZD', name: 'New Zealand Dollar', symbol: '$', divisor: 100) }

  describe 'validations' do
    it 'is valid with required attributes' do
      bracket = described_class.new(currency: currency, lower_cents: 0, upper_cents: 100_00, rate: 0.10)
      expect(bracket).to be_valid
    end

    it 'requires lower_cents' do
      bracket = described_class.new(currency: currency, upper_cents: 100_00, rate: 0.10)
      expect(bracket).not_to be_valid
      expect(bracket.errors[:lower_cents]).to be_present
    end

    it 'requires a positive rate' do
      bracket = described_class.new(currency: currency, lower_cents: 0, upper_cents: 100_00, rate: 0)
      expect(bracket).not_to be_valid
      bracket.rate = -0.1
      bracket.validate
      expect(bracket.errors[:rate]).to be_present
    end

    it 'validates upper_cents greater than lower_cents when present' do
      bracket = described_class.new(currency: currency, lower_cents: 100_00, upper_cents: 50_00, rate: 0.10)
      expect(bracket).not_to be_valid
      expect(bracket.errors[:upper_cents]).to be_present
    end

    it 'allows nil upper_cents (i.e. upper_cents means "and over")' do
      bracket = described_class.new(currency: currency, lower_cents: 100_00, upper_cents: nil, rate: 0.10)
      expect(bracket).to be_valid
    end
  end

  describe 'scopes' do
    it 'orders by lower_cents ascending' do
      bracket3 = described_class.create!(currency: currency, lower_cents: 300_00, upper_cents: 399_99, rate: 0.30)
      bracket1 = described_class.create!(currency: currency, lower_cents: 100_00, upper_cents: 199_99, rate: 0.10)
      bracket2 = described_class.create!(currency: currency, lower_cents: 200_00, upper_cents: 299_99, rate: 0.20)
      expect(described_class.ordered).to eq [ bracket1, bracket2, bracket3 ]
    end
  end

  describe '#bracket_label' do
    it 'formats closed range with delimiter' do
      bracket = described_class.create!(currency: currency, lower_cents: 15_600_00, upper_cents: 53_500_00, rate: 0.175)
      expect(bracket.bracket_label).to eq '$15,600 - $53,500'
    end

    it 'formats open ended range' do
      bracket = described_class.create!(currency: currency, lower_cents: 180_000_00, upper_cents: nil, rate: 0.39)
      expect(bracket.bracket_label).to eq '$180,000 and over'
    end
  end

  describe 'uniqueness on (currency, lower_cents)' do
    it 'prevents duplicate lower_cents for same currency' do
      described_class.create!(currency: currency, lower_cents: 10_000_00, upper_cents: 20_000_00, rate: 0.10)
      dup = described_class.new(currency: currency, lower_cents: 10_000_00, upper_cents: 25_000_00, rate: 0.15)
      expect { dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
