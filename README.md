# AttributeRepository

Callbacks for module implementing [SCIM](http://www.simplecloud.info/)-like attribute
repositories.

SCIM is a standards for exchanging attributes of some resources. The data model is simple:
attributes are associated to a resource. These attributes a simple scalars or maps, and
can be either single-valued or multi-valued. There are no foreign keys and joins like in SQL
DBMSes.

This library defines:
- 6 callbacks:
  - `AttributeRepository.Install`: install the repository on startup
  - `AttributeRepository.Read`: get attributes from the resource's id
  - `AttributeRepository.Write`: create, modify and delete a resource's attributes
  - `AttributeRepository.Search`: search resources that matches a SCIM filter
  - `AttributeRepository.SupervisedStart`: start a supervised attribute repository
  - `AttributeRepository.Start`: start an attribute repository (without supervision)
- a parser for the SCIM filter grammar, and the `AttributeRepository.Search.Filter.parse/1`
convenience function to parse a SCIM filter

## Installation

This library is installed automativally when using one of its implementations.

## Support

Elixir 1.10.0+

## Implementations

- [AttributeRepositoryLdap](https://github.com/tanguilp/attribute_repository_ldap)
- [AttributeRepositoryMnesia](https://github.com/tanguilp/attribute_repository_mnesia)
- [AttributeRepositoryRiak](https://github.com/tanguilp/attribute_repository_riak)

## Example (from the `AttributeRepositoryRiak` implementation)

```elixir
iex> run_opts = [instance: :users, bucket_type: "attr_rep"]
[instance: :users, bucket_type: "attr_rep"]
iex> AttributeRepositoryRiak.install(run_opts, [])
:ok
iex> AttributeRepositoryRiak.put("DKO77TT652NZHXX3WM3ZJBFIC4", %{"first_name" => "Claude", "last_name" => "Leblanc", "shoe_size" => 43, "subscription_date" => DateTime.from_iso8601("2014-06-13T04:42:34Z") |> elem(1)}, run_opts)
{:ok,
 %{
   "first_name" => "Claude",
   "last_name" => "Leblanc",
   "shoe_size" => 43,
   "subscription_date" => #DateTime<2014-06-13 04:42:34Z>
 }}
iex> AttributeRepositoryRiak.put("SGKNRFHMBSKGRVCW4SIJAZMYLE", %{"first_name" => "Xiao", "last_name" => "Ming", "shoe_size" => 36, "subscription_date" => DateTime.from_iso8601("2015-01-29T10:49:58Z") |> elem(1)}, run_opts)
{:ok,
 %{
   "first_name" => "Xiao",
   "last_name" => "Ming",
   "shoe_size" => 36,
   "subscription_date" => #DateTime<2015-01-29 10:49:58Z>
 }}
iex> AttributeRepositoryRiak.put("7WRQL4EAKW27C5BEFF3JDGXBTA", %{"first_name" => "Tomoaki", "last_name" => "Takapamate", "shoe_size" => 34, "subscription_date" => DateTime.from_iso8601("2019-10-13T23:22:51Z") |> elem(1)}, run_opts)
{:ok,
 %{
   "first_name" => "Tomoaki",
   "last_name" => "Takapamate",
   "shoe_size" => 34,
   "subscription_date" => #DateTime<2019-10-13 23:22:51Z>
 }}
iex> AttributeRepositoryRiak.put("WCJBCL7SC2THS7TSRXB2KZH7OQ", %{"first_name" => "Narivelo", "last_name" => "Rajaonarimanana", "shoe_size" => 41, "subscription_date" => DateTime.from_iso8601("2017-06-06T21:01:43Z") |> elem(1), "newsletter_subscribed" => false}, run_opts)
{:ok,
 %{
   "first_name" => "Narivelo",
   "last_name" => "Rajaonarimanana",
   "newsletter_subscribed" => false,
   "shoe_size" => 41,
   "subscription_date" => #DateTime<2017-06-06 21:01:43Z>
 }}
iex> AttributeRepositoryRiak.put("MQNL5ASVNLWZTLJA4MDGHKEXOQ", %{"first_name" => "Hervé", "last_name" => "Le Troadec", "shoe_size" => 48, "subscription_date" => DateTime.from_iso8601("2017-10-19T12:07:03Z") |> elem(1)}, run_opts)
{:ok,
 %{
   "first_name" => "Hervé",
   "last_name" => "Le Troadec",
   "shoe_size" => 48,
   "subscription_date" => #DateTime<2017-10-19 12:07:03Z>
 }}
iex> AttributeRepositoryRiak.put("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", %{"first_name" => "Lisa", "last_name" => "Santana", "shoe_size" => 33, "subscription_date" => DateTime.from_iso8601("2014-08-30T13:45:45Z") |> elem(1), "newsletter_subscribed" => true}, run_opts)
{:ok,
 %{
   "first_name" => "Lisa",
   "last_name" => "Santana",
   "newsletter_subscribed" => true,
   "shoe_size" => 33,
   "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
 }}
iex> AttributeRepositoryRiak.put("4D3FB7C89DC04C808CC756151C", %{"first_name" => "Bigfoot", "shoe_size" => 104, "subscription_date" => DateTime.from_iso8601("1914-10-10T03:42:01Z") |> elem(1)}, run_opts)
{:ok,
 %{
   "first_name" => "Bigfoot",
   "shoe_size" => 104,
   "subscription_date" => #DateTime<1914-10-10 03:42:01Z>
 }}
iex> AttributeRepositoryRiak.get("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", :all, run_opts)
{:ok,
 %{
   "first_name" => "Lisa",
   "last_name" => "Santana",
   "newsletter_subscribed" => true,
   "shoe_size" => 33,
   "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
 }}
iex> AttributeRepositoryRiak.get("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", ["shoe_size"], run_opts)
{:ok, %{"shoe_size" => 33}}
iex> AttributeRepositoryRiak.get!("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", ["shoe_size"], run_opts)
%{"shoe_size" => 33}
iex> AttributeRepositoryRiak.modify("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", [{:replace, "shoe_size", 34}, {:add, "interests", ["rock climbing", "tango", "linguistics"]}], run_opts)
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
iex> AttributeRepositoryRiak.search(~s(last_name eq "Ming"), :all, run_opts)
[
  {"SGKNRFHMBSKGRVCW4SIJAZMYLE",
   %{
     "first_name" => "Xiao",
     "last_name" => "Ming",
     "shoe_size" => 36,
     "subscription_date" => #DateTime<2015-01-29 10:49:58Z>
   }}
]
iex> AttributeRepositoryRiak.search(~s(last_name eq "Ming"), ["shoe_size", "subscription_date"], run_opts)
[
  {"SGKNRFHMBSKGRVCW4SIJAZMYLE",
   %{"shoe_size" => 36, "subscription_date" => #DateTime<2015-01-29 10:49:58Z>}}
]
iex> AttributeRepositoryRiak.search(~s(last_name ew "ana"), :all, run_opts)
[
  {"WCJBCL7SC2THS7TSRXB2KZH7OQ",
   %{
     "first_name" => "Narivelo",
     "last_name" => "Rajaonarimanana",
     "newsletter_subscribed" => false,
     "shoe_size" => 41,
     "subscription_date" => #DateTime<2017-06-06 21:01:43Z>
   }},
  {"Y4HKZMJ3K5A7IMZFZ5O3O56VC4",
   %{
     "first_name" => "Lisa",
     "interests" => ["linguistics", "rock climbing", "tango"],
     "last_name" => "Santana",
     "newsletter_subscribed" => true,
     "shoe_size" => 34,
     "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
   }}
]
iex> AttributeRepositoryRiak.search(~s(last_name co "Le"), :all, run_opts)
[
  {"DKO77TT652NZHXX3WM3ZJBFIC4",
   %{
     "first_name" => "Claude",
     "last_name" => "Leblanc",
     "shoe_size" => 43,
     "subscription_date" => #DateTime<2014-06-13 04:42:34Z>
   }},
  {"MQNL5ASVNLWZTLJA4MDGHKEXOQ",
   %{
     "first_name" => "Hervé",
     "last_name" => "Le Troadec",
     "shoe_size" => 48,
     "subscription_date" => #DateTime<2017-10-19 12:07:03Z>
   }}
]
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
iex> AttributeRepositoryRiak.search(~s(shoe_size le 40), :all, run_opts)
[
  {"SGKNRFHMBSKGRVCW4SIJAZMYLE",
   %{
     "first_name" => "Xiao",
     "last_name" => "Ming",
     "shoe_size" => 36,
     "subscription_date" => #DateTime<2015-01-29 10:49:58Z>
   }},
  {"7WRQL4EAKW27C5BEFF3JDGXBTA",
   %{
     "first_name" => "Tomoaki",
     "last_name" => "Takapamate",
     "shoe_size" => 34,
     "subscription_date" => #DateTime<2019-10-13 23:22:51Z>
   }},
  {"Y4HKZMJ3K5A7IMZFZ5O3O56VC4",
   %{
     "first_name" => "Lisa",
     "interests" => ["linguistics", "rock climbing", "tango"],
     "last_name" => "Santana",
     "newsletter_subscribed" => true,
     "shoe_size" => 34,
     "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
   }}
]
iex> AttributeRepositoryRiak.search(~s(shoe_size le 40 and newsletter_subscribed eq true), :all, run_opts)
[
  {"Y4HKZMJ3K5A7IMZFZ5O3O56VC4",
   %{
     "first_name" => "Lisa",
     "interests" => ["linguistics", "rock climbing", "tango"],
     "last_name" => "Santana",
     "newsletter_subscribed" => true,
     "shoe_size" => 34,
     "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
   }}
]
iex> AttributeRepositoryRiak.search(~s(subscription_date gt "2015-06-01T00:00:00Z"), :all, run_opts)
[
  {"7WRQL4EAKW27C5BEFF3JDGXBTA",
   %{
     "first_name" => "Tomoaki",
     "last_name" => "Takapamate",
     "shoe_size" => 34,
     "subscription_date" => #DateTime<2019-10-13 23:22:51Z>
   }},
  {"MQNL5ASVNLWZTLJA4MDGHKEXOQ",
   %{
     "first_name" => "Hervé",
     "last_name" => "Le Troadec",
     "shoe_size" => 48,
     "subscription_date" => #DateTime<2017-10-19 12:07:03Z>
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
iex> AttributeRepositoryRiak.search(~s(interests eq "rock climbing"), :all, run_opts)
[
  {"Y4HKZMJ3K5A7IMZFZ5O3O56VC4",
   %{
     "first_name" => "Lisa",
     "interests" => ["linguistics", "rock climbing", "tango"],
     "last_name" => "Santana",
     "newsletter_subscribed" => true,
     "shoe_size" => 34,
     "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
   }}
]
iex> AttributeRepositoryRiak.search("not (shoe_size lt 100)", :all, run_opts)
[
  {"4D3FB7C89DC04C808CC756151C",
   %{
     "first_name" => "Bigfoot",
     "shoe_size" => 104,
     "subscription_date" => #DateTime<1914-10-10 03:42:01Z>
   }}
]
```
