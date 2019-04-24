defmodule AttributeRepository.Search do
  @moduledoc """
  Callback for searching resources
  """

  @type search_result :: [search_entry()]

  @type search_entry :: {AttributeRepository.resource_id(), AttributeRepository.resource()}

  @doc """
  Search for resources using the filter.

  The search filter syntax is the one of RFC7644
  (section [query resources](https://tools.ietf.org/html/rfc7644#section-3.4.2)).

  When inserting `use AttributeRepository.Search` at the begining of an implementation,
  the `search(String.t(), [AttributeRepository.attribute_name()] | :all,
  AttributeRepository.run_opts())` function version will be created. That function
  automatically parses the `String.t()` query and passes it to the callback below.

  ## Example
  ```elixir
  iex> AttributeRepositoryRiak.search(~s(first_name co "v" or last_name sw "Le"), :all, run_opts)
  [
    {"MQNL5ASVNLWZTLJA4MDGHKEXOQ",
     %{
       "first_name" => "Hervé",
       "last_name" => "Le Troadec",
       "shoe_size" => 48,
       "subscription_date" => #DateTime<2017-10-19 12:07:03Z>
     }},
    {"DKO77TT652NZHXX3WM3ZJBFIC4",
     %{
       "first_name" => "Claude",
       "last_name" => "Leblanc",
       "shoe_size" => 43,
       "subscription_date" => #DateTime<2014-06-13 04:42:34Z>
     }},
    {"WCJBCL7SC2THS7TSRXB2KZH7OQ",
     %{
       "first_name" => "Narivelo",
       "last_name" => "Rajaonarimanana",
       "newsletter_subscribed" => false,
       "shoe_size" => 41,
       "subscription_date" => #DateTime<2017-06-06 21:01:43Z>
     }}
  ]
  ```
  """

  @callback search(
              AttributeRepository.Search.Filter.t(),
              [AttributeRepository.attribute_name()] | :all,
              AttributeRepository.run_opts()
            ) ::
              {:ok, search_result()}
              | {:error, %AttributeRepository.ReadError{}}
              | {:error, %AttributeRepository.UnsupportedError{}}
              | {:error, %AttributeRepository.Search.Filter.InvalidError{}}

  defmacro __using__(_opts) do
    quote do
      def search(filter_str, attributes, run_opts) when is_binary(filter_str) do
        case AttributeRepository.Search.Filter.parse(filter_str) do
          {:ok, filter} ->
            search(filter, attributes, run_opts)

          {:error, reason} ->
            {:error, AttributeRepository.ReadError.exception(inspect(reason))}
        end
      end
    end
  end
end
