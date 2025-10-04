class CreateCurrencies < ActiveRecord::Migration[7.2]
  def change
    create_table :currencies do |t|
      t.string :code, null: false # ISO 4217 code, e.g. 'NZD'
      t.string :name, null: false
      t.string :symbol, null: false
      # We store currency amounts using the smallest unit (e.g. cents)
      # but then need to know how to convert to major unit (e.g. dollars).
      # divisor allows us to do this conversion.
      t.integer :divisor, null: false, default: 100

      t.timestamps
    end

    add_index :currencies, :code, unique: true
  end
end
