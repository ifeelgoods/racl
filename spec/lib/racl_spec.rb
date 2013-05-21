require 'spec_helper'

describe Racl do
  describe "Racl" do
    before(:each) do
      @acl = Racl::Acl.new
    end

    context "Roles" do
      before(:each) do
        @role_guest = Racl::Role::Generic.new('guest')
      end

      it "should add and get a role" do
        role = @acl.add_role(@role_guest).get_role(@role_guest.get_role_id())
        role.should eq(@role_guest)
        role = @acl.get_role(@role_guest)
        role.should eq(@role_guest)
      end

      it "should add and get a role by string" do
        role = @acl.add_role('area').get_role('area')
        role.is_a?(Racl::Role).should be_true
        role.get_role_id().should eq('area')
      end

      it "should remove a role"

      it "should throw an error when removing a non-existent role."

      it "should remove all roles"

      it "should raise exception when trying to inherit non-existent parent" do
        expect { @acl.add_role(Racl::Role::Generic.new('guest'), 'nonexistent') }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should raise exception when trying to add non-Racl::Role::Generic object or a non-string role" do
        expect { @acl.add_role(Object.new, 'guest') }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should raise exception when a non-existent Role is specified to each parameter of inherits()" do
        @acl.add_role(@role_guest)
        expect { @acl.inherits_role?('nonexistent', @role_guest) }.to raise_error Racl::Exception::InvalidArgumentException
        expect { @acl.inherits_role?(@role_guest, 'nonexistent') }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should test basic Role inheritance" do
        role_guest = @role_guest
        role_member = Racl::Role::Generic.new("member")
        role_editor = Racl::Role::Generic.new("editor")

        role_registry = Racl::Role::Registry.new()
        role_registry.add(role_guest)
        role_registry.add(role_member, role_guest.get_role_id())
        role_registry.add(role_editor, role_member)
        role_registry.get_parents(role_guest).length.should eq(0)

        role_member_parents = role_registry.get_parents(role_member)
        role_member_parents.length.should eq(1)
        role_member_parents['guest'].should_not be_nil

        role_editor_parents = role_registry.get_parents(role_editor)
        role_editor_parents.length.should eq(1)
        
        role_registry.inherits?(role_member, role_guest, true).should be_true
        role_registry.inherits?(role_editor, role_member, true).should be_true
        role_registry.inherits?(role_editor, role_guest).should be_true
        role_registry.inherits?(role_guest, role_member).should be_false
        role_registry.inherits?(role_member, role_editor).should be_false
        role_registry.inherits?(role_guest, role_editor).should be_false
        # TODO:
        # Enable the next few commented lines when role_registry.remove() has been implemented:
        # role_registry.remove(role_member)
        # role_registry.get_parents(role_editor).length.should eq(0)
        # role_registry.inherits?(role_editor, role_guest).should be_false
      end

      it "should test multiple Role inheritance" do
        role_parent1 = Racl::Role::Generic.new('parent1')
        role_parent2 = Racl::Role::Generic.new('parent2')
        role_child = Racl::Role::Generic.new('child')
        role_registry = Racl::Role::Registry.new

        role_registry.add(role_parent1)
        role_registry.add(role_parent2)
        role_registry.add(role_child, [role_parent1, role_parent2])

        role_child_parents = role_registry.get_parents(role_child)
        role_child_parents.length.should eq(2)

        i = 1
        role_child_parents.each { |role_parent_id, role_parent|
          role_parent_id.should eq("parent#{i}")
          i+=1
        }

        role_registry.inherits?(role_child, role_parent1).should be_true
        role_registry.inherits?(role_child, role_parent2).should be_true
        # TODO:
        # Enable the next few commented lines when role_registry.remove() has been implemented:
        # role_registry.remove(role_parent1)
        # role_child_parents = role_registry.get_parents(role_child)
        # role_child_parents.length.should eq(1)
        # role_child_parents['parent2'].should_not be_nil
        # role_registry.inherits?(role_child, role_parent2).should be_true
      end

      it "should not allow duplicate role objects" do
        role_registry = Racl::Role::Registry.new
        expect { role_registry.add(@role_guest).add(@role_guest) }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should not allow duplicate role id" do
        role_registry = Racl::Role::Registry.new
        role_guest2 = Racl::Role::Generic.new('guest')
        expect { role_registry.add(@role_guest).add(role_guest2) }.to raise_error Racl::Exception::InvalidArgumentException
      end
    end

    context "Resources" do
      before(:each) do
        @resource_area = Racl::Resource::Generic.new('area')
      end

      it "should be able to add and retrieve a single resource via the resource object" do
        resource = @acl.add_resource(@resource_area).get_resource(@resource_area.get_resource_id())
        resource.should eq(@resource_area)
        resource = @acl.get_resource(@resource_area)
        resource.should eq(@resource_area)
      end

      it "should be able to add and retrieve a single resource via string name" do
        resource = @acl.add_resource('area').get_resource('area')
        resource.is_a?(Racl::Resource).should be_true
        resource.get_resource_id().should eq('area')
      end

      it "should be able to remove a resource"

      it "should raise an exception when trying to remove a non-existent Resource"

      it "should be able to remove all resources"

      it "should raise an exception when trying to inherit a non-existent Resource" do
        expect { @acl.add_resource(@resource_area, 'nonexistent') }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should raise an exception when a non-Resource object is passed" do
        expect { @acl.add_resource(Object.new) }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should raise an exception when non-existent Resource is specified to each paraameter of #inherits?" do
        @acl.add_resource(@resource_area)
        expect { @acl.inherits_resource?('nonexistent', @resource_area) }.to raise_error Racl::Exception::InvalidArgumentException
        expect { @acl.inherits_resource?(@resource_area, 'nonexistent') }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should test basic Resource inheritance" do
        resource_city = Racl::Resource::Generic.new('city')
        resource_building = Racl::Resource::Generic.new('building')
        resource_room = Racl::Resource::Generic.new('room')
        @acl.add_resource(resource_city)
            .add_resource(resource_building, resource_city.get_resource_id())
            .add_resource(resource_room, resource_building)
        @acl.inherits_resource?(resource_building, resource_city, true).should be_true
        @acl.inherits_resource?(resource_room, resource_building, true).should be_true
        @acl.inherits_resource?(resource_room, resource_city).should be_true
        @acl.inherits_resource?(resource_city, resource_building).should be_false
        @acl.inherits_resource?(resource_building, resource_room).should be_false
        @acl.inherits_resource?(resource_city, resource_room).should be_false
        # TODO:
        # Enable the next few commented lines when acl.remove_resource() has been implemented:
        # @acl.remove_resource(resource_building)
        # @acl.has_resource?(resource_room).should be_false
      end

      it "should not add Resource more than once" do
        expect { @acl.add_resource(@resource_area).add_resource(@resource_area) }.to raise_error Racl::Exception::InvalidArgumentException
      end

      it "should not add two Resources with the same ID" do
        resource_area2 = Racl::Resource::Generic.new('area')
        expect { @acl.add_resource(@resource_area).add_resource(resource_area2) }.to raise_error Racl::Exception::InvalidArgumentException
      end
    end

    context "Acl" do
      it "should raise an exception when a non-existent Role and Resource parameters are specified to #is_allowed?" do
        expect { @acl.is_allowed?('nonexistent') }.to raise_error Racl::Exception::InvalidArgumentException
        expect { @acl.is_allowed?(nil, 'nonexistent') }.to raise_error Racl::Exception::InvalidArgumentException
      end
 
      it "should deny access to everything by default" do
        @acl.is_allowed?().should be_false
      end

      it "should ensure that the default rule obeys its assertion" do
        @acl.deny(nil, nil, nil, Racl::Assertion::Generic.new(false))
        @acl.is_allowed?.should be_true
        @acl.is_allowed?(nil, nil, :some_privilege).should be_true
      end

      it "should ensure that ACL-wide rules (all Roles, Resources, and privileges) work properly" do
        @acl.allow
        @acl.is_allowed?.should be_true
        @acl.deny
        @acl.is_allowed?.should be_false
      end

      it "should by default deny access to a privilege on anything by all" do
        @acl.is_allowed?(nil, nil, :some_privilege).should be_false
      end

      it "should ensure that a privilege allowed for all Roles upon all Resources work properly" do
        @acl.allow(nil, nil, :some_privilege)
        @acl.is_allowed?(nil, nil, :some_privilege).should be_true
      end

      it "should ensure that a privilege denied for all Roles upon all Resources work properly" do
        @acl.allow
        @acl.deny(nil, nil, :some_privilege)
        @acl.is_allowed?(nil, nil, :some_privilege).should be_false
      end

      it "should ensure that multiple privileges work properly" do
        @acl.allow(nil, nil, [:p1, :p2, :p3])
        @acl.is_allowed?(nil, nil, :p1).should be_true
        @acl.is_allowed?(nil, nil, :p2).should be_true
        @acl.is_allowed?(nil, nil, :p3).should be_true
        @acl.is_allowed?(nil, nil, :p4).should be_false
        @acl.deny(nil, nil, :p1)
        @acl.is_allowed?(nil, nil, :p1).should be_false
        @acl.deny(nil, nil, [:p2, :p3])
        @acl.is_allowed?(nil, nil, :p2).should be_false
        @acl.is_allowed?(nil, nil, :p3).should be_false
      end

      it "should ensure that assertions on privileges work properly" do
        @acl.allow(nil, nil, :some_privilege, Racl::Assertion::Generic.new(true))
        @acl.is_allowed?(nil, nil, :some_privilege).should be_true
        @acl.allow(nil, nil, :some_privilege, Racl::Assertion::Generic.new(false))
        @acl.is_allowed?(nil, nil, :some_privilege).should be_false
      end

      it "should ensure that by default, Acl denies access to everything for a particular role" do
        role_guest = Racl::Role::Generic.new('guest')
        @acl.add_role(role_guest)
        @acl.is_allowed?(role_guest).should be_false
      end

      it "should ensure that ACL-wide rules (all Resources and privileges) work properly for a particular Role" do
        role_guest = Racl::Role::Generic.new('guest')
        @acl.add_role(role_guest)
            .allow(role_guest)
        @acl.is_allowed?(role_guest).should be_true
        @acl.deny(role_guest)
        @acl.is_allowed?(role_guest).should be_false
      end

      it "should ensure that by default, Acl denies access to a privilege on anything for a particular Role" do
        role_guest = Racl::Role::Generic.new('guest')
        @acl.add_role(role_guest)
        @acl.is_allowed?(role_guest, nil, :some_privileges).should be_false
      end

      it "should ensure that a privilege allowed for a particular Role upon all Resources work properly" do
        role_guest = Racl::Role::Generic.new('guest')
        @acl.add_role(role_guest)
            .allow(role_guest, nil, :some_privilege)
        @acl.is_allowed?(role_guest, nil, :some_privilege).should be_true
      end

      it "should ensure that a privilege denied for a particular Role upon all Resources work properly" do
        role_guest = Racl::Role::Generic.new('guest')
        @acl.add_role(role_guest)
            .allow(role_guest)
            .deny(role_guest, nil, :some_privilege)
        @acl.is_allowed?(role_guest, nil, :some_privilege).should be_false
      end

      it "should ensure that multiple privileges work properly for a particular Role" do
        role_guest = Racl::Role::Generic.new('guest')
        @acl.add_role(role_guest)
            .allow(role_guest, nil, [:p1, :p2, :p3])
        @acl.is_allowed?(role_guest, nil, :p1).should be_true
        @acl.is_allowed?(role_guest, nil, :p2).should be_true
        @acl.is_allowed?(role_guest, nil, :p3).should be_true
        @acl.is_allowed?(role_guest, nil, :p4).should be_false
        @acl.deny(role_guest, nil, :p1)
        @acl.is_allowed?(role_guest, nil, :p1).should be_false
        @acl.deny(role_guest, nil, [:p2, :p3])
        @acl.is_allowed?(role_guest, nil, :p2).should be_false
        @acl.is_allowed?(role_guest, nil, :p3).should be_false
      end

      it "should ensure that assertions on privileges work properly for a particular Role" do
        role_guest = Racl::Role::Generic.new('guest')
        @acl.add_role(role_guest)
            .allow(role_guest, nil, :some_privilege, Racl::Assertion::Generic.new(true))
        @acl.is_allowed?(role_guest, nil, :some_privilege).should be_true
        @acl.allow(role_guest, nil, :some_privilege, Racl::Assertion::Generic.new(false))
        @acl.is_allowed?(role_guest, nil, :some_privilege).should be_false
      end

      it "should ensure that removing the default rule results in default deny rule"

      it "should ensure that removing the default deny rule results in assertion method being removed"

      it "should ensure that removing the default allow rule results in default deny rule"

      it "should ensure that removing non-existent default allow rule does nothing"

      it "should ensure that removing non-existent default deny rule does nothing"

      it "should ensure that for a particular role, a deny rule on a specific Resource is honored before an allow rule on the entire ACL" do
        @acl.add_role(Racl::Role::Generic.new('guest'))
            .add_role(Racl::Role::Generic.new('staff'), 'guest')
            .add_resource(Racl::Resource::Generic.new('area1'))
            .add_resource(Racl::Resource::Generic.new('area2'))
            .add_resource(Racl::Resource::Generic.new('area3'))
            .deny
            .allow('staff')
            .deny('staff', ['area1', 'area2'])
        @acl.is_allowed?('staff', 'area1').should be_false
        @acl.is_allowed?('staff', 'area3').should be_true
      end

      it "should ensure that for a particular Role, a deny rule on a specific privilege is honored before an allow rule on the entire ACL" do
        @acl.add_role(Racl::Role::Generic.new('guest'))
            .add_role(Racl::Role::Generic.new('staff'), 'guest')
            .deny
            .allow('staff')
            .deny('staff', nil, [:privilege1, :privilege2])
        @acl.is_allowed?('staff', nil, :privilege1).should be_false
      end

      it "should remove basic rule"

      it "should ensure that removal of a Role results in its rules being removed"

      it "should ensure that removal of all Roles results in Role-specific rules being removed"

      it "should ensure that removal of a Resource results in its rules being removed"

      it "should ensure that removal of all Resources results in Resource-specific rules being removed"
    end

    context "CMS Example" do
      it "should ensure that an example for a content management system is operable" do
        # Add some roles to the Role registry
        @acl.add_role(Racl::Role::Generic.new('guest'))
            .add_role(Racl::Role::Generic.new('staff'), 'guest')
            .add_role(Racl::Role::Generic.new('editor'), 'staff')
            .add_role(Racl::Role::Generic.new('administrator'))

        # Guest may only view content
        @acl.allow('guest', nil, :view)
        # Staff inherits privileges from guest, but also needs additional privileges
        @acl.allow('staff', nil, [:edit, :submit, :revise])
        # Editor inherits view, edit, submit and revise privileges, but also needs additional privileges
        @acl.allow('editor', nil, [:publish, :archive, :delete])
        # Administrator inherits nothing, but is allowed all privileges
        @acl.allow('administrator')

        # ACL checks based on above permission sets
