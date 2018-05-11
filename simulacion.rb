#--Condiciones Iniciales--
#Variables de control
@nsm1 = 1
@nsm2 = 2
@nsm3 = 3
@tma = 4000 * 60

#Variables de estado
@ns = 0

#Tiempos
@t = 0
@tf = 100
@tpll = 0

#Acumuladores para calculos
@nt = 0
@sta = 0
@ste = 0

#--Puestos--
class Puesto
  attr_accessor :tps, :disponible, :taa, :sto, :pto
  def initialize
    @tps = -1
    @disponible = true
    @taa = 0
    #Para calculos de resultados
    @sto = 0
    @pto = 0
  end
end

@puestos = [Puesto.new, Puesto.new, Puesto.new]

#--Generacion FDPs--
def tiempo_de_atencion
  Random.new.rand + 3
end

def intervalo_de_llegada
  Random.new.rand + 5 + 10
end

#--Metodos de puestos--
def puestos_activos
  @puestos.count { |puesto| puesto.tps != -1 }
end

def puestos_disponibles
  @puestos.count { |puesto| puesto.disponible }
end

def puestos_ocupados
  @puestos.count - puestos_disponibles
end

def puesto_proxima_salida
  puestos_salida = @puestos.select { |puesto| puesto.tps > -1 }
  puesto = false
  puesto = puestos_salida.min_by { |puesto| puesto.tps} if puestos_salida
  puesto
end

#--Entradas y salidas--
def generar_salida puesto
  ta = tiempo_de_atencion
  puesto.tps = @t + ta
  puesto.disponible = puesto.taa < @tma
  puestos.tta = 0 unless puesto.disponible
end

def generar_llegada
  ia = intervalo_de_llegada
  @tpll = @t + ia
end

def procesar_llegada
  @t = @tpll
  generar_llegada
  @ns += 1
  if @ns == @nsm1 && puestos_activos == 0 && puestos_disponibles > 0
    generar_salida @puestos[0]
  elsif @ns == @nsm2 && puestos_activos == 1 && puestos_disponibles > 1
    generar_salida @puestos[1]
  elsif @ns == @nsm3 && puestos_activos == 2 && puestos_disponibles > 2
    generar_salida @puestos[2]
  end
end

def procesar_salida puesto
  @t = puesto.tps
  @ns -= 1
  if @ns >= puestos_activos && puesto.taa < @tma
    generar_salida puesto
  end
  @nt += 1
end

#--Calculo e impresion de resultados--
def calcular_e_imprimir_resultados
  @puestos.each do |puesto|
    puesto.pto = puesto.sto*100 / @t
  end
  pps = (@ste+@sta) / @nt
  pec = @ste / @nt

  puts "Porcentaje de tiempo ocioso del primer puesto: #{@puestos[0].pto}"
  puts "Porcentaje de tiempo ocioso del segundo puesto: #{@puestos[1].pto}"
  puts "Porcentaje de tiempo ocioso del tercer puesto: #{@puestos[2].pto}"
  puts "Promedio de permanencia en el sistema: #{pps}"
  puts "Promedio de espera en cola: #{pec}"
end

#--Algoritmo
while @t < @tf do
  if !puesto_proxima_salida || @tpll < puesto_proxima_salida.tps
    procesar_llegada
  else
    procesar_salida puesto_proxima_salida
  end
end
calcular_e_imprimir_resultados