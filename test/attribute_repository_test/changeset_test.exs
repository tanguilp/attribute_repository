defmodule AttributeRepository.ChangesetTest do
  use ExUnit.Case

  alias AttributeRepository.Changeset
  alias AttributeRepository.Changeset.{
    InvalidTypeError
  }
  alias AttributeRepository.Schema.{
    MissingAttributeDefinitionError
  }

  @datetime DateTime.utc_now()
  @pi 3.1415

  defmodule ChangesetSchema do
    use AttributeRepository.Schema

    schema "Changeset test schema" do
      attribute :some_string, type: :string
      attribute :some_string_mv, type: :string, multi_valued: true
      attribute :some_bool, type: :boolean
      attribute :some_float, type: :decimal
      attribute :some_integer, type: :integer
      attribute :some_datetime, type: :date_time
    end
  end

  describe "add/3 - general tests" do
    setup [:changeset]

    test "adding an already existing simple value doesn't modify the changeset" do
      changeset = Changeset.new(
        schemas: ChangesetSchema.__schemas__(),
        resource: %{"some_string" => "some value"}
      )

      assert {:ok, changeset} = Changeset.add(changeset, "some_string", "some value")
      assert changeset.change_ops == []
      assert changeset.modified? == false
      assert changeset.resource == %{"some_string" => "some value"}
    end

    test "adding an already existing simple mutlivalued value doesn't modify the changeset" do
      changeset = Changeset.new(
        schemas: ChangesetSchema.__schemas__(),
        resource: %{"some_string_mv" => ["some value", "some other value"]}
      )

      assert {:ok, changeset} = Changeset.add(changeset, "some_string_mv", "some other value")
      assert changeset.change_ops == []
      assert changeset.modified? == false
      assert changeset.resource == %{"some_string_mv" => ["some value", "some other value"]}
    end

    test "invalid add to a nonexistant attribute", %{changeset: changeset} do
      assert {:error, %MissingAttributeDefinitionError{}} =
        Changeset.add(changeset, "unknown", "some value")
    end
  end

  describe "add/3 - string type tests" do
    setup [:changeset]

    test "valid add string attribute", %{changeset: changeset} do
      assert {:ok, changeset} = Changeset.add(changeset, "some_string", "some value")
      assert changeset.change_ops == [{:add, "some_string", "some value"}]
      assert changeset.modified? == true
      assert changeset.resource == %{"some_string" => "some value"}
    end

    test "valid add string attribute (multivalued)", %{changeset: changeset} do
      assert {:ok, changeset} = Changeset.add(changeset, "some_string_mv", "some value")
      assert {:ok, changeset} = Changeset.add(changeset, "some_string_mv", "some other value")
      assert changeset.change_ops ==
        [{:add, "some_string_mv", "some value"}, {:add, "some_string_mv", "some other value"}]
      assert changeset.modified? == true
      assert %{"some_string_mv" => vals} = changeset.resource
      assert Enum.sort(vals) == ["some other value", "some value"]
    end

    test "invalid add a boolean to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_string", true)
    end

    test "invalid add a float to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_string", 3.1415)
    end

    test "invalid add an integer to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_string", 1337)
    end

    test "invalid add a datetime to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_string", DateTime.utc_now())
    end

    test "invalid add a complex value to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_string", %{"a" => 1})
    end
  end

  describe "add/3 - boolean type tests" do
    setup [:changeset]

    test "valid add boolean (true) attribute", %{changeset: changeset} do
      assert {:ok, changeset} = Changeset.add(changeset, "some_bool", true)
      assert changeset.change_ops == [{:add, "some_bool", true}]
      assert changeset.modified? == true
      assert changeset.resource == %{"some_bool" => true}
    end

    test "valid add boolean (false) attribute", %{changeset: changeset} do
      assert {:ok, changeset} = Changeset.add(changeset, "some_bool", false)
      assert changeset.change_ops == [{:add, "some_bool", false}]
      assert changeset.modified? == true
      assert changeset.resource == %{"some_bool" => false}
    end

    test "invalid add a string to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_bool", "some value")
    end

    test "invalid add a float to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_bool", 3.1415)
    end

    test "invalid add an integer to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_bool", 1337)
    end

    test "invalid add a datetime to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_bool", DateTime.utc_now())
    end

    test "invalid add a complex value to a string attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_bool", %{"a" => 1})
    end
  end

  describe "add/3 - float type tests" do
    setup [:changeset]

    test "valid add float attribute", %{changeset: changeset} do
      assert {:ok, changeset} = Changeset.add(changeset, "some_float", @pi)
      assert changeset.change_ops == [{:add, "some_float", @pi}]
      assert changeset.modified? == true
      assert changeset.resource == %{"some_float" => @pi}
    end

    test "invalid add a string to a float attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_float", "some value")
    end

    test "invalid add a boolean to a float attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_float", true)
    end

    test "invalid add an integer to a float attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_float", 1337)
    end

    test "invalid add a datetime to a float attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_float", DateTime.utc_now())
    end

    test "invalid add a complex value to a float attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_float", %{"a" => 1})
    end
  end

  describe "add/3 - integer type tests" do
    setup [:changeset]

    test "valid add integer attribute", %{changeset: changeset} do
      assert {:ok, changeset} = Changeset.add(changeset, "some_integer", 1337)
      assert changeset.change_ops == [{:add, "some_integer", 1337}]
      assert changeset.modified? == true
      assert changeset.resource == %{"some_integer" => 1337}
    end

    test "invalid add a string to an integer attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_integer", "some value")
    end

    test "invalid add a boolean to an integer attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_integer", true)
    end

    test "invalid add an float to an integer attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_integer", @pi)
    end

    test "invalid add a datetime to an integer attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_integer", DateTime.utc_now())
    end

    test "invalid add a complex value to an integer attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_integer", %{"a" => 1})
    end
  end

  describe "add/3 - datetime type tests" do
    setup [:changeset]

    test "valid add datetime attribute", %{changeset: changeset} do
      assert {:ok, changeset} = Changeset.add(changeset, "some_datetime", @datetime)
      assert changeset.change_ops == [{:add, "some_datetime", @datetime}]
      assert changeset.modified? == true
      assert changeset.resource == %{"some_datetime" => @datetime}
    end

    test "invalid add a string to a datetime attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_datetime", "some value")
    end

    test "invalid add a boolean to a datetime attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_datetime", true)
    end

    test "invalid add an float to a datetime attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} = Changeset.add(changeset, "some_datetime", @pi)
    end

    test "invalid add an integer to a datetime attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_datetime", 1337)
    end

    test "invalid add a complex value to a datetime attribute", %{changeset: changeset} do
      assert {:error, %InvalidTypeError{}} =
        Changeset.add(changeset, "some_datetime", %{"a" => 1})
    end
  end

  defp changeset(_) do
    [changeset: Changeset.new(schemas: ChangesetSchema.__schemas__())]
  end
end
