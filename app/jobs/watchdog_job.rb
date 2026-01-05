class WatchdogJob < ApplicationJob
  queue_as :default

  def perform
    # Initialisation des compteurs pour le snapshot du jour
    today = Date.today
    added_count = 0
    
    # On crée le snapshot parent pour la date d'aujourd'hui
    snapshot = DailySnapshot.find_or_create_by!(date: today)

    Organization.find_each do |org|     
      added_count += 1
    end

    # Mise à jour des totaux du snapshot
    snapshot.update!(
      total_organizations: Organization.count,
      total_regulations: Regulation.count,
      added_regulations: added_count
    )
    
    puts "✅ Snapshot du #{today} terminé avec succès !"
  end
end