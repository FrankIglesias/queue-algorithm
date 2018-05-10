@nsm1 = 20
@nsm2 = 40
@nsm3 = 60
@tma = 4000 * 60
@ns = 0
@t = 0
@ta = 0
@sta = 0
@tf = 300
@tpll = 0

class Puesto
  attr_accessor :tps, :disponible, :sta
  def initialize
    @tps = -1
    @disponible = true
    @sta = 0
  end
end

def tiempo_de_atencion
  Random.new.rand + 3
end

def intervalo_de_llegada
  Random.new.rand + 5 + 10
end

@puestos = [Puesto.new, Puesto.new, Puesto.new]

def puestos_activos
  @puestos.count { |puesto| puesto.tps == -1 }
end

def puestos_disponibles
  @puestos.count { |puesto| puesto.disponible }
end

def puestos_ocupados
  @puestos.count - puestos_disponibles
end

def proxima_salida
  @puestos.select { |puesto| puesto.tps > -1 }.min
end

def generar_salida puesto
  ta = tiempo_de_atencion
  @puestos[puesto].tps = @t + ta
  @puestos[puesto].disponible = @puestos[puesto].sta > @tma
  @puestos[puesto].sta = 0 unless @puestos[puesto].disponible
end

def procesar_llegada
  @t = @tpll
  @tpll = @t + intervalo_de_llegada
  @ns += 1
  if @ns <= @nsm1 && !puestos_activos && puestos_disponibles > 0
    generar_salida 1
  elsif @ns == @nsm2 && puestos_activos == 1
    generar_salida 2
  elsif @ns == @nsm3 && puestos_activos == 2 && puestos_disponibles > 2
    generar_salida 3
  end
end

def procesar_salida
  @ns -= 1
end

while @t < @tf do
  if !proxima_salida || @tpll < proxima_salida
    procesar_llegada
  else
    procesar_salida
  end
end