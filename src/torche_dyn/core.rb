# -------------------------------------------------------------------------
# Core – generation of the Torche volume
# -------------------------------------------------------------------------

module TorcheDyn
  class Core
    
    def initialize(model, params, materials)
      @model = model
      @params = params
      @materials = materials # Array [mat1, mat2] or single material object
      @definitions = model.definitions
    end

    def generate
      LogManager.info "Initialisation de la génération Torche..."
      
      # 1. Determine curve label for naming
      courbe_label = @params[:parabole_lin] ? "Para" : "Lin"
      coef_val = @params[:coef_factor] || 0.0
      coef_label = "C#{coef_val.round(2)}"
    
      # 2. Build the main component name
      main_suffix = @params[:mode_corroye] ? "Dressed" : "OpenCutList"
      comp_name = "Torche_#{main_suffix}_v#{VERSION}_#{courbe_label}_#{coef_label}"
    
      tor_def = @definitions.add(comp_name)
      LogManager.info "Composant principal créé : #{tor_def.name}"
      
      setup_math_constants
      
      LogManager.info "Création des #{ @params[:nb_quart] } douelles en cours..."
 
      (0...@params[:nb_quart]).each do |i|
        begin
          slat_def = create_slat_definition(i)
          place_slat(tor_def, slat_def, i)
          # Progress log every 5 slats
          LogManager.info "Progression : Douelle #{i+1}/#{@params[:nb_quart]} placée." if (i + 1) % 5 == 0
        rescue => e
          LogManager.error("Échec de la douelle index #{i}", e)
        end
      end
      
      # Final positioning based on UI input
      final_pos = Geom::Point3d.new(@params[:pos_x].cm, @params[:pos_y].cm, 0)
      final_trans = Geom::Transformation.new(final_pos)
    
      @model.active_entities.add_instance(tor_def, final_trans)
      
      LogManager.info "Instance finale ajoutée au modèle."
      LogManager.info "Génération terminée avec succès."
    end

    private

    # -----------------------------------------------------------------
    # Geometric constants shared by all slats
    # -----------------------------------------------------------------
    def setup_math_constants
      @angle_step = (-360.0 / @params[:nb_quart]) * (Math::PI / 180.0)
      half_angle = Math::PI / @params[:nb_quart]

      @factor = @params[:coef_factor]
      @interieur = @params[:rayon] * Math.tan(half_angle) * 2
      @exterieur = (@params[:rayon] + @params[:epais]) * Math.tan(half_angle) * 2
      @e = @params[:epais]
      xmax = @exterieur * @params[:nb_quart]

      if @params[:parabole_lin] 
        @mid_threshold = ((@params[:nb_quart] / Math.sqrt(@factor)).to_i) - 1
        @coef1 = @params[:hmax] / (xmax**2)
        @coef2 = (@params[:hmax] - @params[:decalage]) / (xmax**2)
      else
        @mid_threshold = ((@params[:nb_quart] / @factor).to_i) - 1
        @coef1 = @params[:hmax] / xmax
        @coef2 = (@params[:hmax] - @params[:decalage]) / xmax
      end

      mode_label = @params[:parabole_lin] ? "parabolique" : "linéaire"
      LogManager.debug "Mode : #{mode_label} | MidThreshold = #{@mid_threshold}, Coef1 = #{@coef1.round(3)}, Coef2 = #{@coef2.round(3)}"
      
      @profile_pts = {
        ptA: Geom::Point3d.new((-@interieur / 2).cm, 0, 0),
        ptB: Geom::Point3d.new(( @interieur / 2).cm, 0, 0),
        ptC: Geom::Point3d.new(( @exterieur / 2).cm, @params[:epais].cm, 0),
        ptD: Geom::Point3d.new((-@exterieur / 2).cm, @params[:epais].cm, 0)
      }
    end

    # -----------------------------------------------------------------
    # Slat Creation
    # -----------------------------------------------------------------
    def create_slat_definition(index)
      # 1. Calculate local heights
      x_curr = index * @exterieur
      x_next = (index + 1) * @exterieur
      
      if @params[:parabole_lin]
        y_curr_coef1 = @params[:hmax] - (@coef1 * (x_curr**2))
        y_next_coef1 = @params[:hmax] - (@coef1 * (x_next**2))
      else
        y_curr_coef1 = @params[:hmax] - (@coef1 * x_curr)
        y_next_coef1 = @params[:hmax] - (@coef1 * x_next)
      end
      
      y_curr_coef2 = 0.0
      y_next_coef2 = 0.0

      if @params[:parabole_lin]
        if index <= (@mid_threshold)
          y_curr_coef2 = (@params[:hmax] - @params[:decalage]) - (@coef2 * @factor * (x_curr**2))
          y_next_coef2 = (@params[:hmax] - @params[:decalage]) - (@coef2 * @factor * (x_next**2))
        end
      else
        if index <= (@mid_threshold)
          y_curr_coef2 = (@params[:hmax] - @params[:decalage]) - (@coef2 * @factor * x_curr)
          y_next_coef2 = (@params[:hmax] - @params[:decalage]) - (@coef2 * @factor * x_next)
        end
      end

      LogManager.debug "Douelle #{index}: y_curr_1= #{y_curr_coef1.round(3)}, y_next_1=#{y_next_coef1.round(3)}, y_curr_2=#{y_curr_coef2.round(3)}, y_next_2=#{y_next_coef2.round(3)}"
      
      # 2. Material selection: 2 Light, 1 Dark cycle
      if @materials.is_a?(Array)
        if @params[:nb_materials] == 2
          cycle_index = index % 3
          mat_index = (cycle_index == 2) ? 1 : 0
          current_mat = @materials[mat_index] 
        else
          current_mat = @materials[0]
        end 
      else
        current_mat = @materials
      end
      
      suffix = @params[:mode_corroye] ? "Dressed" : "ForCutList"
      slat_def = @definitions.add("Slat_#{index}_#{suffix}_v#{VERSION}")
      
      if @params[:mode_corroye]
        build_dressed_slat(slat_def, y_curr_coef1, y_next_coef1, y_curr_coef2, y_next_coef2, current_mat)
      else
        build_simple_slat(slat_def, y_curr_coef1, y_next_coef1, y_curr_coef2, y_next_coef2, current_mat)
      end

      slat_def
    end

    # -----------------------------------------------------------------
    # OpenCutList Mode
    # -----------------------------------------------------------------
    def build_simple_slat(slat_def, y_curr_coef1, y_next_coef1, y_curr_coef2, y_next_coef2, material)
      ztop      = (y_curr_coef1 - y_next_coef1).cm
      push_dist = (y_curr_coef1 - y_next_coef2).cm
						  
      pts = @profile_pts.values.map{ |pt| pt.offset([0, 0, ztop]) }
      face = slat_def.entities.add_face(pts)
      
      face.pushpull(-push_dist) if push_dist > 0.001
      slat_def.entities.grep(Sketchup::Face).each { |f| f.material = material if material}
    end

    # -----------------------------------------------------------------
    # Dressed Mode – 8 points / 12 faces
    # -----------------------------------------------------------------
    def build_dressed_slat(slat_def, y_curr_coef1, y_next_coef1, y_curr_coef2, y_next_coef2, material)
      z0  = 0.0
      ztop = y_curr_coef1 - y_next_coef1
      zmid = y_curr_coef2 - y_next_coef1
      zbot = y_next_coef2 - y_next_coef1

      pts = {
        A_t: Geom::Point3d.new((-@interieur / 2).cm, 0, ztop.cm),
        B_t: Geom::Point3d.new(( @interieur / 2).cm, 0, z0.cm),
        C_t: Geom::Point3d.new(( @exterieur / 2).cm, @e.cm, z0.cm),
        D_t: Geom::Point3d.new((-@exterieur / 2).cm, @e.cm, ztop.cm),

        A_b: Geom::Point3d.new((-@interieur / 2).cm, 0, zmid.cm),
        B_b: Geom::Point3d.new(( @interieur / 2).cm, 0, zbot.cm),
        C_b: Geom::Point3d.new(( @exterieur / 2).cm, @e.cm, zbot.cm),
        D_b: Geom::Point3d.new((-@exterieur / 2).cm, @e.cm, zmid.cm)
      }

      ents = slat_def.entities

      if (y_curr_coef2 - y_next_coef2).abs < 0.001 and (y_curr_coef2 - y_next_coef1).abs < 0.001
        LogManager.debug "Points de base confondus ou alignés (zmid=zbot), passage en mode triangulation."
        begin; ents.add_face(pts[:A_t], pts[:B_t], pts[:B_b]); rescue => e; LogManager.debug "Err Triangle AtBtBb: #{e.message}"; end
        begin; ents.add_face(pts[:A_t], pts[:B_b], pts[:A_b]); rescue => e; LogManager.debug "Err Triangle AtBbAb: #{e.message}"; end
        begin; ents.add_face(pts[:D_t], pts[:C_t], pts[:C_b]); rescue => e; LogManager.debug "Err Triangle DtCtCb: #{e.message}"; end
        begin; ents.add_face(pts[:D_t], pts[:C_b], pts[:D_b]); rescue => e; LogManager.debug "Err Triangle DtCbDb: #{e.message}"; end
        begin; ents.add_face(pts[:A_t], pts[:D_t], pts[:D_b]); rescue => e; LogManager.debug "Err Triangle AtDtDb: #{e.message}"; end
        begin; ents.add_face(pts[:A_t], pts[:D_b], pts[:A_b]); rescue => e; LogManager.debug "Err Triangle AtDbAb: #{e.message}"; end
        begin; ents.add_face(pts[:B_t], pts[:C_t], pts[:C_b]); rescue => e; LogManager.debug "Err Triangle BtCtCb: #{e.message}"; end
        begin; ents.add_face(pts[:B_t], pts[:C_b], pts[:B_b]); rescue => e; LogManager.debug "Err Triangle BtCbBb: #{e.message}"; end
      else
        begin; ents.add_face(pts[:A_t], pts[:B_t], pts[:B_b], pts[:A_b]); rescue => e; LogManager.debug "Err Quadri ABtb: #{e.message}"; end
        begin; ents.add_face(pts[:D_t], pts[:C_t], pts[:C_b], pts[:D_b]); rescue => e; LogManager.debug "Err Quadri DCtb: #{e.message}"; end
        begin; ents.add_face(pts[:A_t], pts[:D_t], pts[:D_b], pts[:A_b]); rescue => e; LogManager.debug "Err Quadri ADtb: #{e.message}"; end
        begin; ents.add_face(pts[:B_t], pts[:C_t], pts[:C_b], pts[:B_b]); rescue => e; LogManager.debug "Err Quadri BCtb: #{e.message}"; end
      end

      begin; ents.add_face(pts[:A_t], pts[:B_t], pts[:C_t]); rescue => e; LogManager.debug "Erreur face At Bt Ct: #{e.message}"; end 
      begin; ents.add_face(pts[:A_t], pts[:C_t], pts[:D_t]); rescue => e; LogManager.debug "Erreur face At Ct Dt: #{e.message}"; end 
      begin; ents.add_face(pts[:C_b], pts[:D_b], pts[:B_b]); rescue => e; LogManager.debug "Erreur face Cb Db Bb: #{e.message}"; end
      begin; ents.add_face(pts[:A_b], pts[:D_b], pts[:B_b]); rescue => e; LogManager.debug "Erreur face Ab Db Bb: #{e.message}"; end
      
      finalize_segment(slat_def, material)
    end

    def finalize_segment(definition, material)
      ents = definition.entities
      orient_faces_outward(ents)
      visualize_normals(ents) if @params[:show_normals]
      ents.grep(Sketchup::Face).each { |f| f.material = material if material}
    end

    def orient_faces_outward(entities)
      centroid = calculate_global_centroid(entities)
      entities.grep(Sketchup::Face).each do |face|
        face_center = calculate_face_centroid(face)
        vector_outward = face_center - centroid
        face.reverse! if vector_outward.dot(face.normal) < 0
      end
    end

    def calculate_global_centroid(entities)
      faces = entities.grep(Sketchup::Face)
      return Geom::Point3d.new(0,0,0) if faces.empty?
      sum_x = sum_y = sum_z = total_area = 0.0
      faces.each do |f|
        c = f.bounds.center; a = f.area
        sum_x += c.x * a; sum_y += c.y * a; sum_z += c.z * a; total_area += a
      end
      total_area == 0 ? Geom::Point3d.new(0,0,0) : Geom::Point3d.new(sum_x / total_area, sum_y / total_area, sum_z / total_area)
    end

    def calculate_face_centroid(face)
      v = face.vertices
      sx = sy = sz = 0.0
      v.each { |vert| p = vert.position; sx += p.x; sy += p.y; sz += p.z }
      Geom::Point3d.new(sx / v.length, sy / v.length, sz / v.length)
    end

    def visualize_normals(entities)
      entities.grep(Sketchup::Face).each do |face|
        center = calculate_face_centroid(face)
        line = entities.add_line(center, center.offset(face.normal, Config::STYLE[:normal_line_length]))
        line.material = "Red"
      end
    end

    def place_slat(tor_def, slat_def, i)
     y_end = @params[:parabole_lin] ? (@params[:hmax] - (@coef1 * ((i + 1) * @exterieur)**2)) : (@params[:hmax] - (@coef1 * ((i + 1) * @exterieur)))
    
     if @params[:mode_deroule]
       pos = [ i * @exterieur, 0, y_end ]
       trans = Geom::Transformation.new(pos.map { |v| v.cm })
       rot = Geom::Transformation.new
       tor_def.entities.add_instance(slat_def, trans * rot)
     else
       cercle_rad = (i + 1) * @angle_step
       pos = [ -@params[:rayon] * Math.cos(cercle_rad), -@params[:rayon] * Math.sin(cercle_rad), y_end ]
       trans = Geom::Transformation.new(pos.map { |v| v.cm })
       rot = Geom::Transformation.rotation(Geom::Point3d.new(0,0,0), [0,0,1], cercle_rad + (Math::PI / 2))
       tor_def.entities.add_instance(slat_def, trans * rot)
     end
    end
  end
end
