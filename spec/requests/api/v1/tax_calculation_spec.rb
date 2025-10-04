# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /api/v1/tax_calculation', type: :request do
  let!(:currency) { Currency.create!(code: 'NZD', name: 'New Zealand Dollar', symbol: '$', divisor: 100) }

  # Current NZ tax brackets as at 4 October 2025
  # Refer: https://www.ird.govt.nz/income-tax/income-tax-for-individuals/tax-codes-and-tax-rates-for-individuals/tax-rates-for-individuals
  let!(:bracket1) { TaxBracket.create!(currency: currency, lower_cents: 0,         upper_cents: 1_560_000, rate: BigDecimal('0.105')) }
  let!(:bracket2) { TaxBracket.create!(currency: currency, lower_cents: 1_560_001, upper_cents: 5_350_000, rate: BigDecimal('0.175')) }
  let!(:bracket3) { TaxBracket.create!(currency: currency, lower_cents: 5_350_001, upper_cents: 7_810_000, rate: BigDecimal('0.30')) }
  let!(:bracket4) { TaxBracket.create!(currency: currency, lower_cents: 7_810_001, upper_cents: 18_000_000, rate: BigDecimal('0.33')) }
  let!(:bracket5) { TaxBracket.create!(currency: currency, lower_cents: 18_000_001, upper_cents: nil,       rate: BigDecimal('0.39')) }

  def json_body
    JSON.parse(response.body)
  end

  context 'happy path' do
    it 'returns correct tax for income within first bracket' do
      get '/api/v1/tax_calculation', params: { income: 10000 }
      expect(response).to have_http_status(:ok)
      body = json_body
      expect(body['income']).to eq('10000')
      # 10,000 * 10.5% = 1,050.00
      expect(body['total_tax']).to eq('1050.00')
      expect(body['currency']['code']).to eq('NZD')
    end

    it 'returns correct tax for income within last bracket' do
      get '/api/v1/tax_calculation', params: { income: 220000 }
      expect(response).to have_http_status(:ok)
      body = json_body
      expect(body['income']).to eq('220000')
      # 15600 * 10.5% = 1,638.00
      # (53500 - 15600) * 17.5% = 6,632.50
      # (78100 - 53500) * 30% = 7,380.00
      # (180000 - 78100) * 33% = 34,377.00
      # (220000 - 180000) * 39% = 15,600.00
      # Total tax = 1,638 + 6,632.50 + 7,380 + 34,377 + 15,600 = 64,877.50
      expect(body['total_tax']).to eq('64877.50')
      expect(body['currency']['code']).to eq('NZD')
    end

    it 'returns correct tax at upper bound of first bracket (15,600)' do
      get '/api/v1/tax_calculation', params: { income: 15_600 }
      expect(response).to have_http_status(:ok)
      body = json_body
      # 15,600 * 10.5% = 1,638.00
      expect(body['total_tax']).to eq('1638.00')
    end

    it 'returns correct tax just into second bracket (15,600.01)' do
      get '/api/v1/tax_calculation', params: { income: 15_600.01 }
      expect(response).to have_http_status(:ok)
      body = json_body
      # 15,600 * 10.5% = 1,638.00
      # $0.01 at 17.5% ~= 0.00175 -> rounds to 0.00
      expect(body['total_tax']).to eq('1638.00')
    end
  end

  context 'validation errors' do
    it 'rejects missing income' do
      get '/api/v1/tax_calculation'
      expect(response).to have_http_status(:bad_request)
      expect(json_body['error']).to eq("Missing required parameter 'income'")
    end

    it 'rejects negative income' do
      get '/api/v1/tax_calculation', params: { income: -10 }
      expect(response).to have_http_status(:bad_request)
      expect(json_body['error']).to eq("Income must not be negative")
    end

    it 'rejects invalid format' do
      get '/api/v1/tax_calculation', params: { income: '12x.34' }
      expect(response).to have_http_status(:bad_request)
      expect(json_body['error']).to eq("Invalid income format")
    end

    it 'rejects too many decimal places' do
      get '/api/v1/tax_calculation', params: { income: '10.123' }
      expect(response).to have_http_status(:bad_request)
      expect(json_body['error']).to eq("Decimal places (3) greater than allowed (2)")
    end

    it 'rejects unknown currency' do
      get '/api/v1/tax_calculation', params: { income: 1000, currency: 'XXX' }
      expect(response).to have_http_status(:bad_request)
      expect(json_body['error']).to eq("Unknown currency code: XXX")
    end
  end
end
