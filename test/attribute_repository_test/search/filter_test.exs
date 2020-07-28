defmodule AttributeRepository.Search.FilterTest do
  use ExUnit.Case
  doctest AttributeRepository.Search.Filter

  alias AttributeRepository.Search.Filter

  describe ".parse/1" do
    test "Valid example 1 from specification" do
      filter = ~S(userName eq "bjensen")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 2 from specification" do
      filter = ~S(name.familyName co "O'Malley")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 3 from specification" do
      filter = ~S(userName sw "J")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 4 from specification" do
      filter = ~S(urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 5 from specification" do
      filter = ~S(title pr)

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 6 from specification" do
      filter = ~S(meta.lastModified gt "2011-05-13T04:42:34Z")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 7 from specification" do
      filter = ~S(meta.lastModified ge "2011-05-13T04:42:34Z")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 8 from specification" do
      filter = ~S(meta.lastModified lt "2011-05-13T04:42:34Z")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 9 from specification" do
      filter = ~S(meta.lastModified le "2011-05-13T04:42:34Z")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 10 from specification" do
      filter = ~S(title pr and userType eq "Employee")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 11 from specification" do
      filter = ~S(title pr or userType eq "Intern")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 12 from specification" do
      filter = ~S(schemas eq "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User")

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 13 from specification" do
      filter = ~S|userType eq "Employee" and (emails co "example.com" or emails.value co "example.org")|

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 14 from specification" do
      filter = ~S|userType ne "Employee" and not (emails co "example.com" or emails.value co "example.org")|

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 15 from specification" do
      filter = ~S|userType eq "Employee" and (emails.type eq "work")|

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 16 from specification" do
      filter = ~S|userType eq "Employee" and emails[type eq "work" and value co "@example.com"]|

      {:ok, _} = Filter.parse(filter)
    end

    test "Valid example 17 from specification" do
      filter = ~S|emails[type eq "work" and value co "@example.com"] or ims[type eq "xmpp" and value co "@foo.com"]|

      {:ok, _} = Filter.parse(filter)
    end

    test "and has precedence over or (1)" do
      filter = ~S|a1 eq 1 and a2 eq 2 or a3 eq 3|

      {:ok, {:or, _, _}} = Filter.parse(filter)
    end

    test "and has precedence over or (2)" do
      filter = ~S|a1 eq 1 or a2 eq 2 and a3 eq 3|

      {:ok, {:or, _, _}} = Filter.parse(filter)
    end

    test "not operator as the root is valid" do
      filter = ~S|not(a1 eq 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "eq operator is correctly parsed" do
      filter = ~S|not(a1 eq 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "ne operator is correctly parsed" do
      filter = ~S|not(a1 ne 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "co operator is correctly parsed" do
      filter = ~S|not(a1 co 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "sw operator is correctly parsed" do
      filter = ~S|not(a1 sw 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "ew operator is correctly parsed" do
      filter = ~S|not(a1 ew 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "gt operator is correctly parsed" do
      filter = ~S|not(a1 gt 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "ge operator is correctly parsed" do
      filter = ~S|not(a1 ge 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "lt operator is correctly parsed" do
      filter = ~S|not(a1 lt 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "le operator is correctly parsed" do
      filter = ~S|not(a1 le 1)|

      {:ok, _} = Filter.parse(filter)
    end

    test "Invalid nested expression into brackets" do
      filter = ~S|emails[type[attr eq "val"] eq "work"]|

      {:error, %_{}} = Filter.parse(filter)
    end
  end
end
