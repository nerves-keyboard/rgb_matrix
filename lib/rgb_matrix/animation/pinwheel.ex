defmodule RGBMatrix.Animation.Pinwheel do
  @moduledoc """
  Cycles hue in a pinwheel pattern.
  """

  alias Chameleon.HSV

  alias RGBMatrix.{Animation, Frame}

  import RGBMatrix.Utils, only: [mod: 2]

  use Animation

  @center %{
    x: 1,
    y: 1.5
  }

  @impl Animation
  def next_frame(animation) do
    %Animation{tick: tick, speed: speed} = animation
    time = div(tick * speed, 100)

    # FIXME: no reaching into Xebow namespace
    pixels = Xebow.Utils.pixels()

    pixel_colors =
      for {x, y} <- pixels do
        dx = x - @center.x
        dy = y - @center.y

        hue = mod(atan2_8(dy, dx) + time, 360)

        HSV.new(hue, 100, 100)
      end

    Frame.new(pixels, pixel_colors)
  end

  defp atan2_8(x, y) do
    atan = :math.atan2(x, y)

    trunc((atan + :math.pi()) * 359 / (2 * :math.pi()))
  end
end
