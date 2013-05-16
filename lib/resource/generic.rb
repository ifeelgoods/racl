class Acl::Resource::Generic < Acl::Resource::Interface
  def initialize(resource_id)
    @resource_id = resource_id.to_s
  end

  def get_resource_id
    return @resource_id
  end

  def to_s
    return get_resource_id()
  end
end
