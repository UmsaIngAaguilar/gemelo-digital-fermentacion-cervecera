# Parámetros del modelo de fermentación y maduración cervecera

Este archivo documenta los parámetros utilizados en el modelo dinámico simplificado de fermentación y maduración cervecera tipo pilsener/lager en tanque cilindrocónico.

Los parámetros aquí descritos corresponden a valores referenciales utilizados para simulación académica. No representan datos oficiales de planta ni información confidencial de una empresa específica.

---

1. Propósito del modelo

El modelo tiene como propósito representar, de manera simplificada, la dinámica del proceso de fermentación y maduración cervecera para evaluar estrategias de control térmico.

El modelo considera cuatro variables de estado:

| Variable | Descripción | Unidad |
|---|---|---|
| `X` | Biomasa o concentración de levadura | g/L |
| `S` | Sustrato o extracto fermentable | g/L |
| `P` | Producto asociado al etanol | g/L |
| `T` | Temperatura del fermentador | °C |

La variable manipulada es:

| Variable | Descripción | Unidad |
|---|---|---|
| `u` | Acción de enfriamiento normalizada | adimensional |

Donde:

```text
u = 0  → sin enfriamiento
u = 1  → máxima acción de enfriamiento simulada

2. Estructura general del modelo

El modelo se basa en balances simplificados de masa y energía.

La cinética de crecimiento se representa mediante una expresión tipo Monod modificada:

mu = fT * mu_max * Sf / (Ks + Sf)

donde:

Sf = max(S - Sres, 0)

El término Sf representa el sustrato fermentable disponible, descontando un extracto residual Sres.

3. Parámetros cinéticos
Parámetro	Valor	Unidad	Descripción
mu_max	0.030	1/h	Tasa máxima de crecimiento ajustada
Ks	10	g/L	Constante de saturación tipo Monod
Yxs	0.25	gX/gS	Rendimiento biomasa/sustrato
Yps	0.45	gP/gS	Rendimiento producto/sustrato
Sres	28	g/L	Extracto residual aproximado
4. Justificación de los parámetros cinéticos
4.1 Tasa máxima de crecimiento mu_max

El valor utilizado fue:

mu_max = 0.030 1/h

Este valor fue ajustado para que la dinámica de consumo de sustrato ocurra dentro del horizonte de fermentación considerado, es decir, aproximadamente durante los primeros 5 días del proceso.

Inicialmente se evaluó un valor mayor:

mu_max = 0.120 1/h

Sin embargo, ese valor provocaba un consumo de sustrato demasiado rápido respecto al perfil tecnológico de fermentación de 120 h. Por ello, se redujo a 0.030 1/h.

4.2 Constante de saturación Ks

El valor utilizado fue:

Ks = 10 g/L

Este parámetro representa la concentración de sustrato a la cual la tasa específica de crecimiento alcanza aproximadamente la mitad de su valor máximo, dentro de la formulación tipo Monod.

4.3 Rendimiento biomasa/sustrato Yxs

El valor utilizado fue:

Yxs = 0.25 gX/gS

Este valor fue ajustado para moderar la velocidad de consumo del sustrato y obtener una dinámica más coherente con el horizonte de fermentación de 5 días.

Inicialmente se evaluó:

Yxs = 0.10 gX/gS

pero dicho valor generaba un consumo de sustrato demasiado acelerado.

4.4 Rendimiento producto/sustrato Yps

El valor utilizado fue:

Yps = 0.45 gP/gS

Este parámetro relaciona la formación del producto asociado al etanol con el consumo de sustrato.

4.5 Extracto residual Sres

El valor utilizado fue:

Sres = 28 g/L

Este valor representa un extracto residual aproximado, equivalente a una fracción de sustrato que no es consumida completamente durante la fermentación. Se incorporó para evitar que el modelo lleve el sustrato a cero, lo cual sería poco representativo de un proceso cervecero real.

5. Factor térmico de actividad fermentativa

El modelo incorpora un factor térmico simplificado fT para reducir la actividad fermentativa durante la maduración fría.

La lógica utilizada fue:

Rango de temperatura	Valor de fT	Interpretación
T < 2 °C	0.05	Actividad fermentativa muy reducida
2 °C ≤ T < 6 °C	0.30	Actividad fermentativa reducida
T ≥ 6 °C	1.00	Actividad fermentativa plena

En forma de código MATLAB:

if T < 2
    fT = 0.05;
elseif T < 6
    fT = 0.30;
else
    fT = 1.00;
end

Este factor es una simplificación académica y debe calibrarse con datos reales si se busca una implementación industrial.

6. Parámetros térmicos
Parámetro	Valor	Unidad	Descripción
alpha	0.08	°C/(g/L)	Generación térmica asociada al consumo de sustrato
beta	1.20	°C/h	Capacidad máxima de enfriamiento simulada
Tamb	20	°C	Temperatura ambiente simulada
k_env	0.02	1/h	Coeficiente simplificado de intercambio térmico con el ambiente
7. Justificación de los parámetros térmicos
7.1 Generación térmica alpha

El valor utilizado fue:

alpha = 0.08

Este parámetro representa de forma simplificada el efecto térmico asociado al consumo de sustrato durante la fermentación. En el modelo, la generación de calor se calcula como:

Qgen = alpha * (-dS)

donde -dS representa la tasa de consumo de sustrato.

7.2 Capacidad de enfriamiento beta

El valor utilizado fue:

beta = 1.20 °C/h

Este parámetro representa la capacidad máxima de enfriamiento dentro del modelo. La remoción de calor se calcula como:

Qcool = beta * u

donde u es la acción de enfriamiento normalizada entre 0 y 1.

7.3 Temperatura ambiente Tamb

El valor utilizado fue:

Tamb = 20 °C

Este valor representa una temperatura ambiente referencial de simulación.

7.4 Coeficiente de intercambio térmico k_env

El valor utilizado fue:

k_env = 0.02 1/h

Este parámetro representa de forma simplificada el intercambio térmico entre el tanque y el ambiente. En el modelo se calcula como:

Qenv = k_env * (Tamb - T)
8. Ecuaciones del modelo
8.1 Sustrato fermentable disponible
Sf = max(S - Sres, 0)
8.2 Cinética de crecimiento
mu = fT * mu_max * Sf / (Ks + Sf)
8.3 Balance de biomasa
dX = mu * X
8.4 Balance de sustrato
dS = -(1 / Yxs) * mu * X

Si el sustrato llega al valor residual, se impide que siga disminuyendo:

if S <= Sres && dS < 0
    dS = 0;
end
8.5 Balance de producto
dP = Yps * (-dS)
8.6 Balance térmico
dT = Qgen - Qcool + Qenv + d

donde:

Qgen  = alpha * (-dS)
Qcool = beta * u
Qenv  = k_env * (Tamb - T)
d     = perturbación térmica simulada
9. Perturbaciones térmicas

En la simulación multiescenario de MATLAB se incorporaron perturbaciones térmicas entre 60 h y 72 h del proceso.

Tipo de perturbación	Valor	Unidad	Descripción
0	0.00	°C/h	Sin perturbación
1	0.20	°C/h	Perturbación térmica moderada
2	0.40	°C/h	Perturbación térmica fuerte

Lógica utilizada:

if t >= 60 && t <= 72
    switch tipoPert
        case 0
            d = 0.0;
        case 1
            d = 0.20;
        case 2
            d = 0.40;
        otherwise
            d = 0.0;
    end
else
    d = 0.0;
end

En la verificación complementaria de Simulink para el escenario base no se incorporó perturbación adicional:

d = 0
10. Condiciones iniciales base
Variable	Valor inicial	Unidad	Descripción
X0	1.0	g/L	Biomasa inicial
S0	140.0	g/L	Sustrato inicial aproximado
P0	0.0	g/L	Producto inicial
T0	10.0	°C	Temperatura inicial de inoculación

Vector de condiciones iniciales:

x0 = [X0; S0; P0; T0]

En MATLAB:

base.X0 = 1.0;
base.S0 = 140.0;
base.P0 = 0.0;
base.T0 = 10.0;
11. Parámetros del controlador PID
Parámetro	Valor	Unidad	Descripción
Kp	0.90	adimensional	Ganancia proporcional
Ki	0.08	1/h	Ganancia integral
Kd	0.02	h	Ganancia derivativa

En MATLAB, para la comparación PID/MPC, se utilizó:

pid.Kp = 0.90;
pid.Ki = 0.08;
pid.Kd = 0.02;

En Simulink, para la verificación complementaria, se utilizó una configuración PI como caso particular del PID:

Kp = 0.90
Ki = 0.08
Kd = 0

Esta decisión se adoptó para evitar inestabilidades numéricas asociadas al filtro derivativo del bloque PID en un proceso térmico lento.

12. Parámetros del controlador MPC
Parámetro	Valor	Unidad	Descripción
Np	24	pasos	Horizonte de predicción
Nc	6	pasos	Horizonte de control
qT	30	adimensional	Peso del error térmico
ru	1.0	adimensional	Peso del cambio de control
u_min	0.0	adimensional	Límite inferior de acción de enfriamiento
u_max	1.0	adimensional	Límite superior de acción de enfriamiento

En MATLAB:

mpc.Np = 24;
mpc.Nc = 6;
mpc.qT = 30;
mpc.ru = 1.0;

u_min = 0.0;
u_max = 1.0;
13. Configuración temporal de la simulación
Parámetro	Valor	Unidad	Descripción
dt	0.25	h	Paso de simulación
tf	360	h	Tiempo final de simulación
N	1441	puntos	Número aproximado de muestras

En MATLAB:

dt = 0.25;
tf = 360;
t = 0:dt:tf;
N = length(t);

En Simulink:

Stop time = 360
Fixed-step size = 0.25
14. Perfil térmico referencial

El perfil térmico utilizado para la simulación corresponde a un proceso total de 15 días:

Etapa	Tiempo	Temperatura de referencia
Inicio / inoculación	0 h	10 °C
Fermentación inicial	0–24 h	10 °C a 12 °C
Fermentación principal	24–72 h	12 °C
Descanso / final de fermentación	72–96 h	12 °C a 14 °C
Fin de fermentación	96–120 h	14 °C
Enfriamiento a maduración	120–144 h	14 °C a -1.5 °C
Maduración fría	144–360 h	-1.5 °C
15. Alcance de los parámetros

Los parámetros utilizados en este modelo cumplen una finalidad de simulación académica. No deben interpretarse como valores calibrados de una planta cervecera real.

Para una futura validación industrial será necesario recopilar datos reales de:

temperatura histórica del TCC;
setpoint térmico por lote;
grados Plato iniciales y finales;
pH;
presión de CO₂;
acción real de enfriamiento;
señal de válvulas;
temperatura de glicol;
volumen del TCC;
frecuencia de muestreo;
características reales del sistema de refrigeración.
16. Nota sobre reproducibilidad

Los parámetros de este archivo fueron utilizados en:

el script MATLAB de simulación multiescenario PID/MPC;
el modelo Simulink de verificación PID/PI;
el cálculo de indicadores de desempeño;
la generación de tablas y figuras del artículo.

La simulación puede reproducirse ejecutando el script principal de MATLAB y verificando posteriormente el modelo Simulink complementario.

