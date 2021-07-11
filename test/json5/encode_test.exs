defmodule Json5.EncodeTest do
  use ExUnit.Case, async: true

  @valid [
    [:number, "1", 1],
    [:float, "3.14", 3.14],
    [:decimal, "1.2E+4", Macro.escape(Decimal.new("12e3"))],
    [:string, "'just some text'", "just some text"],
    [:array, "[1, 2, 3]", [1, 2, 3]],
    [:array, "[1, null, 'text']", [1, nil, "text"]],
    [:object, "{test: 1, }", Macro.escape(%{test: 1})],
    [:object, "{'new': 1, }", Macro.escape(%{new: 1})],
    [:object, "{'using spaces': 1, }", Macro.escape(%{"using spaces" => 1})],
    [
      :mixed_object,
      """
      {array: [1, 2, 3], nested: {more: 123, }, valid_key: true, 'using spaces': 1, }\
      """,
      Macro.escape(%{
        "using spaces" => 1,
        valid_key: true,
        nested: %{more: 123},
        array: [1, 2, 3]
      })
    ]
  ]

  for [prefix, expected, input] <- @valid do
    test "encode #{prefix} #{expected}" do
      assert {:ok, unquote(expected)} = Json5.encode(unquote(input))
    end
  end

  test "encode array pretty" do
    input = ["one", "two", "three"]

    expected = """
    [
      'one',
      'two',
      'three',
    ]
    """

    assert expected == Json5.encode!(input, pretty: true)
  end

  test "encode object map pretty" do
    input = %{
      "using spaces" => 1,
      valid_key: true,
      nested: %{more: 123},
      array: [1, 2, 3]
    }

    expected = """
    {
      array: [
        1,
        2,
        3,
      ],
      nested: {
        more: 123,
      },
      valid_key: true,
      'using spaces': 1,
    }
    """

    assert expected == Json5.encode!(input, pretty: true)
  end

  test "encode object map compact" do
    input = %{
      "using spaces" => 1,
      valid_key: true,
      nested: %{more: 123},
      array: [1, 2, 3]
    }

    expected = """
    {array:[1,2,3],nested:{more:123},valid_key:true,'using spaces':1}\
    """

    assert expected == Json5.encode!(input, compact: true)
  end

  test "encode invalid input" do
    assert {:error, %Json5.Error{type: :invalid_input} = exception} =
             Json5.encode(0..10, %{compact: true})

    assert "unable to format input" == Exception.message(exception)
  end
end
