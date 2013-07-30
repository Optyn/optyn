class IdentifierAssigner
  def self.assign_random(model_instance, attr)
    model_instance.send((attr.to_s + "=").to_sym, UUIDTools::UUID.random_create.to_s.gsub(/[-]/, ""))
  end
end