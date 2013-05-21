class TestPrivilegeAssertion < Racl::Assertion
  def assert(acl, role = nil, resource = nil, privilege = nil)
    if (privilege != :privilege)
      return false
    end
    
    return true
  end
end
