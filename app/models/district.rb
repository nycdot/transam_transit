class District < ActiveRecord::Base

  # Associations
  belongs_to :district_type

  validates :name,              :presence => true
  validates :code,              :presence => true, :uniqueness => true
  validates :description,       :presence => true
  validates :district_type_id,  :presence => true

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s

    name_string = ""

    if(district_type.name == 'County' || district_type.name == 'UZA')
      name_string = "#{name} #{district_type.to_s}"
    else
      name_string = name
    end

    name_string
  end

  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR code = ? OR description = ?', text, text, text).first
    else
      val = "%#{text}%"
      x = where('name LIKE ? OR code LIKE ? OR description LIKE ?', val, val, val).first
    end
    x
  end

end
