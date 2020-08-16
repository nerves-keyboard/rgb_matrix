defmodule RGBMatrix.Animation.Config.FieldType.Option do
  @moduledoc """
  An option field type for use in animation configuration.

  Supports defining a list of pre-defined options as atoms.

  To define an option field in an animation, specify `:option` as the field
  type.

  Example:
      field :direction, :option,
        default: :right,
        options: ~w(right left up down)a, # This must be a list of atoms
        doc: [
          name: "Direction",
          description: \"""
          Controls the direction of the wave
          \"""
        ]

        # Also valid:
        options: [
          :right,
          :left,
          :up,
          :down
        ]
  """

  @behaviour RGBMatrix.Animation.Config.FieldType

  @enforce_keys [:default, :options]
  @optional_keys [doc: []]
  defstruct @enforce_keys ++ @optional_keys

  @type t :: %__MODULE__{
          default: atom,
          options: [atom],
          doc: keyword(String.t()) | []
        }
  @type value :: atom

  @impl true
  @spec validate(field_type :: t, value) :: :ok | :validation_error
  def validate(%__MODULE__{options: options} = _field_type, value) do
    if value in options do
      :ok
    else
      :validation_error
    end
  end

  @impl true
  @spec cast(field_type :: t, any) ::
          {:ok, value} | :cast_error | :validation_error
  def cast(field_type, value) do
    with {:ok, casted_value} <- do_cast(value),
         :ok <- validate(field_type, casted_value) do
      {:ok, casted_value}
    else
      :validation_error = e -> e
      :error -> :cast_error
    end
  end

  defp do_cast(binary_value) when is_binary(binary_value) do
    {:ok, String.to_existing_atom(binary_value)}
  rescue
    ArgumentError -> :error
  end

  defp do_cast(value) when is_atom(value), do: {:ok, value}

  defp do_cast(_value), do: :error
end
