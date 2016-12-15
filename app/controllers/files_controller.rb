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
    user = User.find_by_username! params[:username]
    if user.profile_image.file.nil?
      render json: {}, status: :not_found and return
    end
    send_file(user.profile_image.url, disposition: "inline")
  end
end
