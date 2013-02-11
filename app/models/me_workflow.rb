class MeWorkflow 
  # A model for my experiment workflows
  attr_accessor :id, :my_exp_id, :name, :pack_id, :uri, :content_uri, :title,
    :description, :type, :can_download
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.all
    workflows = []
  end

end
