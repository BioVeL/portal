class ResultController < ApplicationController
  def download
    @result = Result.find(params[:id])
    path = @result.result_filename
    filetype = @result.filetype
    send_file path, :type=>filetype , :name => @result.name
  end
end
