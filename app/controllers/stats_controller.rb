class StatsController < ApplicationController
    def distribution
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @is_today = @selected_date == Date.today
  
      # 1. Calcul de la distribution
      query = Organization.joins(:regulations)
      if @is_today
        query = query.merge(Regulation.active)
      else
        query = query.where("regulations.created_at <= ?", @selected_date.end_of_day)
                     .where("regulations.last_seen_at >= ?", @selected_date.beginning_of_day)
      end
  
      # Récupère le compte par organisation : { org_id => count }
      counts = query.group(:id).count.values
      
      # 2. Groupe par quantité : { 10 arrêtés => 5 orgs, 11 arrêtés => 2 orgs... }
      # On trie par la quantité (X)
      @distribution_data = counts.tally.sort.to_h
  
      # 3. Paramètres pour le graphique (Axe X = Quantité, Axe Y = Nombre d'orgs)
      @max_x = @distribution_data.keys.max || 0
      @max_y = @distribution_data.values.max || 0
      @total_orgs = counts.size
      @average = @total_orgs.positive? ? (counts.sum.to_f / @total_orgs).round(1) : 0
    end
  end