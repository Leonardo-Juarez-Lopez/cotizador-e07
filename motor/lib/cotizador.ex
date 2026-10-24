defmodule Cotizador do
  @moduledoc """
  Motor del cotizador: cálculo puro, sin estado mutable.
  Las reglas de la variante llegan como argumento; aquí no hay números de E07.
  """

  @tipos [:general, :refrigerada, :peligrosa, :sobredimensionada]

  # Validar, y solo si pasa, calcular.
  def cotizar(embarque, reglas) do
    with :ok <- validar(embarque, reglas) do
      {:ok, calcular(embarque, reglas)}
    end
  end

  # ── Validación: una cláusula por motivo, en el orden del enunciado ──

  defp validar(%{peso_kg: p}, _reglas) when p <= 0, do: {:error, :peso_invalido}
  defp validar(%{distancia_km: d}, _reglas) when d <= 0, do: {:error, :distancia_invalida}
  defp validar(%{tipo: t}, _reglas) when t not in @tipos, do: {:error, :tipo_desconocido}

  defp validar(%{puente: p}, %{cuota_puente: cuotas}) when not is_map_key(cuotas, p),
    do: {:error, :puente_desconocido}

  defp validar(%{tipo: :peligrosa, numero_un: un}, _reglas) when un in [nil, ""],
    do: {:error, :falta_numero_un}

  defp validar(%{tipo: :sobredimensionada, permiso: p}, _reglas) when p in [nil, ""],
    do: {:error, :falta_permiso}

  # La sobredimensionada (con permiso) no tiene peso máximo: va antes de esa cláusula.
  defp validar(%{tipo: :sobredimensionada}, _reglas), do: :ok

  defp validar(%{peso_kg: p}, %{peso_maximo_kg: max}) when p > max,
    do: {:error, :excede_peso_maximo}

  defp validar(_embarque, _reglas), do: :ok

  # ── Cálculo ──

  defp calcular(e, r) do
    flete_bruto = e.distancia_km * r.tarifa_km
    descuento = descuento(e.peso_kg, r.descuento, flete_bruto)
    flete = flete_bruto - descuento
    cuota = Map.fetch!(r.cuota_puente, e.puente)
    %{pct: pct_recargo, fija: fija} = Map.fetch!(r.recargo, e.tipo)
    recargo = pct(base_recargo(r.base_recargo, flete, cuota), pct_recargo) + fija
    subtotal = flete + cuota + recargo
    total = max(subtotal, r.minimo)

    %{
      id: e.id,
      flete_bruto: flete_bruto,
      descuento: descuento,
      flete: flete,
      cuota_puente: cuota,
      recargo: recargo,
      ajuste_minimo: total - subtotal,
      total: total
    }
  end

  # El criterio del descuento se decide con cláusulas, no con if.
  defp descuento(peso, %{criterio: :a_partir_de, umbral_kg: u, pct: p}, monto) when peso >= u,
    do: pct(monto, p)

  defp descuento(peso, %{criterio: :mas_de, umbral_kg: u, pct: p}, monto) when peso > u,
    do: pct(monto, p)

  defp descuento(_peso, _descuento, _monto), do: 0

  # La base del recargo: solo el flete, o flete + cuota (subtotal).
  defp base_recargo(:flete, flete, _cuota), do: flete
  defp base_recargo(:subtotal, flete, cuota), do: flete + cuota

  # Un porcentaje, redondeado al centavo, las mitades hacia arriba. Solo enteros.
  defp pct(monto, p), do: div(monto * p + 50, 100)

  # ── Resumen de un lote: Enum y |> ──

  def resumen(embarques, reglas) do
    inicial = %{
      cotizaciones: [],
      rechazados: [],
      por_puente: Map.new(reglas.cuota_puente, fn {puente, _cuota} -> {puente, 0} end)
    }

    acumulado =
      embarques
      |> Enum.map(fn e -> {e, cotizar(e, reglas)} end)
      |> Enum.reduce(inicial, &acumular/2)

    %{
      cotizados: length(acumulado.cotizaciones),
      rechazados: Enum.reverse(acumulado.rechazados),
      total: sumar_totales(acumulado.cotizaciones),
      por_puente: acumulado.por_puente
    }
  end

  defp acumular({e, {:ok, c}}, acc) do
    %{
      acc
      | cotizaciones: [c | acc.cotizaciones],
        por_puente: Map.update!(acc.por_puente, e.puente, &(&1 + c.total))
    }
  end

  defp acumular({e, {:error, motivo}}, acc) do
    %{acc | rechazados: [{e.id, motivo} | acc.rechazados]}
  end

  # Recursiva a mano, sin Enum: lista vacía suma 0; si no, la cabeza más la suma del resto.
  defp sumar_totales([]), do: 0
  defp sumar_totales([c | resto]), do: c.total + sumar_totales(resto)
end
