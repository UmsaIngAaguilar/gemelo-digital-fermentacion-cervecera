# Escenarios de simulación

Este archivo documenta los escenarios utilizados para la simulación multiescenario del proceso de fermentación y maduración cervecera tipo pilsener/lager en tanque cilindrocónico.

Los escenarios fueron definidos para evaluar el desempeño comparativo de los controladores PID y MPC bajo diferentes condiciones de operación simulada. Los valores utilizados son referenciales para simulación académica y no corresponden a datos oficiales de planta.

---

1. Propósito de los escenarios

Los escenarios de simulación tienen como finalidad analizar la respuesta térmica del proceso bajo condiciones nominales y modificadas.

En particular, se busca evaluar:

- el seguimiento de una referencia térmica variable de 15 días;
- la respuesta del controlador PID;
- la respuesta del controlador MPC;
- la sensibilidad ante perturbaciones térmicas;
- la sensibilidad ante variaciones del sustrato inicial;
- el efecto de los controladores sobre indicadores de desempeño térmico.

---

2. Horizonte de simulación

Todos los escenarios consideran el mismo horizonte temporal:

tf = 360 h
Equivalente a:

15 días = 5 días de fermentación + 10 días de maduración

El paso de simulación utilizado fue:

dt = 0.25 h

Por tanto, el vector de tiempo se define como:

t = 0:dt:tf;
3. Perfil térmico de referencia

Todos los escenarios utilizan el mismo perfil térmico de referencia para el proceso de fermentación y maduración.

Etapa	Tiempo	Temperatura de referencia
Inicio / inoculación	0 h	10 °C
Fermentación inicial	0–24 h	10 °C a 12 °C
Fermentación principal	24–72 h	12 °C
Descanso / final de fermentación	72–96 h	12 °C a 14 °C
Fin de fermentación	96–120 h	14 °C
Enfriamiento a maduración	120–144 h	14 °C a -1.5 °C
Maduración fría	144–360 h	-1.5 °C

La referencia térmica se define como:

Tref(t): temperatura de referencia variable en el tiempo
4. Variables de estado iniciales

El modelo considera cuatro variables de estado:

Variable	Descripción	Unidad
X	Biomasa o concentración de levadura	g/L
S	Sustrato o extracto fermentable	g/L
P	Producto asociado al etanol	g/L
T	Temperatura del fermentador	°C

Las condiciones iniciales base son:

Variable	Valor base	Unidad
X0	1.0	g/L
S0	140.0	g/L
P0	0.0	g/L
T0	10.0	°C
5. Escenarios considerados

La simulación multiescenario consideró cinco escenarios principales.

Escenario	Nombre en MATLAB	Condición	S0 [g/L]	T0 [°C]	Perturbación
E1	E1_Pilsen_15dias_sin_perturbacion	Base sin perturbación	140	10	No
E2	E2_Pilsen_15dias_perturbacion_moderada	Perturbación térmica moderada	140	10	Sí
E3	E3_Pilsen_15dias_perturbacion_fuerte	Perturbación térmica fuerte	140	10	Sí
E4	E4_Pilsen_sustrato_bajo_120	Sustrato inicial bajo	120	10	Sí
E5	E5_Pilsen_sustrato_alto_160	Sustrato inicial alto	160	10	Sí
6. Definición de escenarios en MATLAB

En el script principal, los escenarios fueron definidos mediante una estructura struct.

escenarios = struct([]);

escenarios(1).nombre = 'E1_Pilsen_15dias_sin_perturbacion';
escenarios(1).S0 = 140;
escenarios(1).T0 = 10;
escenarios(1).tipoPerturbacion = 0;

escenarios(2).nombre = 'E2_Pilsen_15dias_perturbacion_moderada';
escenarios(2).S0 = 140;
escenarios(2).T0 = 10;
escenarios(2).tipoPerturbacion = 1;

escenarios(3).nombre = 'E3_Pilsen_15dias_perturbacion_fuerte';
escenarios(3).S0 = 140;
escenarios(3).T0 = 10;
escenarios(3).tipoPerturbacion = 2;

escenarios(4).nombre = 'E4_Pilsen_sustrato_bajo_120';
escenarios(4).S0 = 120;
escenarios(4).T0 = 10;
escenarios(4).tipoPerturbacion = 1;

escenarios(5).nombre = 'E5_Pilsen_sustrato_alto_160';
escenarios(5).S0 = 160;
escenarios(5).T0 = 10;
escenarios(5).tipoPerturbacion = 1;
7. Tipos de perturbación térmica

Las perturbaciones térmicas fueron incorporadas para evaluar la capacidad de los controladores ante alteraciones en el proceso.

Tipo de perturbación	Valor	Unidad	Descripción
0	0.00	°C/h	Sin perturbación
1	0.20	°C/h	Perturbación térmica moderada
2	0.40	°C/h	Perturbación térmica fuerte

La perturbación fue aplicada durante la etapa de fermentación activa, en el intervalo:

60 h ≤ t ≤ 72 h
8. Función de perturbación térmica

La perturbación térmica fue implementada en MATLAB mediante la siguiente lógica:

function d = perturbacion_termica_15dias(t, tipoPert)
% Perturbación térmica aplicada durante una ventana crítica del proceso.
% Se ubica durante la fase de fermentación activa, alrededor de 60 a 72 h.

    if t >= 60 && t <= 72

        switch tipoPert
            case 0
                d = 0.0;     % sin perturbación
            case 1
                d = 0.20;    % perturbación moderada [°C/h]
            case 2
                d = 0.40;    % perturbación fuerte [°C/h]
            otherwise
                d = 0.0;
        end

    else
        d = 0.0;
    end
