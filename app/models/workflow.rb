require 't2flow/model'
require 't2flow/parser'
require 't2flow/dot'

class Workflow < ActiveRecord::Base
  attr_accessible :author, :description, :name, :title, :workflow_file, :wf_file
  # a workflow can have many runs
  has_many :runs
  # after the workflow details have been written to the DB
  # write the workflow file to the filesystem
  after_save :store_wffile
  # when data is assigned via the upload, store the data in a local
  # private variable for later and assing the file name to workflow_file
  def wf_file=(file_data)
    unless file_data.blank?
      # store the uploaded data into a private instance variable
      @file_data = file_data
      # set the value of workflow file to that of the original
      # workflow file name
      self.workflow_file = file_data.original_filename.downcase
    end
  end  
  
  WORKFLOW_STORE = Rails.root.join('public', 'workflow_store')
  # define the path where workflow files will be written to:
  def workflow_filename
    File.join WORKFLOW_STORE, "#{id}" , "#{workflow_file}"
  end
  
  #return the path that contains the workflow file
  def workflow_filepath
    return "/workflow_store/#{id}/#{workflow_file}"
  end

  # check if a workflow file exists
  def has_workflowfile?
    File.exists?  workflow_filename
  end
  # check if workflow has parameters
  def has_parameters?
    model = T2Flow::Parser.new.parse(File.open(workflow_filename))
    model.all_sources().size > 0
  end
  # get the workflow file
  def get_file
    File.open(workflow_filename).read
  end
  # delete the workflow file
  def delete_files
    file_dir = File.join WORKFLOW_STORE, "#{id}" 
    FileUtils.rm_rf(file_dir)
  end
  # get the workflow model
  def get_model
    T2Flow::Parser.new.parse(File.open(workflow_filename))
  end
  def get_details_from_model  
      model = T2Flow::Parser.new.parse(File.open(workflow_filename))
      self.name = model.name
      self.title = model.annotations.titles.to_s
      self.author = model.annotations.authors.to_s
      self.description = model.annotations.descriptions.to_s
      puts model
      puts self.name
  end 
  def connects_to_r_server?
    response = false
    for df in self.get_model.dataflows do
      for indv_proc in df.processors do
        if indv_proc.type == "rshell"
          response = true
          break
        end
      end
    end  
    return response
  end 
  def get_inputs
    sources = {}
    descriptions = {}
    # get the workflow t2flow model
    model = get_model
    # collect the sources and their descriptions
    model.sources().each{|source|
      example_values = source.example_values
      if ((!example_values.nil?) && (example_values.size == 1)) then
        sources[source.name] = example_values[0]
      else
        sources[source.name] = ""
      end
      description_values = source.descriptions
      if ((!description_values.nil?) && (description_values.size == 1)) then
        descriptions[source.name] = description_values[0]
      else
        descriptions[source.name] = ""
      end  
    }
    return [sources,descriptions]
  end
  private 
  #the store wffile method is called after the details are saved    
  def store_wffile
    # verify if there is actually a file to be saved
    if @file_data
      # create the WORKFLOW_STORE Folder if it does not exist
      FileUtils.mkdir_p File.join WORKFLOW_STORE, "#{id}"
    # create the file and write the data to the file system
      File.open(workflow_filename, 'wb') do |f|   
        f.write(@file_data.read)
      end
      # ensure that the data is only save once by clearing the cache after savig
      @file_data = nil
    end
  end
  
end
