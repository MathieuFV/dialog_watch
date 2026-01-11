class CleanHistorySnapshots < ActiveRecord::Migration[8.0]
  def up
    SnapshotEvent.delete_all
    DailySnapshot.delete_all
    Rails.logger.info "🧹 Historique nettoyé via migration."
  end

  def down
    # No restoration possible
  end
end