end
9. Descripción individual de los escenarios
9.1 Escenario E1: Base sin perturbación

El escenario E1 representa la condición nominal del proceso.

S0 = 140 g/L
T0 = 10 °C
tipoPerturbacion = 0

Este escenario permite evaluar el seguimiento térmico de los controladores PID y MPC sin alteraciones externas.

Su finalidad es servir como referencia base para comparar el desempeño de los demás escenarios.

9.2 Escenario E2: Perturbación térmica moderada

El escenario E2 introduce una perturbación térmica moderada durante la etapa de fermentación activa.

S0 = 140 g/L
T0 = 10 °C
tipoPerturbacion = 1
d = 0.20 °C/h entre 60 h y 72 h

Este escenario permite evaluar la capacidad de los controladores para rechazar una perturbación de magnitud moderada.

9.3 Escenario E3: Perturbación térmica fuerte

El escenario E3 introduce una perturbación térmica fuerte durante la etapa de fermentación activa.

S0 = 140 g/L
T0 = 10 °C
tipoPerturbacion = 2
d = 0.40 °C/h entre 60 h y 72 h

Este escenario permite evaluar la robustez de los controladores frente a una condición térmica más exigente.

9.4 Escenario E4: Sustrato inicial bajo

El escenario E4 considera una reducción del sustrato inicial respecto al caso base.

S0 = 120 g/L
T0 = 10 °C
tipoPerturbacion = 1
d = 0.20 °C/h entre 60 h y 72 h

Este escenario permite evaluar la respuesta del modelo ante una condición inicial de menor extracto fermentable.

9.5 Escenario E5: Sustrato inicial alto

El escenario E5 considera un aumento del sustrato inicial respecto al caso base.

S0 = 160 g/L
T0 = 10 °C
tipoPerturbacion = 1
d = 0.20 °C/h entre 60 h y 72 h

Este escenario permite evaluar la respuesta del modelo ante una condición inicial de mayor extracto fermentable.

10. Controladores evaluados

En todos los escenarios se evaluaron dos estrategias de control:

Controlador	Descripción
PID	Controlador convencional proporcional-integral-derivativo
MPC	Control predictivo basado en modelo

La comparación principal se realizó mediante indicadores cuantitativos.

11. Indicadores calculados por escenario

Para cada escenario y para cada controlador se calcularon los siguientes indicadores:

Indicador	Descripción
MSE	Error cuadrático medio
IAE	Error absoluto integral
StdError	Desviación estándar del error térmico
StdT	Desviación estándar de la temperatura
ErrorMax	Error máximo absoluto
EsfuerzoControl	Esfuerzo de control
UltimoInstanteFueraBanda	Último instante fuera de la banda de tolerancia
TiempoAcumuladoFueraBanda	Tiempo total acumulado fuera de banda

El error se calculó respecto a la referencia variable:

e(t) = T(t) - Tref(t)
12. Resultados comparativos principales

Los resultados finales mostraron que el controlador MPC presentó mejor seguimiento térmico que el controlador PID en los cinco escenarios evaluados.

Escenario	Mejora MSE [%]	Mejora IAE [%]	Mejora StdError [%]	Mejora ErrorMax [%]	Incremento Eu [%]
E1	84.10	69.96	60.52	68.66	131.77
E2	85.42	73.79	62.22	68.59	132.15
E3	87.90	76.75	65.63	68.51	130.77
E4	84.79	73.16	61.42	67.38	135.38
E5	86.33	74.53	63.43	69.57	131.31
13. Tiempo acumulado fuera de banda

El tiempo acumulado fuera de una banda de tolerancia de ±0.10 °C fue:

Escenario	PID [h]	MPC [h]	Reducción [h]
E1	41.25	22.00	19.25
E2	57.75	22.00	35.75
E3	66.50	22.00	44.50
E4	57.25	22.00	35.25
E5	58.00	22.00	36.00
14. Interpretación general

Los escenarios muestran que el controlador MPC mejora el seguimiento de la trayectoria térmica en comparación con el controlador PID.

La mejora se observa en:

reducción del error cuadrático medio;
reducción del error absoluto integral;
reducción de la desviación estándar del error;
reducción del error máximo absoluto;
reducción del tiempo acumulado fuera de banda.

Sin embargo, el MPC requiere una acción de control más activa, lo cual se refleja en el incremento del esfuerzo de control.

15. Alcance de los escenarios

Los escenarios fueron diseñados para simulación académica y análisis metodológico.

No representan lotes reales de producción ni condiciones oficiales de una planta cervecera específica.

Para una futura validación industrial, los escenarios deberán ajustarse con datos reales, tales como:

temperatura histórica del TCC;
setpoint térmico por lote;
grados Plato iniciales y finales;
pH;
presión de CO₂;
señal real de enfriamiento;
volumen del tanque;
condiciones reales del sistema de refrigeración;
perturbaciones reales del proceso.
16. Nota sobre reproducibilidad

Para reproducir los escenarios se debe ejecutar el script principal:

matlab/sim_fermentacion_maduracion_pilsen_PID_MPC_v3.m

El script genera automáticamente:

simulaciones PID;
simulaciones MPC;
cálculo de indicadores;
tabla comparativa final;
figuras de temperatura, error, acción de control y variables de proceso.

La simulación complementaria en Simulink corresponde principalmente al escenario base E1 con controlador PID/PI.