=begin        @acl.is_allowed?('guest', nil, :view).should be_true
        @acl.is_allowed?('guest', nil, :edit).should be_false
        @acl.is_allowed?('guest', nil, :submit).should be_false
        @acl.is_allowed?('guest', nil, :revise).should be_false
        @acl.is_allowed?('guest', nil, :publish).should be_false
        @acl.is_allowed?('guest', nil, :archive).should be_false
        @acl.is_allowed?('guest', nil, :delete).should be_false
        @acl.is_allowed?('guest', nil, :unknown).should be_false
        @acl.is_allowed?('guest').should be_false

        @acl.is_allowed?('staff', nil, :view).should be_true
        @acl.is_allowed?('staff', nil, :edit).should be_true
        @acl.is_allowed?('staff', nil, :submit).should be_true
        @acl.is_allowed?('staff', nil, :revise).should be_true
        @acl.is_allowed?('staff', nil, :publish).should be_false
        @acl.is_allowed?('staff', nil, :archive).should be_false
        @acl.is_allowed?('staff', nil, :delete).should be_false
        @acl.is_allowed?('staff', nil, :unknown).should be_false
        @acl.is_allowed?('staff').should be_false

        @acl.is_allowed?('editor', nil, :view).should be_true
        @acl.is_allowed?('editor', nil, :edit).should be_true
        @acl.is_allowed?('editor', nil, :submit).should be_true
        @acl.is_allowed?('editor', nil, :revise).should be_true
        @acl.is_allowed?('editor', nil, :publish).should be_true
        @acl.is_allowed?('editor', nil, :archive).should be_true
        @acl.is_allowed?('editor', nil, :delete).should be_true
        @acl.is_allowed?('editor', nil, :unknown).should be_false
        @acl.is_allowed?('editor').should be_false

        @acl.is_allowed?('administrator', nil, :view).should be_true
        @acl.is_allowed?('administrator', nil, :edit).should be_true
        @acl.is_allowed?('administrator', nil, :submit).should be_true
        @acl.is_allowed?('administrator', nil, :revise).should be_true
        @acl.is_allowed?('administrator', nil, :publish).should be_true
        @acl.is_allowed?('administrator', nil, :archive).should be_true
        @acl.is_allowed?('administrator', nil, :delete).should be_true
        @acl.is_allowed?('administrator', nil, :unknown).should be_true
        @acl.is_allowed?('administrator').should be_true
