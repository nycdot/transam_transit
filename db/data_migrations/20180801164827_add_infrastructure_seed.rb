class AddInfrastructureSeed < ActiveRecord::DataMigration
  def up
    infrastructure_segment_unit_types = [
        {name: 'Marker Posts', active: true},
        {name: 'Lat / Long', active: true},
        {name: 'Chaining', active: true}
    ]

    infrastructure_chain_types = [
        {name: 'Engineer (100 feet) (30.48 m)', active: true},
        {name: 'Surveyor (66 feet) (20.1168 m)', active: true}
    ]

    infrastructure_segment_types = [
        {name: 'Main Line', fta_asset_class: 'Track', active: true},
        {name: 'Sidetrack', fta_asset_class: 'Track', active: true},
        {name: 'Siding', fta_asset_class: 'Track', active: true},
        {name: 'Passing Siding', fta_asset_class: 'Track', active: true},
        {name: 'Yard', fta_asset_class: 'Track', active: true},
        {name: 'Cut', fta_asset_class: 'Guideway', asset_subtype: 'At-Grade', active: true},
        {name: 'Embankment', fta_asset_class: 'Guideway', asset_subtype: 'At-Grade', active: true},
        {name: 'Level', fta_asset_class: 'Guideway', asset_subtype: 'At-Grade', active: true},

        {name: 'Arch', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Through Arch', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Beam', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Viaduct', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Bow String', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Box Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Cable-Stayed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Cantilever', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Cantilever Spar Cable-Stayed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Continuous Span Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Integral', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Extradosed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Plate Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Rigid Frame', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Segmental', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Self-Anchored Suspension', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Side-Spar Cable-Stayed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Suspension', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Transporter', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Trestle', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Truss Arch', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
        {name: 'Tubular', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},

        {name: 'Bored', fta_asset_class: 'Guideway', asset_subtype: 'Tunnel', active: true},
        {name: 'Cut-and-Cover', fta_asset_class: 'Guideway', asset_subtype: 'Tunnel', active: true},
        {name: 'Immersed', fta_asset_class: 'Guideway', asset_subtype: 'Tunnel', active: true},
    ]

    infrastructure_gauge_types = [
        {name: 'Standard', active: true},
        {name: 'Broad', active: true},
        {name: 'Narrow', active: true}
    ]

    infrastructure_reference_rails = [
        {name: 'East (North / South Track)', active: true},
        {name: 'North (East / West Track)', active: true},
        {name: 'Outer', active: true},
        {name: 'Center Line', active: true}
    ]

    infrastructure_bridge_types = [
        {name: 'Fixed', active: true},
        {name: 'Movable (Swing)', active: true},
        {name: 'Movable (Bascule)', active: true},
        {name: 'Movable (Vertical Lift)', active: true},
    ]

    infrastructure_crossings = [
        {name: 'Land', active: true},
        {name: 'Roadway', active: true},
        {name: 'Track', active: true},
        {name: 'Valley', active: true},
        {name: 'Water', active: true},
    ]

    infrastructure_rail_joinings = [
        {name: 'Jointed Track', active: true},
        {name: 'Continuous Welded Rail', active: true}
    ]

    infrastructure_cap_materials = [
        {name: 'Concrete', active: true},
        {name: 'Masonry', active: true},
        {name: 'Steel', active: true},
        {name: 'Timber', active: true}
    ]

    infrastructure_foundations = [
        {name: 'Spread Footing', active: true},
        {name: 'Piles', active: true},
        {name: 'Drilled Shafts', active: true},
        {name: 'Caissons', active: true},
    ]

    ['infrastructure_segment_unit_types', 'infrastructure_chain_types', 'infrastructure_gauge_types', 'infrastructure_reference_rails', 'infrastructure_bridge_types','infrastructure_crossings','infrastructure_rail_joinings', 'infrastructure_cap_materials','infrastructure_foundations'].each do |table_name|
      data = eval(table_name)
      data.each do |row|
        x = table_name.classify.constantize.new(row)
        x.save!
      end
    end

    infrastructure_segment_types.each do |segment_type|
      x = InfrastructureSegmentType.new(segment_type.except(:fta_asset_class, :asset_subtype))
      x.fta_asset_class = FtaAssetClass.find_by(name: segment_type[:fta_asset_class]) if segment_type[:fta_asset_class]
      x.asset_subtype = AssetSubtype.find_by(name: segment_type[:asset_subtype]) if segment_type[:asset_subtype]
      x.save!
    end




  end
end