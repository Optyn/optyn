module AppDefaultCss
  def default_app_css
    defualt_css = <<-CSS
      #optyn_button_wrapper .optyn-text { 
        float: left; 
        padding-left: 150px; 
        padding-top: 20px; 
        color: white; 
        font-weight: bold; 
        text-align: center; 
        font-family:"Arial, Verdana", Arial, sans-serif; 
        font-size: 16px; 
      } 
      #optyn_button_wrapper .optyn-button { }  
      #close_optyn_button { 
        float: right; 
        font-weight: bold; 
        margin: 0px; 
        padding-right: 30px; 
        padding-top: 20px; 
        color: white; 
        vertical-align: middle; 
      } 
      #close_optyn_button a { 
        color: white; 
        position: absolute; 
        z-index: 100; 
      } 
      #optyn-container { 
        float:left; 
        padding-left: 100px; 
        padding-top: 12px; 
      } 
      #optyn-container form { 
        margin: 0px; 
      } 
      #optyn-container form input[type="submit"] { 
        background: #6BC704; 
        border-radius: 4px; 
        display: inline-block; 
        height: 35px; top: 4px; 
        color: #ffffff; 
        font-size: 15px; 
        border: 1px #304d58; 
        font-weight: bold; 
        padding-left: 10px; 
        padding-right: 10px; 
      } 
      #optyn-container form input:hover[type="Submit"] { 
        background: #80d81c; 
        color: #fff;
      }  
      #optyn-container h4 { 
        margin: 0px; 
        color: white; 
      }

      #optyn-email-form { 
        margin: 10px 0; 
      }
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
      #optyn-email-form #user_email { 
        margin-right: 5px; 
      }
      #optyn-email-form input:last-child { 
        margin-right: 0; 
      }
      #optyn-email-form input[type="submit"] {
        background-color: #64aaef;
        color: #ffffff;
        min-height: 35px;
        font-size: 16px;
        font-weight: 300;
        line-height: 20px;
        border: 0;
        padding: 5 15 5 15px;
      }
      #optyn-email-form input[type="submit"]:hover {
        background-color: #3691ea;
      }
    CSS
  end
end