=end
        # Some checks on specific areas, which inherit access controls from the root ACL node
        @acl.add_resource(Racl::Resource::Generic.new('newsletter'))
            .add_resource(Racl::Resource::Generic.new('pending'), 'newsletter')
            .add_resource(Racl::Resource::Generic.new('gallery'))
            .add_resource(Racl::Resource::Generic.new('profile'), 'gallery')
            .add_resource(Racl::Resource::Generic.new('config'))
            .add_resource(Racl::Resource::Generic.new('hosts'), 'config')
=begin        @acl.is_allowed?('guest', 'pending', :view).should be_true
        @acl.is_allowed?('staff', 'profile', :revise).should be_true
        @acl.is_allowed?('staff', 'pending', :view).should be_true
        @acl.is_allowed?('staff', 'pending', :edit).should be_true
        @acl.is_allowed?('staff', 'pending', :publish).should be_false
        @acl.is_allowed?('staff', 'pending').should be_false
        @acl.is_allowed?('editor', 'hosts', :unknown).should be_false
        @acl.is_allowed?('administrator', 'pending').should be_true
=end
        # Add a new group, marketing, which bases its permissions on staff
        @acl.add_role(Racl::Role::Generic.new('marketing'), 'staff')

        # Allow marketing to publish and archive newsletters
        @acl.allow('marketing', 'newsletter', [:publish, :archive])

        # Allow marketing to publish and archive latest news
        @acl.add_resource(Racl::Resource::Generic.new('news'))
            .add_resource(Racl::Resource::Generic.new('latest'), 'news')
        puts "\r\n***\r\n#{@acl.rules}\r\n***\r\n"
        @acl.allow('marketing', 'latest', [:publish, :archive])
        puts "\r\n*2*\r\n#{@acl.rules}\r\n*2*\r\n"

        # Deny staff (and marketing, by inheritance) rights to revise latest news
        @acl.deny('staff', 'latest', 'revise')

        # Deny everyone access to archive news announcements
        @acl.add_resource(Racl::Resource::Generic.new('announcement'), 'news')
        @acl.deny(nil, 'announcement', 'archive')
