# -------------------------------------------------------------------------
# UIHandler – handles user input, persistence, and material setup
# -------------------------------------------------------------------------

module TorcheDyn
  
  class UIHandler
    # Class variable to remember the last entered values during the session
    @@last_params = TorcheDyn::Config::DEFAULT_PARAMS 
    
    def self.run
      LogManager.write_header
      model = Sketchup.active_model
      
      # Version check
      if Sketchup.version.to_f < Config::SKETCHUP_MIN_VERSION
        LogManager.warn "Version incompatible : #{Sketchup.version}"
        UI.messagebox("Version incompatible : SketchUp #{Config::SKETCHUP_MIN_VERSION} minimum requis.")
        return
      end

      # Collect inputs from the user
      params = collect_inputs
      return unless params # Exit if user pressed 'Cancel'
      
      # Persist the validated values for the next run
      @@last_params = params

      # Setup materials (returns either a single material or an array [mat1, mat2])
      materials = setup_material
      
      # Formatting material names for the log
      mat_names = materials.is_a?(Array) ? materials.map(&:name).join(", ") : materials.name
      LogManager.info "Matériau(x) configuré(s) : #{mat_names}"

      # Wrap generation in an operation for single-click Undo
      model.start_operation('Générer Torche v' + TorcheDyn::Config::VERSION, true)
      
      begin
        # Instantiate Core and generate the volume
        Core.new(model, params, materials).generate 
      rescue StandardError => e
        LogManager.error("Erreur fatale lors de la génération", e)
        UI.messagebox("Une erreur est survenue :\n#{e.message}")
      ensure
        model.commit_operation
        LogManager.info "Opération terminée."
      end
    end

    private

    def self.collect_inputs
      prompts = [
        "Rayon (cm)", "Nb Quartiers", "Décalage (cm)", "Épaisseur (cm)", 
        "Hmax (cm)", "Facteur(coef)", "Mode (1:Corroyé 0:OCL)", 
        "Normales (1:Oui 0:Non)", "Courbe (1:Parabole 0:Linéaire)", "Déroulé (1:Oui 0:Non)", 
        "Position X (cm)", "Position Y (cm)",
        "Nb Matériaux (1 ou 2)"
      ]
      
      # Use @@last_params for session persistence
      defaults = [
        @@last_params[:rayon], 
        @@last_params[:nb_quart], 
        @@last_params[:decalage],
        @@last_params[:epais], 
        @@last_params[:hmax], 
        @@last_params[:coef_factor],
        @@last_params[:mode_corroye] ? 1 : 0, 
        @@last_params[:show_normals] ? 1 : 0,
        @@last_params[:parabole_lin] ? 1 : 0,
        @@last_params[:mode_deroule] ? 1 : 0,
        @@last_params[:pos_x],
        @@last_params[:pos_y],
        @@last_params[:nb_materials] || 1 
      ]

      input = UI.inputbox(prompts, defaults, "Paramètres Torche v#{VERSION}")
      return nil unless input

      { 
        rayon: input[0].to_f, 
        nb_quart: [input[1].to_i, 1].max, 
        decalage: input[2].to_f, 
        epais: input[3].to_f, 
        hmax: input[4].to_f, 
        coef_factor: input[5].to_f,
        mode_corroye: input[6].to_i == 1, 
        show_normals: input[7].to_i == 1, 
        parabole_lin: input[8].to_i == 1,
        mode_deroule: input[9].to_i == 1,
        pos_x: input[10].to_f, 
        pos_y: input[11].to_f, 
        nb_materials: [input[12].to_i, 1].max
      }
    end

    def self.setup_material
      model = Sketchup.active_model
      mats = model.materials

      # On récupère les couleurs depuis le module Config
      # On utilise l'astérisque (*) pour "splatter" le tableau [R,G,B] 
      # comme arguments pour Sketchup::Color.new
      color_clair = Sketchup::Color.new(*TorcheDyn::Config::COLOR_BOIS_CLAIR)
      color_fonce = Sketchup::Color.new(*TorcheDyn::Config::COLOR_BOIS_FONCE)

      mat1 = mats["Bois Clair"] || mats.add("Bois Clair")
      mat1.color = color_clair

      mat2 = mats["Bois Foncé"] || mats.add("Bois Foncé")
      mat2.color = color_fonce
      
      # On utilise les paramètres persistants pour savoir combien de matériaux retourner
      if @@last_params[:nb_materials] == 2
        return [mat1, mat2]
      else
        return mat1
      end
    end


    def self.setup_material
      model = Sketchup.active_model
      mats = model.materials

      # RGB Colors
      # Light Wood: Beige/Chamois (222, 184, 135)
      # Dark Wood: Chocolate Brown (101, 67, 33)
      color_clair = Sketchup::Color.new(222, 184, 135)
      color_fonce = Sketchup::Color.new(101, 67, 33)

      mat1 = mats["Bois Clair"] || mats.add("Bois Clair")
      mat1.color = color_clair

      mat2 = mats["Bois Foncé"] || mats.add("Bois Foncé")
      mat2.color = color_fonce
      
      # Return array for the 2-light/1-dark cycle, otherwise just the primary material
      if @@last_params[:nb_materials] == 2
        return [mat1, mat2]
      else
        return mat1
      end
    end
  end
end
