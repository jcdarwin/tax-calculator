# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TaxCalculationController, type: :controller do
  render_views

  let!(:currency) { Currency.create!(code: 'NZD', name: 'New Zealand Dollar', symbol: '$', divisor: 100) }

  # Tax brackets as supplied
  let!(:bracket1) { TaxBracket.create!(currency: currency, lower_cents: 0,          upper_cents: 15_600_00,  rate: BigDecimal('0.105')) }
  let!(:bracket2) { TaxBracket.create!(currency: currency, lower_cents: 15_600_01,  upper_cents: 53_500_00,  rate: BigDecimal('0.175')) }
  let!(:bracket3) { TaxBracket.create!(currency: currency, lower_cents: 53_500_01,  upper_cents: 78_100_00,  rate: BigDecimal('0.30')) }
  let!(:bracket4) { TaxBracket.create!(currency: currency, lower_cents: 78_100_01,  upper_cents: 180_000_00, rate: BigDecimal('0.33')) }
  let!(:bracket5) { TaxBracket.create!(currency: currency, lower_cents: 180_000_01, upper_cents: nil,        rate: BigDecimal('0.39')) }

  # Expected progressive tax totals (dollars as strings):
  EXPECTED = {
    10_000 => '1050.00',
    35_000 => '5033.00',
    100_000 => '22877.50',
    220_000 => '64877.50'
  }.freeze

  def parsed
    JSON.parse(response.body)
  end

  describe 'GET show progressive tax totals' do
    EXPECTED.each do |income, expected_tax|
      it "returns total_tax #{expected_tax} for income #{income}" do
        get :show, params: { income: income }
        expect(response).to have_http_status(:ok)
        body = parsed
        expect(body['total_tax']).to eq(expected_tax)
      end
    end
  end

  describe 'validation errors' do
    it 'rejects missing income' do
      get :show
      expect(response).to have_http_status(:bad_request)
      expect(parsed['error']).to match(/Missing required/)
    end

    it 'rejects negative income' do
      get :show, params: { income: -1 }
      expect(response).to have_http_status(:bad_request)
      expect(parsed['error']).to match(/must not be negative/i)
    end

    it 'rejects invalid format' do
      get :show, params: { income: '12x.34' }
      expect(response).to have_http_status(:bad_request)
      expect(parsed['error']).to match(/Invalid income format/)
    end

    it 'rejects too many decimal places' do
      get :show, params: { income: '10.123' }
      expect(response).to have_http_status(:bad_request)
      expect(parsed['error']).to match(/Decimal places/)
    end

    it 'rejects unknown currency' do
      get :show, params: { income: 1000, currency: 'XXX' }
      expect(response).to have_http_status(:bad_request)
      expect(parsed['error']).to match(/Unknown currency/)
    end
  end
end
