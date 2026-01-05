class DashboardsController < ApplicationController
  def index
    # KPI 1 : Combien d'organisations avons-nous ?
    @org_count = Organization.count

    # KPI 2 : Combien d'arrêtés au total ?
    @reg_count = Regulation.count

    # KPI 3 : Date de la dernière donnée fraîche (le dernier import)
    # On prend le règlement le plus récent et on regarde son 'last_seen_at'
    @last_update = Regulation.maximum(:last_seen_at)
    
    # KPI 4 : Top 5 des organisations les plus actives (celles qui ont le plus d'arrêtés)
    # C'est une requête un peu plus avancée : 
    # On joint les tables, on groupe par organisation, on compte, et on trie.
    @top_orgs = Organization.joins(:regulations)
                            .group(:id)
                            .order('COUNT(regulations.id) DESC')
                            .limit(5)
  end
end
