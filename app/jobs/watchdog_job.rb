class WatchdogJob < ApplicationJob
  queue_as :default

  def perform
    today = Time.zone.today
    
    # On initialise le snapshot en début de traitement
    snapshot = DailySnapshot.find_or_create_by!(date: today)

    # Exécuter le service d'import en lui passant le snapshot pour l'historisation
    RegulationsImporter.new(daily_snapshot: snapshot).perform 

    # Mettre à jour les compteurs du snapshot
    snapshot.update!(
      total_organizations: Organization.joins(:regulations).merge(Regulation.active).distinct.count,
      total_regulations: Regulation.active.count,
      added_regulations: snapshot.snapshot_events.where(event_type: 'added').count,
      removed_regulations: snapshot.snapshot_events.where(event_type: 'removed').count,
      updated_at: Time.current
    )
    
    puts "✅ Import et Snapshot terminés avec succès à #{Time.current}"
  end
end