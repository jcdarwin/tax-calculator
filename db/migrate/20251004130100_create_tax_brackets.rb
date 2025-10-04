class CreateTaxBrackets < ActiveRecord::Migration[7.2]
  def change
    create_table :tax_brackets do |t|
      t.references :currency, null: false, foreign_key: true
      # We store currency amounts in the smallest whole unit (e.g. cents, pence)
      t.integer :lower_cents, null: false
      t.integer :upper_cents, null: true
      t.decimal :rate, precision: 7, scale: 6, null: false # allows rates like 0.395000

      t.timestamps
    end

    add_index :tax_brackets, [ :currency_id, :lower_cents ], unique: true, name: 'idx_tax_brackets_currency_lower'
  end
end
