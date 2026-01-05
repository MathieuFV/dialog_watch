class CreateRegulations < ActiveRecord::Migration[8.0]
  def change
    create_table :regulations do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :external_id
      t.string :regulation_type
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :last_seen_at

      t.timestamps
    end
    add_index :regulations, :external_id, unique: true
  end
end
