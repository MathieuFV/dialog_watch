class StatsController < ApplicationController
    def distribution
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @is_today = @selected_date == Date.today
  
      # Calcul du nombre d'arrêtés par organisation
      query = Organization.joins(:regulations)
      if @is_today
        query = query.merge(Regulation.active)
      else
        query = query.where("regulations.created_at <= ?", @selected_date.end_of_day)
                     .where("regulations.last_seen_at >= ?", @selected_date.beginning_of_day)
      end
  
      counts = query.group(:id).count.values
      
      # On fait des groupes par nombre d'arrêtés publiés
      @distribution_data = counts.tally.sort.to_h
  
      # Sur les abscisses on met la quantité d'arrêtés publiés, sur les ordonnées le nombre d'organisation qui ont 
      # publié cette quantité d'arrêtés.
      @max_x = @distribution_data.keys.max || 0
      @max_y = @distribution_data.values.max || 0
      @total_orgs = counts.size
      @average = @total_orgs.positive? ? (counts.sum.to_f / @total_orgs).round(1) : 0
    end
  end