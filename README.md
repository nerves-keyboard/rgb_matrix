# RGBMatrix

[![CI Status](https://github.com/nerves-keyboard/rgb_matrix/workflows/CI/badge.svg)](https://github.com/nerves-keyboard/rgb_matrix/actions)
[![codecov](https://codecov.io/gh/nerves-keyboard/rgb_matrix/branch/master/graph/badge.svg)](https://codecov.io/gh/nerves-keyboard/rgb_matrix)
[![Hex.pm Version](https://img.shields.io/hexpm/v/rgb_matrix.svg?style=flat)](https://hex.pm/packages/rgb_matrix)
[![License](https://img.shields.io/hexpm/l/rgb_matrix.svg)](LICENSE.md)

RGBMatrix is a rendering engine for the Nerves Keyboard project. It schedules
and renders frames. There is a small selection of animations built in.

A layout of LEDs must be defined to use animations. The layout is handled by
[KeyboardLayout](https://github.com/nerves-keyboard/keyboard_layout), which is
included as a dependency. See the documentation for that library for how to
define layouts.

## Installation

The package can be installed by adding `rgb_matrix` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:rgb_matrix, "~> 0.1"}
  ]
end
```

## License

This library is licensed under the [MIT license](./LICENSE.md)
