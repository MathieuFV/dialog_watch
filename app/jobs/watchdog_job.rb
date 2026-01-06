class WatchdogJob < ApplicationJob
  queue_as :default

  def perform
    # Exécuter le service d'import des données
    RegulationsImporter.new.perform 

    # Mettre à jour le snapshot
    today = Time.zone.today
    snapshot = DailySnapshot.find_or_create_by!(date: today)

    snapshot.update!(
      total_organizations: Organization.count,
      total_regulations: Regulation.count,
      added_regulations: Regulation.where("created_at >= ?", today.beginning_of_day).count,
      updated_at: Time.current
    )
    
    puts "✅ Import et Snapshot terminés avec succès à #{Time.current}"
  end
end