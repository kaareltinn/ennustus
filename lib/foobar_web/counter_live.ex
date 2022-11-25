defmodule FoobarWeb.CounterLive do
  use FoobarWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  def handle_event("inc", _value, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end
end
