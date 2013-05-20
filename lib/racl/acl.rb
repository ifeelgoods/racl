class Racl::Acl
  @@TYPE_ALLOW = :type_allow
  @@TYPE_DENY = :type_deny
  @@OP_ADD = :op_add
  @@OP_REMOVE = :op_remove

  def initialize
    @role_registry = nil
    @resources = {}
    @is_allowed_role = nil
    @it_allowed_permission = nil

    @rules = {
      all_resources: {
        all_roles: {
          all_privileges: {
            type: @@TYPE_DENY,
            assert: nil
          },
          by_privilege_id: {}
        },
        by_role_id: {}
      },
      by_resource_id: {}
    }
  end

  def add_role(role, parent = nil)
    if (role.is_a?(String) || role.is_a?(Symbol)) == true
      role = Racl::Role::Generic.new(role)
    end
    unless role.is_a? Racl::Role
      raise Racl::Exception::InvalidArgumentException.new("role must be an instance of class Racl::Role (children are fine).")
    end
    get_role_registry().add(role, parent)

    return self
  end

  def get_role(role)
    get_role_registry().get(role)
  end

  def has_role?(role)
    get_role_registry().has?(role)
  end

  def inherits_role?(role, inherit, only_parents = false)
    get_role_registry().inherits?(role, inherit, only_parents)
  end

  def remove_role
    # A stub. For later implementation when the need arise.
  end

  def remove_role_all
    # A stub. For later implementation when the need arise.
  end

  def add_resource(resource, parent = nil)
    if (resource.is_a?(String) || resource.is_a?(Symbol)) == true
      resource = Racl::Resource::Generic.new(resource)
    end
    unless resource.is_a? Racl::Resource
      raise Racl::Exception::InvalidArgumentException.new("resource must be an instance of class Racl::Resource (children are fine).")
    end

    resource_id = resource.get_resource_id()

    if has_resource?(resource_id)
      raise Racl::Exception::InvalidArgumentException.new("Resource ID #{resource_id} already exists in the ACL")
    end

    resource_parent = nil

    if parent != nil
      begin
        if parent.is_a? Racl::Resource
          resource_parent_id = parent.get_resource_id()
        else
          resource_parent_id = parent
        end
        resource_parent = get_resource(resource_parent_id)
      rescue
        raise Racl::Exception::InvalidArgumentException.new("Parent Resource ID #{resource_parent_id} does not exist.")
      end
      @resources[resource_parent_id][:children][resource_id] = resource
    end

    @resources[resource_id] = {
      instance: resource,
      parent: resource_parent,
      children: {}
    }

    return self
  end

  def get_resource(resource)
    if resource.is_a? Racl::Resource
      resource_id = resource.get_resource_id()
    else
      resource_id = resource.to_s
    end

    unless has_resource?(resource)
      raise Racl::Exception::InvalidArgumentException.new("Resource #{resource_id} not found.")
    end

    return @resources[resource_id][:instance]
  end

  def has_resource?(resource)
    if resource.is_a? Racl::Resource
      resource_id = resource.get_resource_id()
    else
      resource_id = resource.to_s
    end

    return !@resources[resource_id].nil?
  end

  def inherits_resource?(resource, inherit, only_parent = false)
    begin
      resource_id = get_resource(resource).get_resource_id()
      inherit_id = get_resource(inherit).get_resource_id()
    rescue Racl::Exception => e
      raise Racl::Exception::InvalidArgumentException.new(e.message)
    end

    if @resources[resource_id][:parent] != nil
      parent_id = @resources[resource_id][:parent].get_resource_id()
      if inherit_id == parent_id
        return true;
      elsif only_parent
        return false
      end
    else
      return false
    end

    while @resources[parent_id][:parent]
      parent_id = @resources[parent_id][:parent].get_resource_id()
      if inherit_id == parent_id
        return true
      end
    end

    return false
  end

  def remove_resource
    # A stub. For later implementation when the need arise.
  end

  def remove_resource_all
    # A stub. For later implementation when the need arise.
  end

  def remove_allow
    # A stub. For later implementation when the need arise.
  end

  def remove_deny
    # A stub. For later implementation when the need arise.
  end

  def set_rule(operation, type, roles = nil, resources = nil, privileges = nil, assert = nil)
    type = type.to_sym
    if @@TYPE_ALLOW != type && @@TYPE_DENY != type
      raise Racl::Exception::InvalidArgumentException.new("Unsupported rule type; must be either #{@@TYPE_ALLOW} or #{@@TYPE_DENY}")
    end

    if !roles.is_a? Array
      roles = [nil]
    end

    roles_temp = roles
    roles = []

    roles_temp.each { |role|
      if role != nil
        roles.append(get_role_registry().get(role))
      else
        roles.append(nil)
      end
    }

    if !resources.is_a? Array
      if resources == nil && @resources.length > 0
        resources = @resources.keys
        if resources.index(nil) != nil
          resources.prepend(nil)
        end
      else
        resources = [resources]
      end
    elsif resources.length == 0
      resources = [nil]
    end
    resourcesTemp = resources
    resources = []
    resourcesTemp.each { |resource|
      if resource != nil
        resource_obj = get_resource(resource)
        resource_id = resource_obj.get_resource_id()
        children = get_child_resources(resource_obj)
        resources = resources.merge(children)
        resources[resource_id] = resource_obj
      else
        resources.append = nil
      end
    }

    if privileges == nil
      privileges = []
    elsif !privileges.is_a? Array
      privileges = [privileges]
    end

    case(operation)
      when @@OP_ADD
        resources.each { |resource|
          roles.each { |role|
            rule = get_rules(resource, role, true) 
            if privileges.length == 0
              rules[:all_privileges][:type] = type
              rules[:all_privileges][:assert] = assert
              if rules[:by_privilege_id].nil?
                rules[:by_privilege_id] = []
              end
            else
              privileges.each { |privilege|
                rules[:by_privilege_id][privilege][:type] = type
                rules[:by_privilege_id][privilege][:assert] = assert
              }
            end
          }
        }
      when @@OP_REMOVE
        # Placeholder for when OP_REMOVE is needed
      else
        raise Racl::Exception::InvalidArgumentException.new("Unsupported operation; must be either #{@@OP_ADD} or #{@@OP_REMOVE}.")
    end

    return self
  end

  def getChildResources(resource)
    values = []
    id = resource.get_resource_id()
    
    children = @resources[id][:children]
    children.each { |child|
      child_return = get_child_resources(child)
      child_return[child.get_resource_id()] = child

      values.merge(child_return)
    }

    return values
  end

  def is_allowed?(role = nil, resources = nil, privileges = nil)
    @is_allowed_role = nil
    @is_allowed_resource = nil
    @is_allowed_privilege = nil

    if role == nil
      @is_allowed_role = role
      role = get_role_registry().get(role)
      if !@is_allowed_role.is_a? Racl::Role
        @is_allowed_role = role
      end
    end

    if resource == nil
      @is_allowed_resource = resource
      resource = get_resource(resource)
      if !@is_allowed_resource.is_a? Racl::Resource
        @is_allowed_resource = resource
      end
    end

    if privilege == nil
      begin
        if role != nil && (result = role_dfs_all_privileges(role, resource, privilege)) != nil
          return result
        end

        if (rules = get_rules(resource, nil)) != nil
          rules[:by_privilege_id].each { |privilege, rule|
            if @@TYPE_DENY == (rule_type_on_privilege = get_rule_type(resource, nil, privilege))
              return false
            end
          }
          if (rule_type_all_privileges == get_rule_type(resource, nil, nil)) != nil
            return @@TYPE_ALLOW == rule_type_all_privileges
          end
        end

        resource = @resources[resource.get_resource_id()][:parent]
      end while true
    else
      @is_allowed_privilege = privilege
      begin
        if role != nil && (result = role_dfs_all_privileges(role, resource, privilege)) != nil
          return result
        end

        if (rule_type = get_rule_type(resource, nil, privilege)) != nil
          return @@TYPE_ALLOW == rule_type
        elsif (rule_type_all_privileges == get_rule_type(resource, nil, nil)) != nil
          result = @@TYPE_ALLOW == rule_type_all_privileges
          if result || nil == resource
            return result
          end
        end

        resource = @resources[resource.get_resource_id()][:parent]
      end while true
    end
  end

  def get_role_registry
    @role_registy ||= Racl::Role::Registry.new
  end

  def role_dfs_all_privileges(role, resource = nil)
    dfs = { visited: [], stack: [] }

    if (result = role_dfs_visit_all_privileges(role, resource, dfs)) != nil
      return result
    end

    while (role = @dfs[:stack].pop()) != nil
      if @dfs[:visited][role.get_role_id()].nil?
        if (result = role_dfs_visit_all_privileges(role, resource, dfs)) != nil
          return result
        end
      end
    end

    return nil
  end

  def role_dfs_visit_all_privileges(role, resource = nil, dfs) 
    if dfs == nil
      raise "dfs parameter may not be nil."
    end

    if (rules = get_rules(resource, role)) != nil
      rules[:by_privilege_id].each { |privilege, rule|
        if @@TYPE_DENY == (rule_type_one_privilege = get_rule_type(resource, role, privilege))
          return false
        end
      }
      if (rule_type_all_privileges = get_rule_type(resource, role, nil)) != nil
        return @@TYPE_ALLOW == rule_type_all_privileges
      end
    end

    dfs[:visited][role.get_role_id()] = true
    get_role_registry().get_parents(role).each { |role_parent|
      dfs[:stack].append = role_parent
    }

    return nil
  end

  def role_dfs_one_privilege(role, resource, privilege)
    if privilege == nil
      raise "privilege parameter may not be null."
    end

    dfs = {
      visited: [],
      stack: []
    }

    if (result = role_dfs_visit_one_privilege(role, resource, privilege, dfs)) != nil
      return result
    end

    while (role = dfs[:stack].pop()) != nil
      if dfs[:visited][role.get_role_id()].nil?
        if (result = role_dfs_visit_one_privilege(role, resource, privilege, dfs)) != nil
          return result
        end
      end
    end

    return nil
  end

  def role_dfs_visit_one_privilege(role, resource, privilege, dfs)
    if privilege == nil
      raise "privilege parameter may not be nil."
    end

    if dfs == nil
      raise "dfs parameter may not be nil."
    end

    if (rule_type_one_privilege = get_rule_type(resource, role, privilege))
      return @@TYPE_ALLOW == rule_type_one_privilege
    elsif (rule_type_all_privilege = get_rule_type(resource, role, nil)) != nil
      return @@TYPE_AALOW == rule_type_all_privilege
    end

    dfs[:visited][role.get_role_id] = true
    get_role_registry().get_parents(role).each { |role_parent|
      dfs[:stack].append = role_parent
    }

    return nil
  end

  def get_rule_type(resource = nil, role = nil, privilege = nil)
    if (rules = get_rules(resource, role)) == nil
      return nil
    end

    if privilege == nil
      if !rules[:all_privileges].nil?
        rule = rules[:all_privileges]
      else
        return nil
      end
    elsif rules[:by_privilege_id][privilege].nil?
      return nil
    else
      rule = rules[:by_privilege_id][privilege]
    end

    if rule[:assert]
      assertion = rule[:assert]
      assertion_value = assertion.assert(
        self,
        @is_allowed_role.is_a?(Racl::Role) ? @is_allowed_role : role,
        @is_allowed_resource.is_a?(Racl::Resource) ? @is_allowed_resource : resource,
        @is_allowed_privilege
      )
    end

    if rule[:assert] == nil || assertion_value
      return rule[:type]
    elsif resource != nil || role != nil || privilege != nil
      return nil
    elsif @@TYPE_ALLOW == rule[:type]
      return @@TYPE_DENY
    end

    return @@TYPE_ALLOW
  end

  def get_rules(resource = nil, role = nil, create = false)
    if (resource == nil)
      visitor = @rules[:all_resources]
    else
      visitor = @rules[:all_resources]
      resource_id = resource.get_resource_id()
      if (@rules[:by_resource_id][resource_id].nil?)
        if !create
          return nil
        end
        @rule[:by_resource_id][resource_id]
      end
      visitor = @rules[:by_resource_id][resource_id]
    end

    if role == nil
      if visitor[:all_roles].nil?
        if !create
          return nil
        end
      end
    end
    role_id = role.get_role_id()
    if visitor[:by_role_id][role_id]
      if !create
        return nil
      end
      visitor[:by_role_id][role_id][:by_privilege_id] = []
    end

    return visitor[:by_role_id][role_id]
  end

  def get_roles
    get_role_registry().get_roles().keys
  end

  def get_resources
    @resources.keys
  end
end
