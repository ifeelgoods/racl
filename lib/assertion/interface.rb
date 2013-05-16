class Assertion::Interface
  def assert(acl, role = nil, resource = nil, privilege = nil)
    raise 'Method assert not overridden in Assertion child.'
  end
end
