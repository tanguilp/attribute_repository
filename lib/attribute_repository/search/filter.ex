defmodule AttributeRepository.Search.Filter do
  @type t :: {:attrExp, attr_exp()} | log_exp() | value_path() | {:not, t()}

  @type attr_exp :: {:pr, attr_path()} | {compare_op(), attr_path(), comp_value()}

  @type log_exp :: {:and, t(), t()} | {:or, t(), t()}

  @type value_path :: {:valuePath, attr_path(), val_filter()}

  @type val_filter :: attr_exp() | val_log_exp() | val_filter() | {:not, val_filter()}

  @type val_log_exp ::
          {:and, attr_exp(), val_log_exp()}
          | {:and, attr_exp(), attr_exp()}
          | {:or, attr_exp(), val_log_exp()}
          | {:or, attr_exp(), attr_exp()}

  @type compare_op :: :eq | :ne | :gt | :ge | :lt | :le

  @type comp_value :: true | false | nil | String.t() | integer() | float() | DateTime.t()

  @type attr_path :: AttributeRepository.Search.AttributePath.t()

  @doc """
  Parses an expression an returns its AST

  ## Example
  ```elixir
  iex> AttributeRepository.Search.Filter.parse(~s(surname co "Tchang"))                                                                                              
  {:ok,
   {:attrExp,
    {:co,
     %AttributeRepository.Search.AttributePath{
       attribute: "surname",
       sub_attribute: nil,
       uri: nil
     }, "Tchang"}}}
  iex> AttributeRepository.Search.Filter.parse(~s(subscription_date gt "2013-12-12T23:12:33Z" or lastname ew "ed" and email[value ew "@mail.tv" and type eq "work"]))
  {:ok,
   {:or,
    {:attrExp,
     {:gt, 
      %AttributeRepository.Search.AttributePath{
        attribute: "subscription_date",
        sub_attribute: nil,
        uri: nil
      }, #DateTime<2013-12-12 23:12:33Z>}},
    {:and,
     {:attrExp,
      {:ew,
       %AttributeRepository.Search.AttributePath{
         attribute: "lastname",
         sub_attribute: nil,
         uri: nil
       }, "ed"}},
     {:valuePath,
      %AttributeRepository.Search.AttributePath{
        attribute: "email",
        sub_attribute: nil,
        uri: nil
      },
      {:and,
       {:ew,
        %AttributeRepository.Search.AttributePath{
          attribute: "value",
          sub_attribute: nil,
          uri: nil
        }, "@mail.tv"},
       {:eq,
        %AttributeRepository.Search.AttributePath{
          attribute: "type",
          sub_attribute: nil,
          uri: nil
        }, "work"}}}}}}
  ```
  """

  @spec parse(String.t()) :: {:ok, t()} | {:error, any()}

  def parse(filter) do
    with {:ok, filter_lexed, _} <- :filter_lexer.string(:erlang.binary_to_list(filter)),
         {:ok, parsed_result} <- :filter.parse(filter_lexed) do
      {:ok, parsed_result}
    else
      {:error, lexer_error, _} ->
        {:error, __MODULE__.InvalidError.exception(inspect(lexer_error))}

      {:error, parser_error} ->
        {:error, __MODULE__.InvalidError.exception(inspect(parser_error))}
    end
  end

  defmodule InvalidError do
    @moduledoc """
    Error returned when the filter is invalid because of:
    - lexer error
    - syntax error
    - expression not allowed, such as `attr gt true`
    """

    defexception message: "Invalid filter"

    def exception(), do: %__MODULE__{}
  end
end
