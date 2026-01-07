class RegulationsController < ApplicationController
    def index
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @is_today = @selected_date == Date.today
      
      # Selon le cas (date aujourd'hui ou date antérieure) on construit des requêtes différentes.
      if @is_today
        # Date d'aujourd'hui en utilisant les données chaudes
        @base_query = Regulation.active
      else
        # Date antérieure en utilisant les données froides (snapshot)
        # Créés avant la fin du jour choisi ET vus pour la dernière fois après le début du jour choisi
        @base_query = Regulation.where("created_at <= ?", @selected_date.end_of_day)
                                .where("last_seen_at >= ?", @selected_date.beginning_of_day)
      end
  
      # Calcul du total d'arrêtés à l'aide de la requête
      @total_count = @base_query.count
      
      # Si la base est vide sur un jour donné on divise par 0, donc on évite ça avec une conditionnelle
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
  
      # On liste les arrêtés trouvés dans un tableau (limité aux 100 premiers pour l'instant pour perf)
      @regulations = @base_query.includes(:organization, :restrictions)
                                .order(created_at: :desc)
                                .limit(100)
    end
  end