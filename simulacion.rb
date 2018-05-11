require 'statistics'

#--Condiciones Iniciales--
#Variables de control
@nsm1 = 20
@nsm2 = 40
@nsm3 = 60

#Variables de estado
@ns = 0

#Tiempos
@t = 0
@tf = 10000
@tpll = 0

#Acumuladores para calculos
@nt = 0
@ss = 0
@sll = 0

#--Puestos--
class Puesto
  attr_accessor :tps, :ito, :sto, :pto
  def initialize
    @tps = -1
    #Para calculos de resultados
    @ito = 0
    @sto = 0
    @pto = 0
  end
end

@puestos = [Puesto.new, Puesto.new, Puesto.new]

#--Generacion FDPs--
def tiempo_de_atencion
  Statistics::Distribution::Weibull.new(2.0077, 129.92).random
end

def intervalo_de_llegada
  Statistics::Distribution::Weibull.new(1, 1422.4).random
end

#--Metodos de puestos--
def puestos_activos
  @puestos.count { |puesto| puesto.tps != -1 }
end

def puesto_proxima_salida
  puestos_salida = @puestos.select { |puesto| puesto.tps > -1 }
  puesto = false
  puesto = puestos_salida.min_by { |puesto| puesto.tps} if puestos_salida
  puesto
end

def puesto_proxima_atencion
  puestos_libres = @puestos.select { |puesto| puesto.tps == -1 }
  puesto = puestos_libres.min_by { |puesto| puesto.sto}
  puesto
end

#--Entradas y salidas--
def generar_salida puesto
  ta = tiempo_de_atencion
  puesto.tps = @t + ta
end

def generar_llegada
  ia = intervalo_de_llegada
  @tpll = @t + ia
end

def procesar_llegada
  @t = @tpll
  generar_llegada
  @ns += 1
  if (@ns == @nsm1 && puestos_activos == 0) || 
    (@ns == @nsm2 && puestos_activos == 1) ||
    (@ns == @nsm3 && puestos_activos == 2)
    puesto = puesto_proxima_atencion
    puesto.sto = @t - puesto.ito
    generar_salida puesto
  end
  @sll += @t
end

def procesar_salida puesto
  @t = puesto.tps
  @ns -= 1
  if @ns >= puestos_activos
    generar_salida puesto
  else
    puesto.ito = @t
    puesto.tps = -1
  end
  @nt += 1
  @ss += @t
end

#--Calculo e impresion de resultados--
def calcular_e_imprimir_resultados
  @puestos.each do |puesto|
    puesto.pto = puesto.sto*100 / @t
  end
  pps = (@ss-@sll) / @nt

  puts "Porcentaje de tiempo ocioso del primer puesto: #{@puestos[0].pto}"
  puts "Porcentaje de tiempo ocioso del segundo puesto: #{@puestos[1].pto}"
  puts "Porcentaje de tiempo ocioso del tercer puesto: #{@puestos[2].pto}"
  puts "Promedio de permanencia en el sistema: #{pps}"
end
#--Algoritmo
while @t < @tf || @ns>0 do
  @tpll = @tf * 9999999999 if @ns>0 && @t >= @tf
  if !puesto_proxima_salida || @tpll < puesto_proxima_salida.tps
    procesar_llegada
  else
    procesar_salida puesto_proxima_salida
  end
end
calcular_e_imprimir_resultados
