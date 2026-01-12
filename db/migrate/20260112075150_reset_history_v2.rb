class ResetHistoryV2 < ActiveRecord::Migration[8.0]
  def up
    SnapshotEvent.delete_all
    DailySnapshot.delete_all
    Rails.logger.info "🧹 Historique nettoyé (V2) suite au correctif de calcul."
  end

  def down
  end
end
