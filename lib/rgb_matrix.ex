defmodule RGBMatrix do
  @moduledoc """
  RGBMatrix is a rendering engine for the Nerves Keyboard project. It schedules
  and renders frames. There is a small selection of animations built in.
  """

  @type any_color_model ::
          Chameleon.RGB.t()
          | Chameleon.CMYK.t()
          | Chameleon.Hex.t()
          | Chameleon.HSL.t()
          | Chameleon.HSV.t()
          | Chameleon.Keyword.t()
          | Chameleon.Pantone.t()
end
