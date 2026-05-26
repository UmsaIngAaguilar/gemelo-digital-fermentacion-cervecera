1. Software utilizado

La implementación computacional complementaria fue desarrollada utilizando MATLAB y Simulink. El modelo fue construido y verificado en el entorno MATLAB/Simulink, empleando unidades de tiempo en horas para mantener coherencia con el horizonte total del proceso de fermentación y maduración.

1.1 Versión del software

- MATLAB R2022b.
- Simulink R2022b.

1.2 Módulos y herramientas utilizadas

Para la simulación se utilizaron herramientas estándar de MATLAB y Simulink:

- Simulink, para la implementación gráfica del modelo dinámico.
- Bloques Integrator, para resolver las ecuaciones diferenciales de biomasa, sustrato, producto y temperatura.
- Bloque MATLAB Function, para implementar el perfil térmico de referencia y el modelo dinámico de fermentación y maduración.
- Bloque PID Controller, configurado como controlador PI para la verificación complementaria.
- Bloque Saturation, para limitar la acción de enfriamiento normalizada entre 0 y 1.
- Bloques To Workspace, para exportar las señales simuladas hacia MATLAB.
- Scripts MATLAB, para el cálculo posterior de indicadores de desempeño.

1.3 Consideraciones de compatibilidad

El modelo fue desarrollado en MATLAB/Simulink R2022b. Puede ser compatible con versiones posteriores de MATLAB y Simulink, aunque se recomienda verificar la configuración del solver, los bloques MATLAB Function y los bloques To Workspace si se utiliza una versión diferente.

1.4 Unidades de simulación

El modelo utiliza las siguientes unidades principales:

| Magnitud | Unidad |
|---|---|
| Tiempo | h |
| Temperatura | °C |
| Biomasa | g/L |
| Sustrato | g/L |
| Producto / etanol equivalente | g/L |
| Acción de enfriamiento | adimensional, entre 0 y 1 |

La unidad de tiempo utilizada en Simulink es la hora. Por tanto, el bloque Clock entrega el tiempo de simulación en horas, desde 0 hasta 360 h.

1.5 Alcance del uso del software

La implementación en Simulink no corresponde a una conexión en tiempo real con planta. Su propósito es verificar la coherencia computacional del modelo PID/PI, visualizar el seguimiento térmico del perfil de referencia y exportar señales para el cálculo de indicadores en MATLAB.

2. Nombre y descripción del modelo Simulink

El modelo Simulink utilizado para la verificación complementaria del controlador PID/PI fue denominado:
modeloferpid.slx

2.1 Propósito del modelo

El modelo modeloferpid.slx tiene como propósito representar de forma gráfica y computacional el comportamiento térmico simplificado del proceso de fermentación y maduración cervecera tipo pilsener/lager en tanque cilindrocónico.

Este modelo se utilizó para:

implementar el perfil térmico de referencia de 15 días;
simular la respuesta de temperatura del TCC;
verificar el comportamiento de un controlador PID/PI convencional;
exportar señales hacia MATLAB;
calcular indicadores de desempeño a partir de las señales simuladas;
contrastar la coherencia del modelo Simulink con la simulación principal desarrollada en MATLAB.

2.2 Alcance del modelo

El modelo Simulink corresponde a una implementación complementaria del escenario base con controlador PID/PI. La comparación principal entre PID y MPC fue desarrollada en MATLAB mediante el script multiescenario.

El modelo no representa una planta industrial real conectada en línea. Tampoco incorpora comunicación con PLC, adquisición real de datos, sensores físicos, válvulas reales ni sistema de refrigeración industrial. Su función es estrictamente computacional y académica.

2.3 Variables principales del modelo

El modelo considera cuatro variables de estado:

Variable	Descripción	Unidad
X	Biomasa o concentración de levadura	g/L
S	Sustrato o extracto fermentable	g/L
P	Producto asociado al etanol	g/L
T	Temperatura del fermentador	°C

La variable manipulada es:

Variable	Descripción	Unidad
u	Acción de enfriamiento normalizada	adimensional

La variable de referencia es:

Variable	Descripción	Unidad
Tref	Temperatura de referencia variable	°C

2.4 Estructura general del modelo

El modelo modeloferpid.slx está compuesto por los siguientes bloques principales:

	1. Clock
	Entrega el tiempo de simulación en horas.
	2. Referencia_Termica
	Bloque MATLAB Function que genera el perfil térmico de referencia Tref(t).
	3. Sum / Error
	Calcula el error térmico entre la temperatura simulada y la referencia:
	e(t) = T(t) - Tref(t)
	4. PID Controller / PI Controller
	Calcula la acción de enfriamiento a partir del error térmico.
	5. Saturation
	Limita la acción de enfriamiento entre 0 y 1.
	6. Modelo_Fermentacion
	Bloque MATLAB Function que calcula las derivadas de biomasa, sustrato, producto y temperatura.
	7. Integradores
	Integran las derivadas para obtener las variables de estado X(t), S(t), P(t) y T(t).
	8. To Workspace
	Exportan las señales principales hacia MATLAB para el cálculo de indicadores.

2.5 Flujo lógico del modelo

