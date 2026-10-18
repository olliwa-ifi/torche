module TorcheDyn
  class UIHandler
    # Persistance des paramètres durant la session
    @@last_params = {
      mode: "Dressed",
      curve: "Para",
      radius: 1000.mm,
      nb_quarters: 4,
      offset: 50.mm,
      thickness: 20.mm,
      hmax: 500.mm,
      coeff: 1.2,
      pos_x: 0,
      pos_y: 0,
      mode_deroule: false,
      nb_materials: 2,
      show_normals: false
    }

    def self.show_dialog
      # Construction des prompts pour UI.inputbox
      prompts = [
        "Mode (Dressed/OCL):", "Courbe (Para/Lin):", "Rayon:", 
        "Nombre de Quarts:", "Offset:", "Épaisseur:", 
        "Hmax:", "Coefficient:", "Position X:", "Position Y:", 
        "Mode Déroulé (True/False):", "Nb Matériaux (1/2):", "Afficher Normales:"
      ]

      defaults = [
        @@last_params[:mode], @@last_params[:curve], @@last_params[:radius],
        @@last_params[:nb_quarters], @@last_params[:offset], @@last_params[:thickness],
        @@last_params[:hmax], @@last_params[:coeff], @@last_params[:pos_x], @@last_params[:pos_y],
        @@last_params[:mode_deroule], @@last_params[:nb_materials], @@last_params[:show_normals]
      ]

      # Affichage de la boîte de dialogue standard SketchUp
      input = UI.inputbox(prompts, defaults, "Paramètres Torche Volume")

      if input
        # Mise à jour de la persistance
        @@last_params = {
          mode: input[0],
          curve: input[1],
          radius: input[2].to_f,
          nb_quarters: input[3].to_i,
          offset: input[4].to_f,
          thickness: input[5].to_f,
          hmax: input[6].to_f,
          coeff: input[7].to_f,
          pos_x: input[8].to_f,
          pos_y: input[9].to_f,
          mode_deroule: input[10].to_s.downcase == 'true',
          nb_materials: input[11].to_i,
          show_normals: input[12].to_s.downcase == 'true'
        }
        return @@last_params
      end

      nil
    end

    def self.setup_material(nb_materials)
      model = Sketchup.active_model
      materials = model.materials

      # Création du matériau Bois Clair
      mat_clair = materials.add("Bois Clair")
      mat_clair.color = Sketchup::Color.new(222, 184, 135)

      if nb_materials >= 2
        # Création du matériau Bois Foncé
        mat_fonce = materials.add("Bois Foncé")
        mat_fonce.color = Sketchup::Color.new(101, 67, 33)
        
        # Retourne un tableau pour permettre l'alternance dans Core
        return [mat_clair, mat_fonce]
      end

      # Retourne un objet unique si nb_materials == 1
      mat_clair
    end
  end
end
