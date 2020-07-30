defmodule AttributeRepository.Search.FilterTest do
  use ExUnit.Case
  doctest AttributeRepository.Search.Filter

  alias AttributeRepository.Search.Filter

  @spec_examples %{
    1 => ~S|userName eq "bjensen"|,
    2 => ~S|name.familyName co "O'Malley"|,
    3 => ~S|userName sw "J"|,
    4 => ~S|urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J"|,
    5 => ~S|title pr|,
    6 => ~S|meta.lastModified gt "2011-05-13T04:42:34Z"|,
    7 => ~S|meta.lastModified ge "2011-05-13T04:42:34Z"|,
    8 => ~S|meta.lastModified lt "2011-05-13T04:42:34Z"|,
    9 => ~S|meta.lastModified le "2011-05-13T04:42:34Z"|,
    10 => ~S|title pr and userType eq "Employee"|,
    11 => ~S|title pr or userType eq "Intern"|,
    12 => ~S|schemas eq "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"|,
    13 => ~S|userType eq "Employee" and (emails co "example.com" or emails.value co "example.org")|,
    14 => ~S|userType ne "Employee" and not (emails co "example.com" or emails.value co "example.org")|,
    15 => ~S|userType eq "Employee" and (emails.type eq "work")|,
    16 => ~S|userType eq "Employee" and emails[type eq "work" and value co "@example.com"]|,
    17 => ~S|emails[type eq "work" and value co "@example.com"] or ims[type eq "xmpp" and value co "@foo.com"]|
  }

  describe ".parse/1" do
    for i <- 1..Enum.count(@spec_examples) do
      test "Valid example #{i} from specification" do
        assert {:ok, _} = Filter.parse(@spec_examples[unquote(i)])
      end
    end

    test "and has precedence over or (1)" do
      assert {:ok, {:or, _, _}} = Filter.parse(~S|a1 eq 1 and a2 eq 2 or a3 eq 3|)
    end

    test "and has precedence over or (2)" do
      assert {:ok, {:or, _, _}} = Filter.parse(~S|a1 eq 1 or a2 eq 2 and a3 eq 3|)
    end

    test "not operator as the root is valid" do
      assert {:ok, _} = Filter.parse(~S|not(a1 eq 1)|)
    end

    test "eq operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 eq 1)|)
    end

    test "ne operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 ne 1)|)
    end

    test "co operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 co 1)|)
    end

    test "sw operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 sw 1)|)
    end

    test "ew operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 ew 1)|)
    end

    test "gt operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 gt 1)|)
    end

    test "ge operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 ge 1)|)
    end

    test "lt operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 lt 1)|)
    end

    test "le operator is correctly parsed" do
      assert {:ok, _} = Filter.parse(~S|not(a1 le 1)|)
    end

    test "Invalid nested expression into brackets" do
      assert {:error, %_{}} = Filter.parse(~S|emails[type[attr eq "val"] eq "work"]|)
    end
  end

  describe ".serialize/1" do
    for i <- 1..Enum.count(@spec_examples) do
      test "Serialize example #{i} from specification" do
        ast = Filter.parse!(@spec_examples[unquote(i)])

        assert ast == ast |> Filter.serialize() |> Filter.parse!()
      end
    end
  end
end
