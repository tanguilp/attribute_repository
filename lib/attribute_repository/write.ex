defmodule AttributeRepository.Write do
  @moduledoc """
  Callbacks for modification of entries

  There are 3 callbacks:
  - `put/3` that entirely replaces the resource with new attribute values
  - `modify/3` that replaces some attributes
  - `delete/2` that deletes an entire resource
  """

  @doc """
  Replaces a new resource

  Replaces entirely the resource `resource_id` with the attributes of `resource`, or create
  it if the resource does not exist.

  When inserting `use AttributeRepository.Write` at the begining of an implementation,
  the `put!/3` banged version will be automatically created.

  ## Example
  ```elixir
  iex> run_opts = [instance: :users, bucket_type: "attr_rep"]
  iex> AttributeRepositoryRiak.put("WCJBCL7SC2THS7TSRXB2KZH7OQ",
                                   %{"first_name" => "Narivelo",
                                     "last_name" => "Rajaonarimanana",
                                     "shoe_size" => 41,
                                     "subscription_date" => DateTime.from_iso8601("2017-06-06T21:01:43Z") |> elem(1),
                                     "newsletter_subscribed" => false}, run_opts)
  {:ok,
   %{
     "first_name" => "Narivelo",
     "last_name" => "Rajaonarimanana",
     "newsletter_subscribed" => false,
     "shoe_size" => 41,
     "subscription_date" => #DateTime<2017-06-06 21:01:43Z>
   }}
  ```
  """

  @callback put(
              AttributeRepository.resource_id(),
              AttributeRepository.resource(),
              AttributeRepository.run_opts()
            ) ::
              {:ok, AttributeRepository.resource()}
              | {:error, %AttributeRepository.WriteError{}}
              | {:error, %AttributeRepository.UnsupportedError{}}

  @doc """
  Modifies attributes of a resource

  Applies the list of modification operations (`[modify_op]`) to a resource.

  When inserting `use AttributeRepository.Write` at the begining of an implementation,
  the`resource_id` `modify!/3` banged version will be automatically created.

  ## Example
  ```elixir
  iex> run_opts = [instance: :users, bucket_type: "attr_rep"]
  iex> AttributeRepositoryRiak.get("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", :all, run_opts)
  {:ok,
   %{
     "first_name" => "Lisa",
     "last_name" => "Santana",
     "newsletter_subscribed" => true,
     "shoe_size" => 33,
     "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
   }}
  iex> AttributeRepositoryRiak.modify("Y4HKZMJ3K5A7IMZFZ5O3O56VC4",
                                      [
                                        {:replace, "shoe_size", 34},
                                        {:add, "interests", ["rock climbing", "tango", "linguistics"]}
                                      ], run_opts)
  :ok
  iex> AttributeRepositoryRiak.get!("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", :all, run_opts)
  %{
    "first_name" => "Lisa",
    "interests" => ["linguistics", "rock climbing", "tango"],
    "last_name" => "Santana",
    "newsletter_subscribed" => true,
    "shoe_size" => 34,
    "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
  }
  ```
  """

  @callback modify(
              AttributeRepository.resource_id(),
              [modify_op()],
              AttributeRepository.run_opts()
            ) ::
              :ok
              | {:error, %AttributeRepository.WriteError{}}
              | {:error, %AttributeRepository.ReadError{}}
              | {:error, %AttributeRepository.Read.NotFoundError{}}
              | {:error, %AttributeRepository.UnsupportedError{}}

  @type modify_op :: modify_op_add() | modify_op_replace() | modify_op_delete()

  @typedoc """
  Adds an attribute to a resource

  ## Rules
  - If the attribute already exists:
    - If the attribute is multi-valued: add the new value to the multi-valued attribute
    - Otherwise (the attribute is single-valued), replace the value of the target attribute
  - Otherwise, add it as a new attribute
  """

  @type modify_op_add ::
          {:add, AttributeRepository.attribute_name(), AttributeRepository.attribute_value()}

  @typedoc """
  Modifies an attribute

  ## Rules
  - The 3-tuple is equivalent to the `:add` operation
  - Regarding the 4-tuple: 
    - if the existing attribute is a set:
      - If the attribute already exists, replace it
      - Otherwise, add it as a new attribute
    - otherwise, add the new value as an attribute
  """

  @type modify_op_replace ::
          {:replace, AttributeRepository.attribute_name(), AttributeRepository.attribute_value()}
          | {:replace, AttributeRepository.attribute_name(),
             AttributeRepository.attribute_value(), AttributeRepository.attribute_value()}

  @typedoc """
  Deletes an attribute

  ## Rules
  - 2-tuple: deletes the attribute
  - 3-tuple:
    - if the existing attribute is a set, delete the value if it exists
    - otherwise, do not delete anything
  """

  @type modify_op_delete ::
          {:delete, AttributeRepository.attribute_name()}
          | {:delete, AttributeRepository.attribute_name(), AttributeRepository.attribute_value()}

  @callback delete(
              AttributeRepository.resource_id(),
              AttributeRepository.run_opts()
            ) ::
              :ok
              | {:error, %AttributeRepository.WriteError{}}
              | {:error, %AttributeRepository.Read.NotFoundError{}}

  defmacro __using__(_opts) do
    quote do
      def put!(resource_id, resource, opts) do
        case put(resource_id, resource, opts) do
          {:ok, resource} ->
            resource

          {:error, exception} ->
            raise exception
        end
      end

      def delete!(resource_id, opts) do
        case delete(resource_id, opts) do
          :ok ->
            :ok

          {:error, exception} ->
            raise exception
        end
      end
    end
  end

  defmodule NotFoundError do
    @moduledoc """
    Error returned when a resource expected to be found was not found
    """

    defexception message: "Resource not found"
  end
end
