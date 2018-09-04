AssetsController.class_eval do

  # returns a list of assets for an index view (index, map) based on user selections. Called after
  # a call to set_view_vars
  def get_assets

    params[:sort] ||= 'fta_asset_class_id'

    @fta_asset_class_ids = params[:fta_asset_class_id]
    @fta_asset_class_id = @fta_asset_class_ids.to_i

    asset_class = FtaAssetClass.find_by(id: @fta_asset_class_id)

    unless asset_class.nil?

      if asset_class.class_name == 'RevenueVehicle'
        # klass = RevenueVehicleAssetTableView.includes(:revenue_vehicle, :policy).where(transit_asset_fta_asset_class_id: @fta_asset_class_id)
        klass = RevenueVehicleAssetTableView.where(transit_asset_fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'ServiceVehicle'
        klass = ServiceVehicleAssetTableView.includes(:service_vehicle, :policy)
                    .where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'CapitalEquipment'
        klass = CapitalEquipmentAssetTableView.includes(:capital_equipment, :policy).where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'Facility'
        klass = FacilityPrimaryAssetTableView.includes(:facility, :policy)
                    .where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'Guideway' || asset_class.class_name == 'PowerSignal' || asset_class.class_name == 'Track'
        klass = InfrastructureAssetTableView.includes(:infrastructure, :policy)
                    .where(fta_asset_class_id: @fta_asset_class_id)
      end
    end

    # We only want disposed assets on export
    unless @fmt == 'xls'
      klass = klass.where(transam_asset_disposition_date: nil)
    end

    # Create a class instance of the asset type which can be used to perform
    # active record queries
    @asset_class = klass.name
    @view = "transit_asset_index"

    # here we build the query one clause at a time based on the input params
    unless @org_id == 0
      klass = klass.where(organization_id: @org_id)
    else
      klass = klass.where(organization_id: @organization_list)
    end

    @fta_asset_class_id = params[:fta_asset_class_id].to_i
    unless @fta_asset_class_id == 0
      klass = klass.where(fta_asset_class_id: @fta_asset_class_id)
    end

    unless @id_filter_list.blank?
      klass = klass.where(object_key: @id_filter_list)
    end

    if @transferred_assets
      klass = klass.where('asset_tag = object_key')
    else
      klass = klass.where('asset_tag != object_key')
    end

    unless @spatial_filter.blank?
      gis_service = GisService.new
      search_box = gis_service.search_box_from_bbox(@spatial_filter)
      wkt = "#{search_box.as_wkt}"
      klass = klass.where('MBRContains(GeomFromText("' + wkt + '"), geometry) = ?', [1])
    end

    # See if we got an asset group. If we did then we can
    # use the asset group collection to filter on instead of creating
    # a new query. This is kind of a hack but works!
    unless @asset_group.blank?
      klass = klass.joins(:asset_groups).where(asset_groups: {object_key: @asset_group})
    end

    # Search for only early dispostion proposed assets if flag is on
    if @early_disposition
      klass = klass.joins(:early_disposition_requests).where(asset_events: {state: 'new'})
    end

    # send the query
    @table_view_data = klass.all
  end
end
