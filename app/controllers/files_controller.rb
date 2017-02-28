class FilesController < ApplicationController
  api! "파일을 조회한다."
  def show
    attachment = Attachment.find_by_key! params[:key]
    if attachment.file_identifier != params[:file]
      render json: {}, status: :not_found and return
    end
    send_file(attachment.file.url, disposition: "inline")
  end

  api! "프로필 이미지를 조회한다."
  error code: 404, desc: "설정된 프로필 이미지가 없을 때"
  def show_profile_image
    if params[:username] == "default"
      send_file("#{Rails.root}/public/default.png", disposition: "inline")
    else
      user = User.find_by_username! params[:username]
      url = "#{Rails.root}/public/default.png"
      url = user.profile_image.thumb.url unless user.profile_image.thumb.file.nil?
      send_file(url, disposition: "inline")
    end
  end
end
