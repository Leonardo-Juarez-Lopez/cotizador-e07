defmodule Cotizador do
  def cotizar(envio, reglas) do
    cond do
      # 1. Validación de peso inválido
      envio.peso_kg <= 0 ->
        {:error, :peso_invalido}

      # 2. Validación de distancia negativa
      envio.distancia_km < 0 ->
        {:error, :distancia_invalida}

      # 3. Tipo de carga no registrada en las reglas
      not Map.has_key?(reglas.recargo, envio.tipo) ->
        {:error, :tipo_desconocido}

      # 4. Puente no registrado en las reglas
      envio.puente != nil and not Map.has_key?(reglas.cuota_puente, envio.puente) ->
        {:error, :puente_desconocido}

      # 5. Carga peligrosa sin número UN
      envio.tipo == :peligrosa and (is_nil(envio.numero_un) or envio.numero_un == "") ->
        {:error, :falta_numero_un}

      # 6. Sobredimensionada sin permiso
      envio.tipo == :sobredimensionada and (is_nil(envio.permiso) or envio.permiso == "") ->
        {:error, :falta_permiso}

      # 7. Exceso de peso (excepto sobredimensionada con permiso)
      envio.peso_kg > reglas.peso_maximo_kg and
          not (envio.tipo == :sobredimensionada and not is_nil(envio.permiso) and envio.permiso != "") ->
        {:error, :excede_peso_maximo}

      true ->
        calcular_cotizacion(envio, reglas)
    end
  end

  defp calcular_cotizacion(envio, reglas) do
    # 1. Flete bruto por distancia
    flete_bruto = envio.distancia_km * reglas.tarifa_km

    # 2. Cuota de puente
    monto_puente =
      if envio.puente do
        Map.get(reglas.cuota_puente, envio.puente, 0)
      else
        0
      end

    subtotal = flete_bruto + monto_puente

    # 3. Descuento por volumen (se calcula sobre el flete bruto)
    desc_config = reglas.descuento

    aplica_descuento =
      case desc_config.criterio do
        :a_partir_de -> envio.peso_kg >= desc_config.umbral_kg
        :mayor_a -> envio.peso_kg > desc_config.umbral_kg
        _ -> false
      end

    monto_descuento =
      if aplica_descuento do
        round(flete_bruto * desc_config.pct / 100)
      else
        0
      end

    flete_neto = flete_bruto - monto_descuento
    subtotal_neto = subtotal - monto_descuento

    # 4. Recargos por tipo de carga (calculados sobre la base con descuento)
    recargo_config = Map.get(reglas.recargo, envio.tipo, %{pct: 0, fija: 0})

    base_recargo =
      case Map.get(reglas, :base_recargo, :subtotal) do
        :subtotal -> subtotal_neto
        _ -> flete_neto
      end

    monto_recargo = round(base_recargo * recargo_config.pct / 100) + recargo_config.fija

    # 5. Cálculo final y ajuste por tarifa mínima
    monto_calculado = subtotal_neto + monto_recargo

    minimo = Map.get(reglas, :minimo, 0)

    {ajuste_minimo, total_final} =
      if monto_calculado < minimo do
        {minimo - monto_calculado, minimo}
      else
        {0, monto_calculado}
      end

    resultado = %{
      flete_bruto: flete_bruto,
      flete: flete_neto,
      puente: monto_puente,
      cuota_puente: monto_puente,
      subtotal: subtotal,
      recargo: monto_recargo,
      descuento: monto_descuento,
      ajuste_minimo: ajuste_minimo,
      total: total_final
    }

    {:ok, resultado}
  end

  # Resumen para lotes de cotizaciones
  def resumen(lote, reglas) do
    results = Enum.map(lote, fn envio -> {envio, cotizar(envio, reglas)} end)

    {exitos, fallos} = Enum.split_with(results, fn {_, res} -> match?({:ok, _}, res) end)

    cotizaciones = Enum.map(exitos, fn {_, {:ok, c}} -> c end)
    rechazados = Enum.map(fallos, fn {e, {:error, motivo}} -> {e.id, motivo} end)

    monto_total = Enum.reduce(cotizaciones, 0, fn c, acc -> acc + c.total end)

    por_puente =
      Enum.reduce(exitos, %{}, fn {envio, {:ok, cotizacion}}, acc ->
        if envio.puente do
          Map.update(acc, envio.puente, cotizacion.total, &(&1 + cotizacion.total))
        else
          acc
        end
      end)

    %{
      total: monto_total,
      monto_total: monto_total,
      cotizados: length(cotizaciones),
      aceptados: cotizaciones,
      cotizaciones: cotizaciones,
      rechazados: rechazados,
      errores: rechazados,
      por_puente: por_puente,
      cantidad_aceptados: length(cotizaciones),
      cantidad_rechazados: length(rechazados)
    }
  end
end
