defmodule Neurotick.MixProject do
  use Mix.Project
  
  @project_url "https://github.com/DaanKrug/neurotick"

  def project do
    [
      app: :neurotick,
      version: "0.0.2",
      elixir: "~> 1.13",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Neurotick",
      description: "Common Neural Network functionalities to improve a TWEANN mechanism.",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      docs: [main: "readme", extras: ["README.md"]],
      deps: deps(),
      xref: [exclude: []]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:earmark, "~> 1.4.13", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:krug, "~> 1.1.45"}
    ]
  end
  
  defp aliases do
    [c: "compile", d: "docs"]
  end
  
  defp package do
    [
      maintainers: ["Daniel Augusto Krug @daankrug <daniel-krug@hotmail.com>"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
  
end
