module ApplicationHelper
    # -------------------------------------------------------------------------
    # MÉTHODES DE STYLE (TAILWIND)
    # On retourne les classes en toutes lettres pour que le compilateur les détecte.
    # -------------------------------------------------------------------------
  
    # 1. Pour les Badges (Fond clair + Texte foncé)
    def badge_class_for_type(type)
      case type
      when 'AccessRestriction', 'Restriction de circulation'
        'bg-blue-100 text-blue-800'
      when 'StandingOrParkingRestriction', 'Restriction de stationnement'
        'bg-amber-100 text-amber-800'
      when 'SpeedLimit', 'Limitation de vitesse'
        'bg-rose-100 text-rose-800'
      when 'Multi-type'
        'bg-slate-100 text-slate-800'
      else
        'bg-gray-100 text-gray-800'
      end
    end
  
    # 2. Pour les Barres de progression (Fond vif -500)
    def progress_bar_class_for_type(type)
      case type
      when 'AccessRestriction', 'Restriction de circulation'
        'bg-blue-500' 
      when 'StandingOrParkingRestriction', 'Restriction de stationnement'
        'bg-amber-500'
      when 'SpeedLimit', 'Limitation de vitesse'
        'bg-rose-500'
      when 'Multi-type'
        'bg-slate-500'
      else
        'bg-gray-500'
      end
    end
  
    # 3. Pour les Puces / Dots (Fond moyen -400)
    def dot_class_for_type(type)
      case type
      when 'AccessRestriction', 'Restriction de circulation'
        'bg-blue-400'
      when 'StandingOrParkingRestriction', 'Restriction de stationnement'
        'bg-amber-400'
      when 'SpeedLimit', 'Limitation de vitesse'
        'bg-rose-400'
      when 'Multi-type'
        'bg-slate-400'
      else
        'bg-gray-400'
      end
    end
  
    # -------------------------------------------------------------------------
    # GÉNÉRATEURS HTML
    # -------------------------------------------------------------------------
  
    # Génère le badge HTML complet
    def type_badge(type)
      # On récupère les classes CSS explicites via la méthode ci-dessus
      css_classes = badge_class_for_type(type)
      translated_type = t("regulations.types.#{type}", default: type)
      
      content_tag(:span, translated_type, 
        class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{css_classes}")
    end
  
    # Gardé pour compatibilité si tu l'utilises ailleurs pour juste avoir le nom de la couleur
    def color_for_type(type)
      case type
      when 'AccessRestriction', 'Restriction de circulation' then 'blue'
      when 'StandingOrParkingRestriction', 'Restriction de stationnement' then 'amber'
      when 'SpeedLimit', 'Limitation de vitesse' then 'rose'
      when 'Multi-type' then 'slate'
      else 'gray'
      end
    end
  end