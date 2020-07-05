defmodule RGBMatrix.Engine do
  @moduledoc """
  Renders [`Animation`](`RGBMatrix.Animation`)s and outputs
  [`Frame`](`RGBMatrix.Frame`)s to be displayed.
  """

  use GenServer

  alias Layout.LED
  alias RGBMatrix.Animation

  defmodule State do
    @moduledoc false
    defstruct [:leds, :animation, :paintables]
  end

  # Client

  @doc """
  Start the engine.

  This module registers its process globally and is expected to be started by
  a supervisor.

  This function accepts the following arguments as a tuple:
  - `leds` - The list of LEDs to be painted on.
  - `initial_animation` - The animation that plays when the engine starts.
  - `paintables` - A list of modules to output `RGBMatrix.Frame` to that implement
      the `RGBMatrix.Paintable` behavior. If you want to register your paintables
      dynamically, set this to an empty list `[]`.
  """
  @spec start_link(
          {leds :: [LED.t()], initial_animation :: Animation.t(), paintables :: list(module)}
        ) ::
          GenServer.on_start()
  def start_link({leds, initial_animation, paintables}) do
    GenServer.start_link(__MODULE__, {leds, initial_animation, paintables}, name: __MODULE__)
  end

  @doc """
  Play the given animation.

  Note that the animation can be played synchronously by passing `:false` for the `:async` option. However, only
  looping (animations with `:loop` >= 1) animations may be played this way. This is to ensure that the caller is not
  blocked forever.
  """
  @spec play_animation(animation :: Animation.t(), opts :: keyword()) :: :ok
  def play_animation(animation, opts \\ []) do
    async? = Keyword.get(opts, :async, true)

    if async? do
      GenServer.cast(__MODULE__, {:play_animation, animation})
    else
      GenServer.call(__MODULE__, {:play_animation, animation})
    end
  end

  @doc """
  Register a `RGBMatrix.Paintable` for the engine to paint pixels to.
  This function is idempotent.
  """
  @spec register_paintable(paintable :: module) :: :ok
  def register_paintable(paintable) do
    GenServer.call(__MODULE__, {:register_paintable, paintable})
  end

  @doc """
  Unregister a `RGBMatrix.Paintable` so the engine no longer paints pixels to it.
  This function is idempotent.
  """
  @spec unregister_paintable(paintable :: module) :: :ok
  def unregister_paintable(paintable) do
    GenServer.call(__MODULE__, {:unregister_paintable, paintable})
  end

  # Server

  @impl GenServer
  def init({leds, initial_animation, paintables}) do
    send(self(), :get_next_frame)

    initial_state = %State{leds: leds, paintables: %{}}

    state =
      Enum.reduce(paintables, initial_state, fn paintable, state ->
        add_paintable(paintable, state)
      end)
      |> set_animation(initial_animation)

    {:ok, state}
  end

  defp add_paintable(paintable, state) do
    paintables = Map.put(state.paintables, paintable, paintable.get_paint_fn)
    %State{state | paintables: paintables}
  end

  defp remove_paintable(paintable, state) do
    paintables = Map.delete(state.paintables, paintable)
    %State{state | paintables: paintables}
  end

  defp set_animation(state, animation) do
    %State{state | animation: animation}
  end

  @impl GenServer
  def handle_info(:get_next_frame, state) do
    animation = Animation.next_frame(state.animation)

    state.paintables
    |> Map.values()
    |> Enum.each(fn paint_fn ->
      paint_fn.(animation.next_frame)
    end)

    Process.send_after(self(), :get_next_frame, animation.delay_ms)
    {:noreply, set_animation(state, animation)}
  end

  @impl GenServer
  def handle_info({:reset_animation, reset_animation}, state) do
    {:noreply, set_animation(state, reset_animation)}
  end

  @impl GenServer
  def handle_info({:reply, from, reset_animation}, state) do
    GenServer.reply(from, :ok)

    {:noreply, set_animation(state, reset_animation)}
  end

  @impl GenServer
  def handle_cast({:play_animation, %{loop: loop} = animation}, state)
      when is_integer(loop) and loop >= 1 do
    current_animation = state.animation
    expected_duration = Animation.duration(animation)
    Process.send_after(self(), {:reset_animation, current_animation}, expected_duration)

    {:noreply, set_animation(state, animation)}
  end

  @impl GenServer
  def handle_cast({:play_animation, %{loop: 0} = _animation}, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:play_animation, animation}, state) do
    {:noreply, set_animation(state, animation)}
  end

  @impl GenServer
  def handle_call({:play_animation, %{loop: loop} = animation}, from, state)
      when is_integer(loop) and loop >= 1 do
    current_animation = state.animation
    duration = Animation.duration(animation)
    Process.send_after(self(), {:reply, from, current_animation}, duration)

    {:noreply, set_animation(state, animation)}
  end

  @impl GenServer
  def handle_call({:register_paintable, paintable}, _from, state) do
    state = add_paintable(paintable, state)
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:unregister_paintable, paintable}, _from, state) do
    state = remove_paintable(paintable, state)
    {:reply, :ok, state}
  end
end
