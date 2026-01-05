class CreateSnapshotEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :snapshot_events do |t|
      t.references :daily_snapshot, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.references :regulation, null: false, foreign_key: true
      t.string :event_type

      t.timestamps
    end
  end
end
