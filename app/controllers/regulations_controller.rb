class RegulationsController < ApplicationController
    def index
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @is_today = @selected_date == Date.today
      
      # 1. Définition de la requête de base selon la date
      if @is_today
        # Situation LIVE : Uniquement les arrêtés marqués actifs aujourd'hui
        @base_query = Regulation.active
      else
        # Situation HISTORIQUE :
        # Créés avant la fin du jour choisi ET vus pour la dernière fois après le début du jour choisi
        # (Cela exclut les arrêtés qui étaient déjà "fantômes" à cette date)
        @base_query = Regulation.where("created_at <= ?", @selected_date.end_of_day)
                                .where("last_seen_at >= ?", @selected_date.beginning_of_day)
      end
  
      # 2. Calcul des Statistiques
      @total_count = @base_query.count
      
      # Évite la division par zéro si la base est vide pour un jour donné
      if @total_count > 0
        @permanent_count = @base_query.where(end_date: nil).count
        @temporary_count = @total_count - @permanent_count
  
        # Répartition par type (via les restrictions)
        @type_distribution = Restriction.joins(:regulation)
                                        .where(regulation: @base_query)
                                        .group(:restriction_type)
                                        .count
                                        .sort_by { |_type, count| -count }
      else
        @permanent_count = 0
        @temporary_count = 0
        @type_distribution = []
      end
  
      # 3. Liste pour le tableau (avec jointures pour la performance)
      @regulations = @base_query.includes(:organization, :restrictions)
                                .order(created_at: :desc)
                                .limit(100)
    end
  end