require 'open-uri'

# Ce script importe les données depuis l'API DiaLog et les enregistre dans la base de données

class RegulationsImporter
  URL = "https://dialog.beta.gouv.fr/api/regulations.xml"

  def initialize
    @stats = { created: 0, updated: 0, errors: 0 }
  end

  def perform
    puts "📡 Démarrage de l'import depuis #{URL}..."
    
    xml_data = URI.open(URL)
    doc = Nokogiri::XML(xml_data)
    doc.remove_namespaces!

    nodes = doc.xpath('//trafficRegulationOrder')
    puts "🔍 #{nodes.count} arrêtés trouvés dans le XML."

    nodes.each do |node|
      process_node(node)
    end

    puts "✅ Import terminé ! Résultats : #{@stats}"
  end

  private

  def process_node(node)
    external_id = node['id']
    
    # On garde le nom de l'organisation dans issuingAuthority -> values -> value
    org_name = node.at_xpath('.//issuingAuthority/values/value')&.text&.strip || "Inconnu"
    
    # On extrait les dates de validité des arrêtés présents sur l'API
    start_date_str = node.at_xpath('.//overallStartTime')&.text
    end_date_str = node.at_xpath('.//overallEndTime')&.text

    # On extrait le type d'arrêté
    reg_type = node.at_xpath('.//typeOfRegulation')&.attr('type') || 
               "Autre"

    # On crée un enregistrement par organisation trouvée dans la base de données
    organization = Organization.find_or_create_by(name: org_name)

    # On crée un enregistrement par arrêté trouvé dans la base de données
    regulation = Regulation.find_or_initialize_by(external_id: external_id)
    is_new = regulation.new_record?

    # On assigne, pour chaque arrêté, l'organisation émettrice, les dates de validité, le type d'arrêté
    regulation.organization = organization
    regulation.start_date = start_date_str
    regulation.end_date = end_date_str
    regulation.regulation_type = reg_type
    # Le champ "last_seen_at" permettra de savoir si un arrêté a disparu de la base de données
    regulation.last_seen_at = Time.current

    if regulation.save
      if is_new
        @stats[:created] += 1
        print "+" # On ajoute un signe "+" pour signaler la création d'un arrêté
      else
        @stats[:updated] += 1
        print "." # Le . signale la mise à jour d'un arrêté
      end
    else
      @stats[:errors] += 1
      puts "\n❌ Erreur #{external_id} : #{regulation.errors.full_messages.join(', ')}"
    end
  end
end