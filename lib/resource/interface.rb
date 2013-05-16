class Acl::Resource::Interface
  def get_resource_id
    raise 'Method get_resource_id not overridden in Resource child.'
  end
end