=begin
        # Access control checks for the above refined permission sets
        @acl.is_allowed?('marketing', nil, :view).should be_true
        @acl.is_allowed?('marketing', nil, :edit).should be_true
        @acl.is_allowed?('marketing', nil, :submit).should be_true
        @acl.is_allowed?('marketing', nil, :revise).should be_true
        @acl.is_allowed?('marketing', nil, :publish).should be_false
        @acl.is_allowed?('marketing', nil, :archive).should be_false
        @acl.is_allowed?('marketing', nil, :delete).should be_false
        @acl.is_allowed?('marketing', nil, :unknown).should be_false
        @acl.is_allowed?('marketing').should be_false
=end
        @acl.is_allowed?('marketing', 'newsletter', :publish).should be_true
        @acl.is_allowed?('staff', 'pending', :publish).should be_false
        @acl.is_allowed?('marketing', 'pending', :publish).should be_true
        @acl.is_allowed?('marketing', 'newsletter', :archive).should be_true
        @acl.is_allowed?('marketing', 'newsletter', :delete).should be_false
        @acl.is_allowed?('marketing', 'newsletter').should be_false

        @acl.is_allowed?('marketing', 'latest', :publish).should be_true
        @acl.is_allowed?('marketing', 'latest', :archive).should be_true
        @acl.is_allowed?('marketing', 'latest', :delete).should be_false
        @acl.is_allowed?('marketing', 'latest', :revise).should be_false
        @acl.is_allowed?('marketing', 'latest').should be_false

        @acl.is_allowed?('marketing', 'announcement', :archive).should be_false
        @acl.is_allowed?('staff', 'announcement', :archive).should be_false
        @acl.is_allowed?('administrator', 'announcement', :archive).should be_false

        @acl.is_allowed?('staff', 'latest', :publish).should be_false
        @acl.is_allowed?('editor', 'announcement', :archive).should be_false
      end
    end
  end
end