El flujo lógico del modelo puede resumirse de la siguiente manera:

Clock → Referencia_Termica → Tref
T y Tref → cálculo del error
Error → controlador PID/PI
PID/PI → Saturation → acción de enfriamiento u
X, S, P, T, u, t → Modelo_Fermentacion
Modelo_Fermentacion → dX, dS, dP, dT
dX, dS, dP, dT → Integradores → X, S, P, T
T, Tref, u, X, S, P → To Workspace → MATLAB

2.6 Señales exportadas

El modelo exporta las siguientes señales hacia MATLAB:

Señal	Nombre exportado
Temperatura simulada	T_sim
Referencia térmica	Tref_sim
Acción de enfriamiento	u_sim
Biomasa	X_sim
Sustrato	S_sim
Producto / etanol equivalente	P_sim

Estas señales permiten calcular indicadores como MSE, IAE, desviación estándar del error, esfuerzo de control, error máximo absoluto y tiempo acumulado fuera de banda.

2.7 Relación con el artículo

El modelo modeloferpid.slx corresponde al soporte computacional complementario del artículo:

“Gemelo digital y control predictivo para la optimización térmica del proceso de fermentación y maduración cervecera como aproximación hacia la Industria 4.0”.

Su inclusión como material complementario permite reproducir la verificación del controlador PID/PI en Simulink y respaldar la consistencia de los resultados presentados en el artículo.

3. Horizonte de simulación

El proceso total simulado corresponde a 15 días:

Fermentación: 5 días = 120 h
Maduración: 10 días = 240 h
Tiempo total: 15 días = 360 h

Configuración en Simulink:

Stop time = 360

4. Configuración del solver

La simulación fue configurada con paso fijo para mantener coherencia con la simulación desarrollada en MATLAB.

Configuración recomendada:

Solver type: Fixed-step
Solver: ode4 (Runge-Kutta)
Fixed-step size: 0.25

También se verificó la simulación con paso fijo equivalente al utilizado en el script MATLAB principal:

dt = 0.25 h

5. Perfil térmico de referencia

La referencia térmica fue implementada mediante un bloque MATLAB Function denominado:

Referencia_Termica

Este bloque recibe como entrada el tiempo de simulación entregado por el bloque Clock y entrega como salida la temperatura de referencia Tref.

El perfil térmico utilizado fue:

Etapa	Tiempo	Temperatura de referencia
Inicio / inoculación	0 h	10 °C
Fermentación inicial	0–24 h	10 °C a 12 °C
Fermentación principal	24–72 h	12 °C
Descanso / final de fermentación	72–96 h	12 °C a 14 °C
Fin de fermentación	96–120 h	14 °C
Enfriamiento a maduración	120–144 h	14 °C a -1.5 °C
Maduración fría	144–360 h	-1.5 °C

Código utilizado en el bloque Referencia_Termica:

function Tref = fcn(t)
% Referencia térmica para fermentación + maduración tipo pilsen/lager
% Proceso total: 15 días = 360 h
% Fermentación: 5 días = 120 h
% Maduración: 10 días = 240 h

if t <= 24
    % Día 0 a 1: subida de 10 a 12 °C
    Tref = 10 + (12 - 10)*(t/24);

elseif t <= 72
    % Día 1 a 3: mantener 12 °C
    Tref = 12;

elseif t <= 96
    % Día 3 a 4: subida de 12 a 14 °C
    Tref = 12 + (14 - 12)*((t - 72)/24);

elseif t <= 120
    % Día 4 a 5: mantener 14 °C
    Tref = 14;

elseif t <= 144
    % Día 5 a 6: enfriamiento de 14 a -1.5 °C
    Tref = 14 + (-1.5 - 14)*((t - 120)/24);

else
    % Día 6 a 15: maduración fría a -1.5 °C
    Tref = -1.5;
end

6. Condiciones iniciales de los integradores

Las condiciones iniciales fueron definidas directamente en los bloques Integrator de Simulink.

Variable	Integrador	Condición inicial
Biomasa	Biomasa Int_X	1
Sustrato	Sustrato Int_S	140
Etanol / producto	Etanol Int_P	0
Temperatura	Temperatura Int_T	10

Configuración:

Biomasa Int_X       Initial condition = 1
Sustrato Int_S      Initial condition = 140
Etanol Int_P        Initial condition = 0
Temperatura Int_T   Initial condition = 10

7. Controlador PID/PI

El modelo Simulink utilizó un controlador PID convencional en configuración PI, es decir, con acción derivativa nula.

Esta decisión se adoptó debido a la naturaleza lenta del proceso térmico de fermentación y maduración, y para evitar inestabilidades numéricas asociadas al filtro derivativo del bloque PID.

Configuración recomendada:

Controller type: PI

o, si se utiliza el bloque PID en modo general:

Kp = 0.90
Ki = 0.08
Kd = 0

La señal de error se calcula como:

e(t) = T(t) - Tref(t)

Donde:

T(t) es la temperatura simulada del TCC.
Tref(t) es la temperatura de referencia variable.

8. Bloque de saturación

La acción de enfriamiento fue limitada mediante un bloque Saturation denominado:

