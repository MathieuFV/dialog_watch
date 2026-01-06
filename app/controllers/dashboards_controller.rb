class DashboardsController < ApplicationController
  def index
    # Gestion du sélecteur de date
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @is_today = @selected_date == Date.today
    @snapshot = DailySnapshot.find_by(date: @selected_date)

    # Pour la date sélectionnée, récupérer le snapshot de la base de données de ce jour là
    @snapshot = DailySnapshot.find_by(date: @selected_date)

    # Calcul des indicateurs du dashboard pour le snapshot séléctionné
    if @is_today
      @org_count = Organization.count
      @reg_count = Regulation.count
      @last_update = DailySnapshot.maximum(:updated_at)
      
      @top_orgs = Organization.joins(:regulations)
                              .group(:id)
                              .order('COUNT(regulations.id) DESC')
                              .limit(5)
    else
      @org_count = @snapshot&.total_organizations || 0
      @reg_count = @snapshot&.total_regulations || 0
      @last_update = @snapshot&.updated_at
      
      @top_orgs_events = @snapshot&.snapshot_events
                                  &.where(event_type: 'added')
                                  &.group(:organization_id)
                                  &.count
                                  &.sort_by { |_id, count| -count }
                                  &.first(5) || []
    end
  end

  # On ajoute une action pour rafraîchir les données à la main depuis l'interface
  def refresh_data
    # 1. Le serveur exécute l'import (le navigateur attend ici)
    WatchdogJob.perform_now 
  
    # 2. Une fois fini, on redirige normalement. 
    # Turbo (côté navigateur) verra la redirection et rechargera la page de destination.
    redirect_to root_path, status: :see_other
  end
end