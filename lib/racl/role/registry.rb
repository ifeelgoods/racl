class Racl::Role::Registry
  def initialize
    @roles = {}
  end

  def add(role, parents = nil)
    role_id = role.get_role_id()

    if has?(role_id)
      raise Racl::Exception::InvalidArgumentException.new("Role id #{role_id} already exists in the registry")
    end

    role_parents = {}

    if parents != nil
      if !parents.is_a? Array
        parents = [parents]
      end
      parents.each { |parent|
        begin
          if parent.is_a? Racl::Role
            role_parent_id = parent.get_role_id()
          else
            role_parent_id = parent
          end
          role_parent = get(role_parent_id)
        rescue
          raise Racl::Exception::InvalidArgumentException.new("Parent role id #{role_parent_id} does not exist")
        end
        role_parents[role_parent_id] = role_parent
        @roles[role_parent_id][:children][role_id] = role
      }
    end

    @roles[role_id] = {
      instance: role,
      parents: role_parents,
      children: {}
    }

    return self
  end

  def get(role)
    if role.is_a? Racl::Role
      role_id = role.get_role_id()
    else
      role_id = role.to_s
    end

    if !has?(role)
      raise Racl::Exception::InvalidArgumentException.new("Role #{role_id} not found.")
    end

    return @roles[role_id][:instance]
  end

  def has?(role)
    if role.is_a? Racl::Role
      role_id = role.get_role_id()
    else
      role_id = role
    end

    return !@roles[role_id].nil?
  end

  def get_parents(role)
    role_id = get(role).get_role_id()

    @roles[role_id][:parents]
  end

  def inherits?(role, inherit, only_parents = false)
    begin
      role_id = get(role).get_role_id()
      inherit_id = get(inherit).get_role_id()
    rescue Exception => e
      raise Racl::Exception::InvalidArgumentException.new(e.message)
    end

    inherits = !@roles[role_id][:parents][inherit_id].nil?

    if inherits || only_parents
      return inherits
    end

    @roles[role_id][:parents].each { |parent_id, parent|
      if inherits?(parent_id, inherit_id)
        return true
      end
    }

    return false
  end

  def remove(role)
    # Stub
  end

  def remove_all()
    # Stub
  end

  def get_roles()
    return @roles
  end
end
