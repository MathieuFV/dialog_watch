class OrganizationsController < ApplicationController
  def index
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @is_today = @selected_date == Date.today
    @filter = params[:filter] || "all"
    
    query = Organization.joins(:regulations)
  
    if @is_today
      query = query.merge(Regulation.active)
    else
      query = query.where("regulations.created_at <= ?", @selected_date.end_of_day)
                   .where("regulations.last_seen_at >= ?", @selected_date.beginning_of_day)
    end
  
    # Filtres par type d'arrêté
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

    def show
      @organization = Organization.find(params[:id])
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @is_today = @selected_date == Date.today
    
      # On récupère les arrêtés de l'organisation
      @regulations = @organization.regulations
      
      if @is_today
        @regulations = @regulations.active
      else
        # FIX ICI : On ajoute "regulations." devant les noms de colonnes
        @regulations = @regulations.where("regulations.created_at <= ?", @selected_date.end_of_day)
                                   .where("regulations.last_seen_at >= ?", @selected_date.beginning_of_day)
      end
    
      @reg_count = @regulations.count
    
      # Répartition Temp/Perm
      @permanent_count = @regulations.where(end_date: nil).count
      @temporary_count = @reg_count - @permanent_count
    
      # Répartition des types (Cette ligne provoquait l'erreur à cause de la jointure)
      @restriction_counts = @regulations.joins(:restrictions)
                                        .group("restrictions.restriction_type")
                                        .count
      
      @pagy, @regulations = pagy(
        @organization.regulations.where("created_at <= ?", @selected_date.end_of_day)
                                  .where("last_seen_at >= ?", @selected_date.beginning_of_day)
                                  .order(created_at: :desc),
        items: 25
      )
    end
  end