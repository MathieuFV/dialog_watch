class OrganizationsController < ApplicationController
    def index
      # On récupère la date des paramètres, sinon aujourd'hui
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @filter = params[:filter] || "all"
      
      # On définit la limite de temps : fin de la journée sélectionnée
      limit_date = @selected_date.to_time.end_of_day
  
      # On ne compte que les arrêtés créés AVANT ou PENDANT cette date
      query = Organization.joins(:regulations)
                          .where("regulations.created_at <= ?", limit_date)
  
      case @filter
      when "permanent"
        query = query.where(regulations: { end_date: nil })
      when "temporary"
        query = query.where.not(regulations: { end_date: nil })
      end
  
      @organizations = query.group(:id)
                            .select("organizations.*, COUNT(regulations.id) as regs_count")
                            .order("regs_count DESC")
    end
  end