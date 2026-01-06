class OrganizationsController < ApplicationController
    def index
      @filter = params[:filter] || "all"
      
      # Logique de filtrage
      case @filter
      when "permanent"
        # Un arrêté est permanent s'il n'a pas de date de fin
        @organizations = Organization.joins(:regulations)
                                     .where(regulations: { end_date: nil })
                                     .group(:id)
                                     .select("organizations.*, COUNT(regulations.id) as regs_count")
                                     .order("regs_count DESC")
      when "temporary"
        # Un arrêté est temporaire s'il a une date de fin
        @organizations = Organization.joins(:regulations)
                                     .where.not(regulations: { end_date: nil })
                                     .group(:id)
                                     .select("organizations.*, COUNT(regulations.id) as regs_count")
                                     .order("regs_count DESC")
      else
        @organizations = Organization.joins(:regulations)
                                     .group(:id)
                                     .select("organizations.*, COUNT(regulations.id) as regs_count")
                                     .order("regs_count DESC")
      end
    end
  end