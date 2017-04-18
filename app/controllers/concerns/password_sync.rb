module PasswordSync
  extend ActiveSupport::Concern

  def sync_registration(username, name, birthday, bs_number, email, phone_number)
    http = Net::HTTP.new("id.snucse.org", 443)
    http.use_ssl = true
    year = birthday[0..3]
    month = birthday[5..6]
    date = birthday[8..9]
    http.post("/Account/JoinSubmit.aspx", {terms: "on", name: name, birth_year: year, birth_month: month, birth_date: date, account: username, bs_number: bs_number, ms_number: nil, phd_number: nil, graduate_year: nil, graduate_month: nil, email: email, phone: phone_number}.to_query)
  end

  def check_password(username, password)
    if Rails.env.production?
      http = Net::HTTP.new("id.snucse.org", 443)
      http.use_ssl = true
      resp = http.post("/Authentication/Login.aspx", {login_type: "member_login", referrer: nil, redirect_mode: "keep", secure: "on", member_account: username, member_password: password}.to_query)
      resp.code != "200"
    else
      password == username + username
    end
  end

  def sync_password(username, password, new_password)
    http = Net::HTTP.new("id.snucse.org", 443)
    http.use_ssl = true
    resp = http.post("/Authentication/Login.aspx", {login_type: "member_login", referrer: nil, redirect_mode: "keep", secure: "on", member_account: username, member_password: password}.to_query)
    if resp.code == "200"
      return
    end
    resp2 = http.get("/User/ModifyPasswordForm.aspx?account=#{username}", {"Cookie" => resp["set-cookie"]})
    doc = Nokogiri::HTML(resp2.body)
    uid = doc.css("input[name=uid]").attr("value").value
    http.post("/User/ModifyPasswordSubmit.aspx", {uid: uid, current_password: password, new_password: new_password, new_password_confirm: new_password}.to_query, {"Cookie" => resp["set-cookie"]})
  end
end
