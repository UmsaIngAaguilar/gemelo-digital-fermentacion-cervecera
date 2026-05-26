# Condiciones iniciales de simulación

Este archivo documenta las condiciones iniciales utilizadas en la simulación del proceso de fermentación y maduración cervecera tipo pilsener/lager en tanque cilindrocónico.

Las condiciones iniciales corresponden a valores referenciales utilizados para simulación académica. No representan datos oficiales de planta ni información confidencial de una empresa específica.

---

1. Propósito

Las condiciones iniciales definen el estado del sistema al inicio de la simulación. En este modelo, el proceso inicia en el tiempo:

t = 0 h
correspondiente al inicio del proceso de fermentación y maduración simulado.

El horizonte total de simulación es:

tf = 360 h

equivalente a:

15 días = 5 días de fermentación + 10 días de maduración
2. Variables de estado

El modelo considera cuatro variables de estado:

Variable	Descripción	Unidad
X	Biomasa o concentración de levadura	g/L
S	Sustrato o extracto fermentable	g/L
P	Producto asociado al etanol	g/L
T	Temperatura del fermentador	°C
3. Condiciones iniciales base

Las condiciones iniciales base utilizadas en la simulación son:

Variable	Símbolo	Valor inicial	Unidad	Descripción
Biomasa inicial	X0	1.0	g/L	Concentración inicial referencial de levadura
Sustrato inicial	S0	140.0	g/L	Extracto fermentable inicial aproximado
Producto inicial	P0	0.0	g/L	Producto asociado al etanol al inicio
Temperatura inicial	T0	10.0	°C	Temperatura inicial de inoculación
4. Vector de condiciones iniciales

El vector de condiciones iniciales se define como:

x0 = [X0; S0; P0; T0]

Para el escenario base:

x0 = [1.0; 140.0; 0.0; 10.0]
5. Implementación en MATLAB

En el script principal de MATLAB, las condiciones iniciales base se definieron de la siguiente manera:

base.X0 = 1.0;          % g/L, biomasa inicial
base.S0 = 140.0;        % g/L, sustrato inicial aprox. 14 °P
base.P0 = 0.0;          % g/L, etanol inicial
base.T0 = 10.0;         % °C, temperatura inicial de inoculación

Para cada escenario, el vector de estado inicial se construyó mediante:

x0 = [base.X0; S0_esc; base.P0; T0_esc];

Donde:

base.X0 corresponde a la biomasa inicial.
S0_esc corresponde al sustrato inicial definido para cada escenario.
base.P0 corresponde al producto inicial.
T0_esc corresponde a la temperatura inicial definida para cada escenario.
6. Implementación en Simulink

En Simulink, las condiciones iniciales se definieron directamente en los bloques Integrator.

Integrador	Variable	Condición inicial
Biomasa Int_X	X0	1
Sustrato Int_S	S0	140
Etanol Int_P	P0	0
Temperatura Int_T	T0	10

Configuración utilizada:

Biomasa Int_X       Initial condition = 1
Sustrato Int_S      Initial condition = 140
Etanol Int_P        Initial condition = 0
Temperatura Int_T   Initial condition = 10
7. Condiciones iniciales por escenario

La simulación multiescenario modificó principalmente el valor del sustrato inicial S0, manteniendo constantes las demás condiciones iniciales.

Escenario	Descripción	X0 [g/L]	S0 [g/L]	P0 [g/L]	T0 [°C]
E1	Base sin perturbación	1.0	140	0.0	10
E2	Perturbación térmica moderada	1.0	140	0.0	10
E3	Perturbación térmica fuerte	1.0	140	0.0	10
E4	Sustrato inicial bajo	1.0	120	0.0	10
E5	Sustrato inicial alto	1.0	160	0.0	10
8. Justificación de las condiciones iniciales
8.1 Biomasa inicial X0

Se utilizó:

X0 = 1.0 g/L

Este valor representa una concentración inicial referencial de levadura para iniciar la dinámica fermentativa en el modelo.

8.2 Sustrato inicial S0

El escenario base utilizó:

S0 = 140.0 g/L

Este valor se adoptó como una aproximación equivalente a un mosto inicial de aproximadamente 14 °P, considerando una conversión simplificada para fines de simulación.

Para evaluar sensibilidad ante variaciones de extracto inicial, se definieron dos escenarios adicionales:

S0 = 120 g/L   → sustrato inicial bajo
S0 = 160 g/L   → sustrato inicial alto
8.3 Producto inicial P0

Se utilizó:

P0 = 0.0 g/L

Este valor representa la condición inicial del producto asociado al etanol antes del desarrollo de la fermentación.

8.4 Temperatura inicial T0

Se utilizó:

T0 = 10.0 °C

Este valor representa la temperatura inicial referencial de inoculación para el perfil térmico tipo pilsener/lager utilizado en la simulación.

9. Relación con el perfil térmico de referencia

La temperatura inicial T0 = 10 °C coincide con el primer valor de la referencia térmica:

Tref(0) = 10 °C

El perfil térmico de referencia inicia en 10 °C y evoluciona de acuerdo con las siguientes etapas:

Etapa	Tiempo	Temperatura de referencia
Inicio / inoculación	0 h	10 °C
Fermentación inicial	0–24 h	10 °C a 12 °C
Fermentación principal	24–72 h	12 °C
Descanso / final de fermentación	72–96 h	12 °C a 14 °C
Fin de fermentación	96–120 h	14 °C
Enfriamiento a maduración	120–144 h	14 °C a -1.5 °C
Maduración fría	144–360 h	-1.5 °C
10. Correspondencia entre MATLAB y Simulink

Para que los resultados de MATLAB y Simulink sean comparables, las condiciones iniciales deben coincidir en ambos entornos.

Variable	MATLAB	Simulink
X0	base.X0 = 1.0	Biomasa Int_X = 1
S0	base.S0 = 140.0	Sustrato Int_S = 140
P0	base.P0 = 0.0	Etanol Int_P = 0
T0	base.T0 = 10.0	Temperatura Int_T = 10

La verificación complementaria en Simulink corresponde al escenario base:

E1: Base sin perturbación
11. Alcance de las condiciones iniciales

Las condiciones iniciales utilizadas son referenciales y fueron definidas para permitir la simulación académica del proceso. No corresponden necesariamente a mediciones reales de planta.

Para una futura validación industrial se deberán obtener condiciones iniciales reales de cada lote, tales como:

temperatura real de inoculación;
grados Plato iniciales;
volumen del TCC;
cantidad o concentración real de levadura inoculada;
pH inicial;
presión inicial del tanque;
temperatura del glicol;
estado inicial de válvulas de enfriamiento;
condiciones ambientales o de sala.
12. Nota de reproducibilidad

Para reproducir los resultados del escenario base, se deben utilizar las siguientes condiciones:

X0 = 1.0 g/L
S0 = 140.0 g/L
P0 = 0.0 g/L
T0 = 10.0 °C
tf = 360 h
dt = 0.25 h

Estas condiciones corresponden al escenario base utilizado para comparar MATLAB y Simulink.