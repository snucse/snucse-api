class FilesController < ApplicationController
  api! "파일을 조회한다."
  def show
    attachment = Attachment.find_by_key! params[:key]
    if attachment.file_identifier != params[:file]
      render json: {}, status: :not_found and return
    end
    send_file(attachment.file.current_path, disposition: "inline")
  end

  api! "프로필 이미지를 조회한다."
  error code: 404, desc: "설정된 프로필 이미지가 없을 때"
  def show_profile_image
    if params[:username] == "default"
      send_file("#{Rails.root}/public/default.png", disposition: "inline")
    else
      user = User.find_by_username! params[:username]
      url = "#{Rails.root}/public/default.png"
      url = user.profile_image.thumb.current_path unless user.profile_image.thumb.file.nil?
      send_file(url, disposition: "inline")
    end
  end

  api! "구 스누씨 형식 URL로 된 파일을 조회한다."
  def show_legacy
    legacy_object = LegacyObject.find_by_uid(params[:uid])
    render nothing: true, status: :not_found if legacy_object.nil? or legacy_object.target_type != "Attachment"
    send_file(legacy_object.target.file.current_path, disposition: "inline")
  end
end
