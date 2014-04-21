object false

  child :data do
    node :folder_counts do
      {:drafts => @drafts_count, :queued => @queued_count,:waiting_for_approval => @approves_count}
    end

    node :select_list do
      {:labels => @labels}
    end

    node :receivers do
      {labels: current_shop.inactive_label, count: current_shop.active_connection_count}
    end

    node :shop do
      {name: current_shop.name, logo: current_shop.logo_location, website: current_shop.website}
    end
  end
