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

    # Nouveau calcul unifié du Top 5 pour la date sélectionnée
    @top_orgs = Organization.joins(:regulations)
                            .where("regulations.created_at <= ?", limit_date)
                            .group(:id)
                            .select("organizations.*, COUNT(regulations.id) as regs_count")
                            .order("regs_count DESC")
                            .limit(5)

    # On conserve les événements spécifiques au snapshot si besoin
    @top_orgs_events = @snapshot&.snapshot_events
                                &.where(event_type: 'added')
                                &.group(:organization_id)
                                &.count
                                &.sort_by { |_id, count| -count }
                                &.first(5) || []
  end

  # Rafraîchissement manuel des données depuis l'interface
  def refresh_data
    # Exécuter le script d'import via le job (en arrière-plan)
    WatchdogJob.perform_now 
  
    # Rafraîchir la page après la fin de l'import 
    redirect_to root_path, status: :see_other
  end
end