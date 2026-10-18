# ==============================================================================
# Plugin : Torche_dyn - Générateur de Torche en bois
# Version : 2.0.5.1 (Parabole ou Linéaire,  Déroulé ou final, Position) 
# ==============================================================================
require 'sketchup.rb'

# Chargement des modules du projet

module TorcheDyn
  require_relative 'config'
  require_relative 'logger'
  require_relative 'ui_handler'
  require_relative 'core'

  # Méthode principale lancée par le menu SketchUp
  def self.run_generator
    begin
      # 1. Affichage de l'UI et récupération des paramètres
      # UIHandler.show_dialog retourne un hash de params ou nil si annulé
      params = UIHandler.show_dialog
      
      if params
        # 2. Initialisation du moteur de génération avec les paramètres et matériaux
        materials = UIHandler.setup_material(params[:nb_materials])
        
        generator = Core.new(params, materials)
        
        # 3. Exécution de la génération dans une opération pour permettre l'Undo
        model = Sketchup.active_model
        model.start_operation('Generate Torche Volume', true)
        
        generator.generate
        
        model.commit_operation
        
        Logger.info("Torche Volume generated successfully.")
      else
        Logger.info("Generation cancelled by user.")
      end
      
    rescue StandardError => e
      Sketchup.active_model.abort_operation if Sketchup.active_model.active_operation
      Logger.error("Failed to generate Torche Volume: #{e.message}")
      puts e.backtrace # Sortie console détaillée pour le développeur
    end
  end

 # -------------------------------------------------------------------------
  # Enregistrement du menu
  # -------------------------------------------------------------------------
   # Installation du menu au chargement du plugin
  if !defined?(@menu_loaded)
    menu = UI.menu("Plugins")
    menu.add_item("Générateur Torche Volume") { self.run_generator }
    @menu_loaded = true
  end
end
