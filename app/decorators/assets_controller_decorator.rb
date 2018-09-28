AssetsController.class_eval do

  def add_index_breadcrumbs
    fta_asset_class = FtaAssetClass.find_by(id: params[:fta_asset_class_id])
    if fta_asset_class
      add_breadcrumb "#{fta_asset_class.fta_asset_category}", '#'
      add_breadcrumb "#{fta_asset_class}"
    end
  end

  def add_breadcrumbs
    add_breadcrumb "#{@asset.fta_asset_category}", '#'
    add_breadcrumb "#{@asset.fta_asset_class}", inventory_index_path(:asset_type => 0, :asset_subtype => 0, :asset_group => 0, :fta_asset_class_id => @asset.fta_asset_class.id)
    add_breadcrumb "#{@asset.fta_asset_class.name.singularize} Profile"
  end

  # returns a list of assets for an index view (index, map) based on user selections. Called after
  # a call to set_view_vars
  def get_assets

    @fta_asset_class_ids = params[:fta_asset_class_id]
    @fta_asset_class_id = @fta_asset_class_ids.to_i

    asset_class = FtaAssetClass.find_by(id: @fta_asset_class_id)

    unless asset_class.nil?

      if asset_class.class_name == 'RevenueVehicle'
        # klass = RevenueVehicleAssetTableView.includes(:revenue_vehicle, :policy).where(transit_asset_fta_asset_class_id: @fta_asset_class_id)
        query = RevenueVehicleAssetTableView.includes(:revenue_vehicle, :policy).where(transit_asset_fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'ServiceVehicle'
        query = ServiceVehicleAssetTableView.where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'CapitalEquipment'
        query = CapitalEquipmentAssetTableView.where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'Facility'
        query = FacilityPrimaryAssetTableView.includes(:facility, :component, :policy).where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'Guideway' || asset_class.class_name == 'PowerSignal' || asset_class.class_name == 'Track'
        query = InfrastructureAssetTableView.where(fta_asset_class_id: @fta_asset_class_id)
      end
    end

    if asset_class.nil?
      if @early_disposition
        @early_disposition = true
        # query = TransamAsset.joins(:early_disposition_requests).where(asset_events: {state: 'new'})
        query = TransitAsset.joins(:early_disposition_requests).where(asset_events: {state: 'new'})
      end
      if @transferred_assets
        query = TransitAsset.joins(:transam_asset).where('asset_tag = object_key')
      else
        query = TransitAsset.joins(:transam_asset).where('asset_tag != object_key')
      end
    end

    # We only want disposed assets on export
    unless @fmt == 'xls' || @transferred_assets || @early_disposition
      query = query.where(transam_asset_disposition_date: nil)
    end

    # Create a class instance of the asset type which can be used to perform
    # active record queries
    @asset_class = query.name
    @view = "transit_asset_index"

    # here we build the query one clause at a time based on the input params
    unless @org_id == 0
      query = query.where(organization_id: @org_id)
    else
      query = query.where(organization_id: @organization_list)
    end

    unless @id_filter_list.blank?
      query = query.where(object_key: @id_filter_list)
    end

    unless @spatial_filter.blank?
      gis_service = GisService.new
      search_box = gis_service.search_box_from_bbox(@spatial_filter)
      wkt = "#{search_box.as_wkt}"
      query = query.where('MBRContains(GeomFromText("' + wkt + '"), geometry) = ?', [1])
    end

    # See if we got an asset group. If we did then we can
    # use the asset group collection to filter on instead of creating
    # a new query. This is kind of a hack but works!
    unless @asset_group.blank?
      query = query.joins(:asset_groups).where(asset_groups: {object_key: @asset_group})
    end

    # Search for only early dispostion proposed assets if flag is on
    if @early_disposition
      query = query.joins(:early_disposition_requests).where(asset_events: {state: 'new'})
    end

    if @transferred_assets
      query = query.where('transam_asset_asset_tag = object_key')
    else
      query = query.where('transam_asset_asset_tag != object_key')
    end

    # @total_results = query.count
    return query
  end

  def index_rows_as_json
    multi_sort = params[:multiSort]

    if multi_sort.nil?

      sort_name = format_methods_to_sort_order(params[:sort])
      sorting_string = nil

      unless sort_name.nil?
        sorting_string = "#{sort_name} #{params[:order]}"
      end


    else

      sorting = []

      multi_sort.each { |x|

        sort_name = format_methods_to_sort_order(x[1]['sortName'])

        sorting << "#{sort_name} #{x[1]['sortOrder']}"
      }
      sorting_string = sorting.join(' , ')

    end

    if sorting_string.nil?
      @assets.order(sorting_string.to_s).limit(params[:limit]).offset(params[:offset]).as_json(user: current_user, include_early_disposition: @early_disposition)
    else
      @assets.order(sorting_string.to_s).limit(params[:limit]).offset(params[:offset]).as_json(user: current_user, include_early_disposition: @early_disposition)
    end

  end

  def format_methods_to_sort_order(sort_name)

    case @assets.name
    when 'RevenueVehicleAssetTableView'
      return RevenueVehicleAssetTableView.format_methods_to_sort_order_columns(sort_name)
    when 'ServiceVehicleAssetTableView'
      return ServiceVehicleAssetTableView.format_methods_to_sort_order_columns(sort_name)
    when 'CapitalEquipmentAssetTableView'
      return CapitalEquipmentAssetTableView.format_methods_to_sort_order_columns(sort_name)
    when 'FacilityPrimaryAssetTableView'
      return FacilityPrimaryAssetTableView.format_methods_to_sort_order_columns(sort_name)
    when 'InfrastructureAssetTableView'
      return InfrastructureAssetTableView.format_methods_to_sort_order_columns(sort_name)
    end

  end
end
