class CreateDailySnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_snapshots do |t|
      t.date :date
      t.integer :total_organizations
      t.integer :total_regulations
      t.integer :added_regulations
      t.integer :removed_regulations

      t.timestamps
    end
  end
end
