class Acl::Interface
  def has_resource? *args
    raise 'Method hasResource? not overridden in ACL child.'
  end

  def is_allowed? *args
    raise 'Method isAllowed? not overridden in ACL child.'
  end
end
