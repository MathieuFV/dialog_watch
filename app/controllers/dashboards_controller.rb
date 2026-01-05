class DashboardsController < ApplicationController
  def index
    # 1. Gestion de la date sélectionnée
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @is_today = @selected_date == Date.today

    # 2. Récupération du snapshot pour cette date
    @snapshot = DailySnapshot.find_by(date: @selected_date)

    # 3. Calcul des KPIs
    if @is_today
      # Si c'est aujourd'hui, on garde tes requêtes performantes en temps réel
      @org_count = Organization.count
      @reg_count = Regulation.count
      @last_update = Regulation.maximum(:last_seen_at)
      @top_orgs = Organization.joins(:regulations)
                              .group(:id)
                              .order('COUNT(regulations.id) DESC')
                              .limit(5)
    else
      @org_count = @snapshot&.total_organizations || 0
      @reg_count = @snapshot&.total_regulations || 0
      @last_update = @selected_date.to_time.end_of_day # La date du snapshot
      
      @top_orgs_events = @snapshot&.snapshot_events
                                  &.where(event_type: 'added')
                                  &.group(:organization_id)
                                  &.count 
                                  &.sort_by { |_id, count| -count }
                                  &.first(5)
    end
  end
end