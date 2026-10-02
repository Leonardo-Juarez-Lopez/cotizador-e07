defmodule SinMutacion do
  @doc """
  1. total_pesos: usa Enum.reduce con un acumulador inicial en 0.
  """
  def total_pesos(embarques) do
    Enum.reduce(embarques, 0, fn e, acc -> acc + e.peso_kg end)
  end

  @doc """
  2. marcar_urgentes: usa Enum.map y Map.put para agregar/actualizar la llave :urgente.
  """
  def marcar_urgentes(embarques) do
    Enum.map(embarques, fn e ->
      Map.put(e, :urgente, e.distancia_km > 500)
    end)
  end

  @doc """
  3. aplicar_descuento: usa Enum.map para transformar cada precio.
  """
  def aplicar_descuento(precios, pct) do
    Enum.map(precios, fn precio ->
      descuento = div(precio * pct + 50, 100)
      precio - descuento
    end)
  end

  @doc """
  4. contar_por_tipo: usa Enum.reduce con un mapa inicial %{} y Map.update.
  """
  def contar_por_tipo(embarques) do
    Enum.reduce(embarques, %{}, fn e, conteo ->
      Map.update(conteo, e.tipo, 1, fn actual -> actual + 1 end)
    end)
  end

  @doc """
  5. sin_duplicados: usando Enum.reduce para construir una lista sin repetidos.
  """
  def sin_duplicados(ids) do
    ids
    |> Enum.reduce([], fn id, acc ->
      if id in acc, do: acc, else: acc ++ [id]
    end)
  end
end
