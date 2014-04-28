class AddCustomCssAndLabelForOauthApplications < ActiveRecord::Migration
def change
    add_column(:oauth_applications, :custom_css, :text, :default => '#optyn-email-form { margin: 10px 0; }
#optyn-email-form #user_name,
#optyn-email-form #user_email {
width: 180px;
padding: 0 10px;
border: solid 2px #d4d4d4;
background-color: #fbfbfb;
box-shadow: none;
color: #333333;
min-height: 35px;
font-size: 17px;
font-weight: 300;
line-height: 20px;
}
#optyn-email-form #user_name,
#optyn-email-form #user_email { margin-right: 5px; }
#optyn-email-form input:last-child { margin-right: 0; }
#optyn-email-form input[type="submit"] {
background-color: #64aaef;
color: #ffffff;
min-height: 35px;
font-size: 16px;
font-weight: 300;
line-height: 20px;
border: 0;
padding: 5px;
}
#optyn-email-form input[type="submit"]:hover {
background-color: #3691ea;
}


')
    add_column(:oauth_applications, :label_ids, :text)
    add_column(:oauth_applications, :show_name, :boolean, :default => false)
  end
end
