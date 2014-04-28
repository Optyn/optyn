module Merchants::AppsHelper
  def show_bar_option(render_choice)
    if render_choice.to_s == "2"
      "display:none"
    else
      "display:block"
    end
  end
end