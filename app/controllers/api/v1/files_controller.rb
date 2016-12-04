class Api::V1::FilesController < Api::V1::ApiController
  include AccessControl
  skip_before_action :check_user_level

  api! "파일을 조회한다."
  def show
    attachment = Attachment.find params[:id]
    check_article(attachment.article)
    send_file(attachment.file.url, disposition: "inline")
  end
end
