class OrganizationsController < ApplicationController
  def index
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @is_today = @selected_date == Date.today
    @filter = params[:filter] || "all"
    
    # Construction de la requête de base
    query = Organization.joins(:regulations)
  
    if @is_today
      query = query.merge(Regulation.active)
    else
      query = query.where("regulations.created_at <= ?", @selected_date.end_of_day)
                   .where("regulations.last_seen_at >= ?", @selected_date.beginning_of_day)
    end
  
    # Application des filtres de type
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