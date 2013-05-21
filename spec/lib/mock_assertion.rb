class MockAssertion < Racl::Assertion
  def initialize(return_value)
    @return_value = return_value
  end

  def assert(acl, role = nil, resource = nil, privilege = nil)
    return @return_value
  end
end
