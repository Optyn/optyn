class AddCustomCssAndLabelForOauthApplications < ActiveRecord::Migration
def change
    add_column(:oauth_applications, :custom_css, :text, :default => '#optyn_button_wrapper .optyn-text { float: left; padding-left: 150px; padding-top: 20px; color: white; font-weight: bold; text-align: center; font-family:"Arial, Verdana", Arial, sans-serif; font-size: 16px; }
#optyn_button_wrapper .optyn-button { }
#close_optyn_button { float: right; font-weight: bold; margin: 0px; padding-right: 30px; padding-top: 20px; color: white; vertical-align: middle; }
#close_optyn_button a { color: white; position: absolute; z-index: 100; }
#optyn-container { float:left; padding-left: 100px; padding-top: 12px; }
#optyn-container form { margin: 0px; }
#optyn-container form input[type="submit"] {
  background: blue; border-radius: 4px; display: inline-block; height: 35px; top: 4px; color: red; font-size: 15px; border: 1px #304d58; font-weight: bold; padding-left: 10px; padding-right: 10px;
  position: absolute; top: 0; right: 0;
}
#optyn-container form input:hover[type="Submit"] { background: #80d81c; color: #fff; }
#optyn-container h4 { margin: 0px; color: white; }
#optyn-email-form { position: relative; width: 100%; }
#optyn-email-form input[type="text"],
#optyn-email-form input[type="email"] { width: 50%; }
#optyn-email-form input[type="text"] { padding-right: 90px; }
')
    add_column(:oauth_applications, :label_ids, :text)
    add_column(:oauth_applications, :show_name, :boolean, :default => false)
  end
end
