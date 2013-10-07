object false

  child :data do
    node :folder_counts do
      {:drafts => @drafts_count, :queued => @queued_count}
    end
  end
