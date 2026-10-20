# -------------------------------------------------------------------------
# Configuration
# -------------------------------------------------------------------------
module TorcheDyn
  module Config
    SKETCHUP_MIN_VERSION = 20.0
    # --- Version du Plugin ---
    VERSION = "1.0.3.1"

    DEFAULT_PARAMS = {
      rayon: 15.0, 
      nb_quart: 24, 
      decalage: 3.0, 
      epais: 3.0, 
      hmax: 220.0, 
      mode_corroye: true, 
      show_normals: false, 
      parabole_lin: true, 
      coef_factor: 1.77777777, # Valeur 16/9 par défaut
      mode_deroule: false,  # Valeur par défaut : cercle (false) ou déroulé (true)
      pos_x: 0.0, 
      pos_y: 0.0,
      nb_materials: 1 
    }.freeze

    STYLE = {
      normal_line_length: 10.cm
    }.freeze
    
    # --- Couleurs des matériaux (RGB) ---
    # Bois Clair : Beige/Chamois
    COLOR_BOIS_CLAIR = [222, 185, 135]
    # Bois Foncé : Marron Chocolat
    COLOR_BOIS_FONCE = [101, 67, 33]
  end
end
