defmodule Escondida do
  @doc """
  1. Ordena un lote por peso.
  `Enum.sort_by/2` retorna una lista nueva sin alterar la lista original.
  """
  def ordenar_por_peso(lote) do
    Enum.sort_by(lote, fn item -> item.peso end)
  end

  @doc """
  2. Agrega o actualiza el descuento en las reglas.
  Retorna un nuevo mapa con la clave actualizada.
  """
  def con_descuento(reglas, pct) do
    Map.put(reglas, :descuento_pct, pct)
  end

  @doc """
  3. Agrega un ID a la lista de vistos.
  Retorna una nueva lista con el ID al final.
  """
  def registrar(vistos, id) do
    vistos ++ [id]
  end

  @doc """
  4. Actualiza el permiso en el mapa anidado de documentos.
  Usa actualización de mapa anidado para mantener inmutabilidad en ambos niveles.
  """
  def con_permiso(embarque, permiso) do
    %{embarque | documentos: Map.put(embarque.documentos, :permiso, permiso)}
  end

  @doc """
  5. Suma días a una fecha de salida.
  `Date.add/2` retorna una fecha nueva en memoria.
  """
  def fecha_de_entrega(salida, dias) do
    Date.add(salida, dias)
  end
end
