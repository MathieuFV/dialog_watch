class DashboardsController < ApplicationController
  def index
    # Gestion du sélecteur de date
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @is_today = @selected_date == Date.today

    # Pour la date sélectionnée, récupérer le snapshot de la base de données de ce jour là
    @snapshot = DailySnapshot.find_by(date: @selected_date)

    # Calcul des indicateurs du dashboard pour le snapshot séléctionné
    if @is_today
      # Si on reste sur la date du jour, les dernières données sont stockées dans la base de données
      # 'chaude', on peut donc utiliser les fonctions natives pour faire les calculs (count, maximum, ...)
      @org_count = Organization.count
      @reg_count = Regulation.count
      @last_update = Regulation.maximum(:last_seen_at)
      @top_orgs = Organization.joins(:regulations)
                              .group(:id)
                              .order('COUNT(regulations.id) DESC')
                              .limit(5)
    else
      # Si on est sur une date antérieure, on récupère les données à afficher dans la table snapshot
      @org_count = @snapshot&.total_organizations || 0
      @reg_count = @snapshot&.total_regulations || 0
      @last_update = @selected_date.to_time.end_of_day
      
      @top_orgs_events = @snapshot&.snapshot_events
                                  &.where(event_type: 'added')
                                  &.group(:organization_id)
                                  &.count 
                                  &.sort_by { |_id, count| -count }
                                  &.first(5)
    end
  end
end