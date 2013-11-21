object false

  child :data do
    node :folder_counts do
      {:drafts => @drafts_count, :queued => @queued_count}
    end

    node :select_list do
      {:labels => @labels}
    end

    node :receivers do
      {labels: current_shop.inactive_label, count: current_shop.active_connection_count}
    end
  end
