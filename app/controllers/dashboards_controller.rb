class DashboardsController < ApplicationController
  def index
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @is_today = @selected_date == Date.today
    @snapshot = DailySnapshot.find_by(date: @selected_date)

    # Limite pour le calcul historique : fin de la journée sélectionnée
    limit_date = @selected_date.to_time.end_of_day

    if @is_today
      @org_count = Organization.joins(:regulations).merge(Regulation.active).distinct.count
      @reg_count = Regulation.active.count
      @last_update = DailySnapshot.maximum(:updated_at)
    else
      @org_count = @snapshot&.total_organizations || 0
      @reg_count = @snapshot&.total_regulations || 0
      @last_update = @snapshot&.updated_at
    end

    # Calcul du top 5 des organisations contributrice pour la journée sélectionnée.
    query = Organization.joins(:regulations)
    if @is_today
      # On ne compte que les arrêtés actifs pour la date du jour
      query = query.merge(Regulation.active)
    else
      # Pour les jours antérieurs, on compte ceux qui étaient déjà connus à ce moment là et qui ont été vu à la date choisie
      query = query.where("regulations.created_at <= ?", @selected_date.end_of_day)
                  .where("regulations.last_seen_at >= ?", @selected_date.beginning_of_day)
    end

    @top_orgs = query.group(:id)
                    .select("organizations.*, COUNT(regulations.id) as regs_count")
                    .order("regs_count DESC")
                    .limit(5)

    @top_orgs_events = @snapshot&.snapshot_events
                                &.where(event_type: 'added')
                                &.group(:organization_id)
                                &.count
                                &.sort_by { |_id, count| -count }
                                &.first(5) || []
  end

  # Rafraîchissement manuel des données depuis l'interface
  def refresh_data
    # Le job Watchdog exécute le script d'import de données en arrière-plan
    WatchdogJob.perform_later
  
    # Informer l'utilisateur que l'import a démarré
    redirect_to root_path, notice: "La synchronisation a démarré en tâche de fond. Actualisez la page dans quelques instants."
  end
end