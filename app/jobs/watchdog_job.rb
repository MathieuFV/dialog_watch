class WatchdogJob < ApplicationJob
  queue_as :default

  def perform
    # Initialisation des compteurs pour le snapshot du jour
    today = Date.today
    
    # On cherche ou on crée le snapshot pour aujourd'hui
    snapshot = DailySnapshot.find_or_create_by!(date: today)

    # Logique de calcul (ici on compte les organisations existantes)
    added_count = 0
    Organization.find_each do |org|     
      # Pour l'instant on simule l'ajout, 
      # plus tard ici on mettra la vraie logique de comparaison
      added_count += 1
    end

    # On prépare les données sans les enregistrer immédiatement
    snapshot.assign_attributes(
      total_organizations: Organization.count,
      total_regulations: Regulation.count,
      added_regulations: added_count
    )
    
    snapshot.update!(
      total_organizations: Organization.count,
      total_regulations: Regulation.count,
      updated_at: Time.current # On force l'heure ici aussi
    )
    
    puts "✅ Snapshot du #{today} mis à jour avec succès à #{Time.current}"
  end
end