object false

  child :data do 
    child @types => :types do |type|
      node(false){|type| type}
    end

    node :folder_counts do
      {:drafts => @drafts_count, :queued => @queued_count}
    end

    node :shop do
      {name: current_shop.name, logo: current_shop.logo_location, website: current_shop.website}
    end
  end
