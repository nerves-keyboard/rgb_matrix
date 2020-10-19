defmodule RGBMatrix.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nerves-keyboard/rgb_matrix"

  def project do
    [
      app: :rgb_matrix,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.json": :test
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "_build/#{Mix.env()}"
    ]
  end

  defp description do
    """
    Nerves Keyborad rendering engine and animation library
    """
  end

  defp package do
    [
      files: ["lib", ".formatter.exs", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Chris Dosé <chris.dose@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Readme" => "#{@source_url}/blob/v#{@version}/README.md"
      }
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md": [title: "README"],
        "LICENSE.md": [title: "LICENSE"]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:chameleon, "~> 2.2"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: :test, runtime: false},
      {:keyboard_layout, "~> 0.1"}
    ]
  end
end
