module PasswordSync
  extend ActiveSupport::Concern

  def sync_password(username, password, new_password)
    http = Net::HTTP.new("id.snucse.org", 443)
    http.use_ssl = true
    resp = http.post("/Authentication/Login.aspx", "login_type=member_login&referrer=&redirect_mode=keep&secure=on&member_account=#{username}&member_password=#{password}")
    if resp.code == "200"
      return
    end
    resp2 = http.get("/User/ModifyPasswordForm.aspx?account=#{username}", {"Cookie" => resp["set-cookie"]})
    doc = Nokogiri::HTML(resp2.body)
    uid = doc.css("input[name=uid]").attr("value").value
    http.post("/User/ModifyPasswordSubmit.aspx", "uid=#{uid}&current_password=#{password}&new_password=#{new_password}&new_password_confirm=#{new_password}", {"Cookie" => resp["set-cookie"]})
  end
end
