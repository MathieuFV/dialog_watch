class WatchdogJob < ApplicationJob
  queue_as :default

  def perform
    # 1. On lance le VRAI script d'import
    RegulationsImporter.new.perform 

    # 2. Une fois fini, on s'occupe du Snapshot
    today = Time.zone.today
    snapshot = DailySnapshot.find_or_create_by!(date: today)

    # 3. Mise à jour des indicateurs réels
    snapshot.update!(
      total_organizations: Organization.count,
      total_regulations: Regulation.count,
      # Optionnel : compter les nouveautés du jour
      added_regulations: Regulation.where("created_at >= ?", today.beginning_of_day).count,
      updated_at: Time.current
    )
    
    puts "✅ Import et Snapshot terminés avec succès à #{Time.current}"
  end
end