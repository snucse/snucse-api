module AccessControl
  extend ActiveSupport::Concern

  def check_profile(profile)
    return if @user.active?
    render json: {}, status: :not_found if Follow.where(user_id: @user.id, profile_id: profile.id).empty?
  end

  def check_article(article)
    return if @user.active?
    render json: {}, status: :not_found if (article.profiles & @user.profiles).empty?
  end

  def check_comment(comment)
    return if @user.active?
    check_article(comment.article)
  end
end
