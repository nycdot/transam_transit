class SupportFacility < FtaFacility

  # Enable auditing of this model type. Only monitor uodate and destroy events
  has_paper_trail :on => [:update, :destroy]

  # Callbacks
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations common to all service facilities
  #------------------------------------------------------------------------------

  # Each support facility has a capacity type
  belongs_to                :facility_capacity_type

  validates                 :facility_capacity_type,       :presence => :true
  validates                 :pcnt_capital_responsibility, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.find_by_class_name(self.name).id) }

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  SEARCHABLE_FIELDS = [
  ]
  CLEANSABLE_FIELDS = [
  ]
  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :facility_capacity_type_id
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end

  def searchable_fields
    a = []
    a << super
    SEARCHABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    CLEANSABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a suppoert facility
  def set_defaults
    super
    self.asset_type ||= AssetType.find_by_class_name(self.name)
  end

end
