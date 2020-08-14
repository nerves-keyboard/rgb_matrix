defmodule RGBMatrix.Animation.Config.FieldType.Integer do
  @moduledoc """
  An integer field type for use in animation configuration.

  Supports defining a minimum and a maximum, as well as a step value.
  """

  @behaviour RGBMatrix.Animation.Config.FieldType

  import RGBMatrix.Utils, only: [mod: 2]

  @enforce_keys [:default, :min, :max]
  @optional_keys [step: 1, doc: []]
  defstruct @enforce_keys ++ @optional_keys

  @type t :: %__MODULE__{
          default: integer,
          min: integer,
          max: integer,
          doc: keyword(String.t()) | []
        }

  @impl true
  @spec validate(field_type :: t, value :: integer) :: :ok | :error
  def validate(field_type, value) do
    if value >= field_type.min &&
         value <= field_type.max &&
         mod(value, field_type.step) == 0 do
      :ok
    else
      :error
    end
  end

  @impl true
  @spec cast(field_type :: t, value :: any) :: {:ok, integer} | :error
  def cast(field_type, value) do
    with {:ok, casted_value} <- do_cast(value),
         :ok <- validate(field_type, casted_value) do
      {:ok, casted_value}
    else
      :error -> :error
    end
  end

  defp do_cast(value) when is_integer(value) do
    {:ok, value}
  end

  defp do_cast(value) when is_float(value) do
    {:ok, trunc(value)}
  end

  defp do_cast(value) when is_binary(value) do
    case Integer.parse(value) do
      {parsed_value, _remaining_string} -> {:ok, parsed_value}
      :error -> :error
    end
  end

  defp do_cast(_) do
    :error
  end
end