class Result < ActiveRecord::Base
  attr_accessible :depth, :filepath, :filetype, :name, :run_id, :result_file
  # every result is linked to a run, trough run_id
  belongs_to :run

  # after the result details have been written to the DB
  # write the write file to the filesystem
  after_save :store_resultfile
  
  # when data is assigned, store the data in a local
  # private variable for later 
  def result_file=(file_data)
    unless file_data.blank?
      # store the uploaded data into a private instance variable
      @file_data = file_data
    end
  end  
  
  RESULT_STORE = Rails.root.join('public', 'result_store')
  # define the path where workflow files will be written to:
  def result_filename
    File.join RESULT_STORE, self.filepath, "value"
  end
  
  #return the path that contains the workflow file
  def result_filepath
    return "/result_store/#{self.filepath}/value"
  end

  # check if a workflow file exists
  def has_resultfile?
    File.exists?  result_filename
  end
  def self.delete_files(runid)
    file_dir = File.join RESULT_STORE, "#{runid}" 
    FileUtils.rm_rf(file_dir)
  end
  private 
  #the store wffile method is called after the details are saved    
  def store_resultfile
    # verify if there is actually a file to be saved
    if @file_data
      # create the WORKFLOW_STORE Folder if it does not exist
      FileUtils.mkdir_p File.join RESULT_STORE, self.filepath
    # create the file and write the data to the file system
      File.open(result_filename, 'wb') do |f|   
        f.write(@file_data)
      end
      # ensure that the data is only save once by clearing the cache after savig
      @file_data = nil
    end
    puts "no data to save"
  end    
end
