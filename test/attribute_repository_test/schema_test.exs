defmodule AttributeRepository.SchemaTest do
  use ExUnit.Case

  alias AttributeRepository.Schema

  defmodule BasicSchemas do
    use AttributeRepository.Schema

    @doc """
    Base user schema
    """
    schema "Schema 1" do
      attribute :some_string, type: :string
      attribute :some_other_string,
        case_exact: true,
        multi_valued: true,
        mutability: :read_only,
        required: true,
        returned: :always,
        type: :string,
        uniqueness: :server,
        canonical_values: ["some", "values"],
        description: "Some description"
      attribute :some_boolean, type: :boolean
      attribute :some_decimal, type: :decimal
      attribute :some_integer, type: :integer
      attribute :some_date_time, type: :date_time
      attribute :some_reference, type: :reference, reference_types: ["User", "Admin"]
      attribute :some_complex, type: :complex, sub_attributes: [
        some_string: [type: :string],
        some_boolean: [type: :boolean],
        some_decimal: [type: :decimal],
        some_integer: [type: :integer],
        some_date_time: [type: :date_time],
        some_reference: [type: :reference]
      ]
    end

    schema "Schema 2", id: "urn:attrrep:schemas:schema-2" do
      attribute :some_other_string, type: :string
    end
  end

  describe ".schema/2" do
    test "schemas are parsed" do
      assert [%Schema{name: "Schema 1"} = schema1, %Schema{name: "Schema 2"} = schema2] =
        BasicSchemas.__schemas__()

      assert schema1.id == "Schema 1"
      assert schema1.name == "Schema 1"
      assert schema1.description == "Base user schema"

      assert schema1.attributes["some_string"][:case_exact] == false
      assert schema1.attributes["some_string"][:multi_valued] == false
      assert schema1.attributes["some_string"][:mutability] == :read_write
      assert schema1.attributes["some_string"][:required] == false
      assert schema1.attributes["some_string"][:returned] == :default
      assert schema1.attributes["some_string"][:type] == :string
      assert schema1.attributes["some_string"][:uniqueness] == :none
      assert schema1.attributes["some_string"][:canonical_values] == nil
      assert schema1.attributes["some_string"][:description] == nil
      assert schema1.attributes["some_string"][:reference_types] == nil
      assert schema1.attributes["some_string"][:sub_attributes] == nil

      assert schema1.attributes["some_other_string"][:case_exact] == true
      assert schema1.attributes["some_other_string"][:multi_valued] == true
      assert schema1.attributes["some_other_string"][:mutability] == :read_only
      assert schema1.attributes["some_other_string"][:required] == true
      assert schema1.attributes["some_other_string"][:returned] == :always
      assert schema1.attributes["some_other_string"][:type] == :string
      assert schema1.attributes["some_other_string"][:uniqueness] == :server
      assert schema1.attributes["some_other_string"][:canonical_values] == ["some", "values"]
      assert schema1.attributes["some_other_string"][:description] == "Some description"
      assert schema1.attributes["some_other_string"][:reference_types] == nil
      assert schema1.attributes["some_other_string"][:sub_attributes] == nil

      assert schema1.attributes["some_boolean"][:case_exact] == false
      assert schema1.attributes["some_boolean"][:multi_valued] == false
      assert schema1.attributes["some_boolean"][:mutability] == :read_write
      assert schema1.attributes["some_boolean"][:required] == false
      assert schema1.attributes["some_boolean"][:returned] == :default
      assert schema1.attributes["some_boolean"][:type] == :boolean
      assert schema1.attributes["some_boolean"][:uniqueness] == :none
      assert schema1.attributes["some_boolean"][:canonical_values] == nil
      assert schema1.attributes["some_boolean"][:description] == nil
      assert schema1.attributes["some_boolean"][:reference_types] == nil
      assert schema1.attributes["some_boolean"][:sub_attributes] == nil

      assert schema1.attributes["some_decimal"][:case_exact] == false
      assert schema1.attributes["some_decimal"][:multi_valued] == false
      assert schema1.attributes["some_decimal"][:mutability] == :read_write
      assert schema1.attributes["some_decimal"][:required] == false
      assert schema1.attributes["some_decimal"][:returned] == :default
      assert schema1.attributes["some_decimal"][:type] == :decimal
      assert schema1.attributes["some_decimal"][:uniqueness] == :none
      assert schema1.attributes["some_decimal"][:canonical_values] == nil
      assert schema1.attributes["some_decimal"][:description] == nil
      assert schema1.attributes["some_decimal"][:reference_types] == nil
      assert schema1.attributes["some_decimal"][:sub_attributes] == nil

      assert schema1.attributes["some_integer"][:case_exact] == false
      assert schema1.attributes["some_integer"][:multi_valued] == false
      assert schema1.attributes["some_integer"][:mutability] == :read_write
      assert schema1.attributes["some_integer"][:required] == false
      assert schema1.attributes["some_integer"][:returned] == :default
      assert schema1.attributes["some_integer"][:type] == :integer
      assert schema1.attributes["some_integer"][:uniqueness] == :none
      assert schema1.attributes["some_integer"][:canonical_values] == nil
      assert schema1.attributes["some_integer"][:description] == nil
      assert schema1.attributes["some_integer"][:reference_types] == nil
      assert schema1.attributes["some_integer"][:sub_attributes] == nil

      assert schema1.attributes["some_date_time"][:case_exact] == false
      assert schema1.attributes["some_date_time"][:multi_valued] == false
      assert schema1.attributes["some_date_time"][:mutability] == :read_write
      assert schema1.attributes["some_date_time"][:required] == false
      assert schema1.attributes["some_date_time"][:returned] == :default
      assert schema1.attributes["some_date_time"][:type] == :date_time
      assert schema1.attributes["some_date_time"][:uniqueness] == :none
      assert schema1.attributes["some_date_time"][:canonical_values] == nil
      assert schema1.attributes["some_date_time"][:description] == nil
      assert schema1.attributes["some_date_time"][:reference_types] == nil
      assert schema1.attributes["some_date_time"][:sub_attributes] == nil

      assert schema1.attributes["some_reference"][:case_exact] == false
      assert schema1.attributes["some_reference"][:multi_valued] == false
      assert schema1.attributes["some_reference"][:mutability] == :read_write
      assert schema1.attributes["some_reference"][:required] == false
      assert schema1.attributes["some_reference"][:returned] == :default
      assert schema1.attributes["some_reference"][:type] == :reference
      assert schema1.attributes["some_reference"][:uniqueness] == :none
      assert schema1.attributes["some_reference"][:canonical_values] == nil
      assert schema1.attributes["some_reference"][:description] == nil
      assert schema1.attributes["some_reference"][:reference_types] == ["User", "Admin"]
      assert schema1.attributes["some_reference"][:sub_attributes] == nil

      assert schema1.attributes["some_complex"][:case_exact] == false
      assert schema1.attributes["some_complex"][:multi_valued] == false
      assert schema1.attributes["some_complex"][:mutability] == :read_write
      assert schema1.attributes["some_complex"][:required] == false
      assert schema1.attributes["some_complex"][:returned] == :default
      assert schema1.attributes["some_complex"][:type] == :complex
      assert schema1.attributes["some_complex"][:uniqueness] == :none
      assert schema1.attributes["some_complex"][:canonical_values] == nil
      assert schema1.attributes["some_complex"][:description] == nil
      assert schema1.attributes["some_complex"][:reference_types] == nil

      sub_attrs = schema1.attributes["some_complex"][:sub_attributes]

      assert sub_attrs["some_string"][:case_exact] == false
      assert sub_attrs["some_string"][:multi_valued] == false
      assert sub_attrs["some_string"][:mutability] == :read_write
      assert sub_attrs["some_string"][:required] == false
      assert sub_attrs["some_string"][:returned] == :default
      assert sub_attrs["some_string"][:type] == :string
      assert sub_attrs["some_string"][:uniqueness] == :none
      assert sub_attrs["some_string"][:canonical_values] == nil
      assert sub_attrs["some_string"][:description] == nil
      assert sub_attrs["some_string"][:reference_types] == nil
      assert sub_attrs["some_string"][:sub_attributes] == nil

      assert sub_attrs["some_boolean"][:case_exact] == false
      assert sub_attrs["some_boolean"][:multi_valued] == false
      assert sub_attrs["some_boolean"][:mutability] == :read_write
      assert sub_attrs["some_boolean"][:required] == false
      assert sub_attrs["some_boolean"][:returned] == :default
      assert sub_attrs["some_boolean"][:type] == :boolean
      assert sub_attrs["some_boolean"][:uniqueness] == :none
      assert sub_attrs["some_boolean"][:canonical_values] == nil
      assert sub_attrs["some_boolean"][:description] == nil
      assert sub_attrs["some_boolean"][:reference_types] == nil
      assert sub_attrs["some_boolean"][:sub_attributes] == nil

      assert sub_attrs["some_decimal"][:case_exact] == false
      assert sub_attrs["some_decimal"][:multi_valued] == false
      assert sub_attrs["some_decimal"][:mutability] == :read_write
      assert sub_attrs["some_decimal"][:required] == false
      assert sub_attrs["some_decimal"][:returned] == :default
      assert sub_attrs["some_decimal"][:type] == :decimal
      assert sub_attrs["some_decimal"][:uniqueness] == :none
      assert sub_attrs["some_decimal"][:canonical_values] == nil
      assert sub_attrs["some_decimal"][:description] == nil
      assert sub_attrs["some_decimal"][:reference_types] == nil
      assert sub_attrs["some_decimal"][:sub_attributes] == nil

      assert sub_attrs["some_integer"][:case_exact] == false
      assert sub_attrs["some_integer"][:multi_valued] == false
      assert sub_attrs["some_integer"][:mutability] == :read_write
      assert sub_attrs["some_integer"][:required] == false
      assert sub_attrs["some_integer"][:returned] == :default
      assert sub_attrs["some_integer"][:type] == :integer
      assert sub_attrs["some_integer"][:uniqueness] == :none
      assert sub_attrs["some_integer"][:canonical_values] == nil
      assert sub_attrs["some_integer"][:description] == nil
      assert sub_attrs["some_integer"][:reference_types] == nil
      assert sub_attrs["some_integer"][:sub_attributes] == nil

      assert sub_attrs["some_date_time"][:case_exact] == false
      assert sub_attrs["some_date_time"][:multi_valued] == false
      assert sub_attrs["some_date_time"][:mutability] == :read_write
      assert sub_attrs["some_date_time"][:required] == false
      assert sub_attrs["some_date_time"][:returned] == :default
      assert sub_attrs["some_date_time"][:type] == :date_time
      assert sub_attrs["some_date_time"][:uniqueness] == :none
      assert sub_attrs["some_date_time"][:canonical_values] == nil
      assert sub_attrs["some_date_time"][:description] == nil
      assert sub_attrs["some_date_time"][:reference_types] == nil
      assert sub_attrs["some_date_time"][:sub_attributes] == nil

      assert sub_attrs["some_reference"][:case_exact] == false
      assert sub_attrs["some_reference"][:multi_valued] == false
      assert sub_attrs["some_reference"][:mutability] == :read_write
      assert sub_attrs["some_reference"][:required] == false
      assert sub_attrs["some_reference"][:returned] == :default
      assert sub_attrs["some_reference"][:type] == :reference
      assert sub_attrs["some_reference"][:uniqueness] == :none
      assert sub_attrs["some_reference"][:canonical_values] == nil
      assert sub_attrs["some_reference"][:description] == nil
      assert sub_attrs["some_reference"][:reference_types] == nil
      assert sub_attrs["some_reference"][:sub_attributes] == nil

      assert schema2.attributes["some_other_string"][:case_exact] == false
      assert schema2.attributes["some_other_string"][:multi_valued] == false
      assert schema2.attributes["some_other_string"][:mutability] == :read_write
      assert schema2.attributes["some_other_string"][:required] == false
      assert schema2.attributes["some_other_string"][:returned] == :default
      assert schema2.attributes["some_other_string"][:type] == :string
      assert schema2.attributes["some_other_string"][:uniqueness] == :none
      assert schema2.attributes["some_other_string"][:canonical_values] == nil
      assert schema2.attributes["some_other_string"][:description] == nil
      assert schema2.attributes["some_other_string"][:reference_types] == nil
      assert schema2.attributes["some_other_string"][:sub_attributes] == nil
    end
  end
end
