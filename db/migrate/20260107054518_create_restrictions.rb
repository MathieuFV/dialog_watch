class CreateRestrictions < ActiveRecord::Migration[8.0]
  def change
    create_table :restrictions do |t|
      t.references :regulation, null: false, foreign_key: true
      t.string :restriction_type
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
