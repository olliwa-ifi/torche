
# -------------------------------------------------------------------------
# UIHandler – handles user input, persistence, and material setup
# -------------------------------------------------------------------------

module TorcheDyn
  module UIHandler
    SCHEMA = {
      pos_x:           { prompt: "[ORIGINE] X (cm):",         default: "0.0",   list: nil, type: :float },
      pos_y:           { prompt: "          Y (cm):",         default: "0.0",   list: nil, type: :float },
      hmax:            { prompt: "[TORCHE]  Hmax (cm):",      default: "220.0", list: nil, type: :float },
      rayon:           { prompt: "          Rayon (cm):",     default: "15.0",  list: nil, type: :float },
      nb_quart:        { prompt: "          Nb de lattes:",   default: "24",    list: nil, type: :integer },
      decalage:        { prompt: "          Décalage (cm):",  default: "3.0",   list: nil, type: :float },
      epais:           { prompt: "[LATTE]   Épaisseur (cm):", default: "3.0",   list: nil, type: :float },
      coef_factor:     { prompt: "          Facteur (coef):", default: "1.77777777",   list: nil, type: :float },
      mode_corroye:    { prompt: "[OPTIONS] Corroyé:",        default: "Oui",   list: "Oui|Non", type: :bool },
      parabole_lin:    { prompt: "          Parabole:",       default: "Oui",   list: "Oui|Non", type: :bool },
      mode_deroule:    { prompt: "          Déroulé:",        default: "Non",   list: "Oui|Non", type: :bool },
      show_normals:    { prompt: "          Normales:",       default: "Non",   list: "Oui|Non", type: :bool },
      nb_materials:    { prompt: "          Nb Matériaux:",   default: "1",     list: "1|2", type: :integer }
    }.freeze

    VALIDATION_RULES = {
      pos_x:           { min: -10000, max: 10000 },
      pos_y:           { min: -10000, max: 10000 },
      hmax:            { min: 1, max: 10000 },
      rayon:           { min: 1, max: 5000 },
      nb_quart:        { min: 1, max: 100 },
      decalage:        { min: 1, max: 50},
      epais:           { min: 0.1, max: 50 },
      coef_factor:     { min: 0.01, max: 10 },
    }.freeze

    @@session_params = {}

    def self.run
      begin
        TorcheLogger.debug("Ouverture de la boîte de dialogue de saisie")

        prompts  = []
        defaults = []
        lists    = []

        SCHEMA.each do |key, config|
          prompts  << config[:prompt]
          lists    << config[:list]
          defaults << (@@session_params[key] || config[:default]).to_s
        end

        input = UI.inputbox(prompts, defaults, lists, "Paramètres Torche v#{TorcheDyn::Config::VERSION rescue '1.0.4'}")
        return unless input

        user_data        = SCHEMA.keys.zip(input).to_h
        validated_params = validate_and_sanitize(user_data)

        # On mémorise les chaînes brutes seulement si la validation a réussi
        @@session_params = user_data

        model = Sketchup.active_model
        materials = setup_materials(validated_params[:nb_materials])

        model.start_operation('Générer Torche', true)
        begin
          TorcheDyn::Core.new(model, validated_params, materials).generate
        ensure
          model.commit_operation
        end

        TorcheLogger.info("Génération terminée avec succès.")

      rescue ArgumentError => e
        TorcheLogger.error("Erreur de saisie : #{e.message}")
        UI.messagebox("Erreur de saisie : #{e.message}", MB_OK)
      rescue => e
        TorcheLogger.error("Erreur système : #{e.message}")
        UI.messagebox("Erreur système : #{e.message}", MB_OK)
      end
    end

    private

    def self.validate_and_sanitize(user_data)
      validated = {}
      user_data.each do |key, value|
        config = SCHEMA[key]
        label = config[:prompt].split(':').first
        case config[:type]
        when :float
          num = value.to_f
          check_range(num, key, label)
          validated[key] = num
        when :integer
          num = value.to_i
          check_range(num, key, label)
          validated[key] = num
        when :bool
          validated[key] = (value.to_s.downcase == "oui")
        when :string
          validated[key] = value.to_s.strip
        end
      end
      validated
    end

    def self.check_range(val, key, label)
      rule = VALIDATION_RULES[key]
      return if rule.nil?
      if val < rule[:min] || val > rule[:max]
        raise ArgumentError, "#{label} : doit être entre #{rule[:min]} et #{rule[:max]} (reçu #{val})"
      end
    end

    def self.setup_materials(count)
      model = Sketchup.active_model
      mats = model.materials
      c_clair = Sketchup::Color.new(*(TorcheDyn::Config::COLOR_BOIS_CLAIR rescue [222, 184, 135]))
      c_fonce = Sketchup::Color.new(*(TorcheDyn::Config::COLOR_BOIS_FONCE rescue [101, 67, 33]))
      mat1 = mats["Bois Clair"] || mats.add("Bois Clair")
      mat1.color = c_clair
      mat2 = mats["Bois Foncé"] || mats.add("Bois Foncé")
      mat2.color = c_fonce
      count == 2 ? [mat1, mat2] : mat1
    end
  end
end