Sat_u

Configuración:

Lower limit = 0
Upper limit = 1

La señal de salida representa la acción de enfriamiento normalizada:

u(t) ∈ [0, 1]

Donde:

u = 0 representa ausencia de enfriamiento.
u = 1 representa máxima acción de enfriamiento simulada.

9. Bloque MATLAB Function del modelo dinámico

El bloque principal del modelo dinámico fue denominado:

Modelo_Fermentacion

Entradas del bloque:

X
S
P
T
u
t

Salidas del bloque:

dX
dS
dP
dT

Código utilizado en el bloque Modelo_Fermentacion:

function [dX,dS,dP,dT] = fcn(X,S,P,T,u,t)

% Modelo dinámico simplificado para fermentación + maduración cervecera
% Perfil tipo pilsen/lager en TCC

%% Parámetros cinéticos ajustados

mu_max = 0.030;     % 1/h, tasa máxima ajustada
Ks     = 10;        % g/L
Yxs    = 0.25;      % gX/gS
Yps    = 0.45;      % gP/gS

%% Parámetros térmicos

alpha  = 0.08;      % generación térmica por consumo de sustrato
beta   = 1.20;      % capacidad máxima de enfriamiento [°C/h]
Tamb   = 20;        % temperatura ambiente [°C]
k_env  = 0.02;      % intercambio térmico con ambiente [1/h]

%% Extracto residual

Sres = 28;          % g/L, extracto residual aproximado

%% Protección numérica

if X < 0
    X = 0;
end

if S < Sres
    S = Sres;
end

%% Sustrato fermentable disponible

Sf = max(S - Sres, 0);

%% Factor térmico de actividad fermentativa

if T < 2
    fT = 0.05;
elseif T < 6
    fT = 0.30;
else
    fT = 1.00;
end

%% Cinética tipo Monod modificada

mu = fT * mu_max * Sf/(Ks + Sf + eps);

%% Balances de masa

dX = mu*X;

dS = -(1/Yxs)*mu*X;

% Evitar que el sustrato baje del residual
if S <= Sres && dS < 0
    dS = 0;
end

dP = Yps*(-dS);

%% Balance térmico

Qgen  = alpha*(-dS);       % calor generado por fermentación
Qcool = beta*u;            % enfriamiento
Qenv  = k_env*(Tamb - T);  % intercambio térmico con ambiente

%% Perturbación térmica

% En la verificación Simulink base no se incorpora perturbación adicional.
d = 0;

dT = Qgen - Qcool + Qenv + d;

10. Bloques To Workspace

Los bloques To Workspace se utilizaron para exportar señales desde Simulink hacia MATLAB.

Configuración común para todos los bloques:

Limit data points to last: inf
Decimation: 1
Save format: Structure With Time
Sample time: -1

Variables exportadas:

Señal	Nombre del bloque / variable
Temperatura simulada	T_sim
Referencia térmica	Tref_sim
Acción de enfriamiento	u_sim
Biomasa	X_sim
Sustrato	S_sim
Etanol / producto	P_sim

Con la opción Single simulation output activada, las señales se leen desde MATLAB como:

out.T_sim
out.Tref_sim
out.u_sim
out.X_sim
out.S_sim
out.P_sim

11. Configuración de Data Import/Export

En Model Settings > Data Import/Export, se utilizó:

Single simulation output: activado

Esto permite que los resultados se almacenen dentro del objeto:

out

12. Señales utilizadas para el cálculo de indicadores

Para el cálculo de indicadores de desempeño desde MATLAB se utilizaron principalmente:

out.T_sim
out.Tref_sim
out.u_sim

Con estas señales se calcularon:

MSE
IAE
desviación estándar del error
desviación estándar de la temperatura
esfuerzo de control
error máximo absoluto
último instante fuera de banda
tiempo acumulado fuera de banda

13. Resultados de verificación Simulink

Para el escenario base de 15 días, la simulación PID/PI en Simulink produjo los siguientes indicadores:

Indicador	Valor
MSE	0.010340
IAE	15.821424
StdError	0.100959
StdT	6.639495
Esfuerzo de control	0.086298
Error máximo absoluto	0.533247 °C
Último instante fuera de banda	161.75 h
Tiempo acumulado fuera de banda	41.50 h

Estos resultados son coherentes con los obtenidos en MATLAB para el escenario base con controlador PID.

14. Observaciones

La implementación en Simulink fue utilizada como verificación complementaria del modelo PID/PI. La comparación principal entre PID y MPC fue desarrollada en MATLAB mediante el script multiescenario.

El modelo Simulink no representa una conexión en tiempo real con planta. Corresponde a una etapa inicial de modelado y simulación computacional dentro de la ruta hacia un gemelo digital conectado.

15. Alcance y limitaciones

Los parámetros utilizados son referenciales para simulación académica y no corresponden a datos oficiales de planta.

La implementación no incluye datos reales de temperatura, grados Plato, pH, presión de CO₂, señal real de válvulas, consumo energético ni capacidad real del sistema de refrigeración.

Para una futura implementación industrial se requerirá calibrar el modelo con datos reales del proceso.