class Acl::Role::Generic
  def initialize(role_id)
    @role_id = role_id.to_s
  end

  def get_role_id
    return @role_id
  end

  def to_s
    return get_role_id()
  end
end
