require "dbus"

describe DBusApiService do
  include RackTestMixin

  let(:user) { "jdoe" }

  let(:dbus_ifp_interface) do
    sysbus = double("sysbus")
    allow(DBus).to receive(:system_bus).and_return(sysbus)

    ifp_service = double("ifp_service")
    allow(sysbus).to receive(:[]).with("org.freedesktop.sssd.infopipe").and_return(ifp_service)

    ifp_object  = double("ifp_object")
    allow(ifp_service).to receive(:object).with("/org/freedesktop/sssd/infopipe").and_return(ifp_object)
    allow(ifp_object).to receive(:introspect)

    double("ifp_interface").tap do |ifp_interface|
      allow(ifp_object).to receive(:[]).with("org.freedesktop.sssd.infopipe").and_return(ifp_interface)
    end
  end

  def assert_not_found
    expect(last_response).to_not be_ok
    expect(last_response.status).to eql 404
  end

  def assert_response(expected)
    expect(last_response).to be_ok
    expect(JSON.parse(last_response.body)).to eq expected
  end

  def assert_error_matches(error_pattern)
    expect(last_response).to_not be_ok
    expect(JSON.parse(last_response.body)["error"]).to match(error_pattern)
  end

  describe "/" do
    it "is not accessible" do
      get "/"
      assert_not_found
    end
  end

  describe "/api/user_attrs" do
    it "without a user" do
      get "/api/user_attrs"
      assert_not_found
    end

    it "when DBus is not running" do
      get "/api/user_attrs/#{user}"
      assert_error_matches(/Unable to get attributes for user #{user} - .*/)
    end

    it "with a user" do
      requested_attrs = DBusApiService::DEFAULT_USER_ATTRIBUTES

      dbus_attrs = [
        {
          "mail"        => ["jdoe@example.com"],
          "givenname"   => ["John"],
          "sn"          => ["Doe"],
          "displayname" => ["John Doe"],
          "domainname"  => ["example.com"]
        }
      ]

      allow(dbus_ifp_interface).to receive(:GetUserAttr).with(user, requested_attrs).and_return(dbus_attrs)

      get "/api/user_attrs/#{user}"

      assert_response(
        "result" => {
          "mail"        => "jdoe@example.com",
          "givenname"   => "John",
          "sn"          => "Doe",
          "displayname" => "John Doe",
          "domainname"  => "example.com"
        }
      )
    end

    it "with a user and specific attributes" do
      requested_attrs = %w[mail displayname]

      dbus_attrs = [
        {
          "mail"        => ["jdoe@example.com"],
          "displayname" => ["John Doe"]
        }
      ]

      allow(dbus_ifp_interface).to receive(:GetUserAttr).with(user, requested_attrs).and_return(dbus_attrs)

      get "/api/user_attrs/#{user}?attributes=mail,displayname"

      assert_response(
        "result" => {
          "mail"        => "jdoe@example.com",
          "displayname" => "John Doe"
        }
      )
    end
  end

  describe "/api/user_groups" do
    it "without a user" do
      get "/api/user_groups"
      assert_not_found
    end

    it "when DBus is not running" do
      get "/api/user_groups/#{user}"
      assert_error_matches(/Unable to get groups for user #{user} - .*/)
    end

    it "with a user with groups" do
      dbus_groups = [%w[group1 group2]]

      allow(dbus_ifp_interface).to receive(:GetUserGroups).with(user).and_return(dbus_groups)

      get "/api/user_groups/#{user}"

      assert_response("result" => %w[group1 group2])
    end

    it "with a user with FQDN groups" do
      dbus_groups = [%w[group1@fqdn group2@fqdn]]

      allow(dbus_ifp_interface).to receive(:GetUserGroups).with(user).and_return(dbus_groups)

      get "/api/user_groups/#{user}"

      assert_response("result" => %w[group1@fqdn group2@fqdn])
    end
  end
end
