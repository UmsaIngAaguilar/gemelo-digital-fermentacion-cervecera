%% CALCULO DE INDICADORES DESDE SIMULINK
% Fermentación + maduración tipo pilsen/lager
% Proceso total: 15 días = 360 h
%
% Señales requeridas desde Simulink:
% out.T_sim
% out.u_sim
% out.Tref_sim
% DESARROLADO POR
% Ing. MSc. Abad L. Aguilar M.

clc;

%% Extraer señales desde Simulink

T_export    = out.T_sim;
u_export    = out.u_sim;
Tref_export = out.Tref_sim;

%% Extraer temperatura

if isa(T_export, 'timeseries')
    t = T_export.Time;
    T = T_export.Data;
elseif isstruct(T_export)
    t = T_export.time;
    T = T_export.signals.values;
else
    T = T_export;
    t = linspace(0,360,length(T))';
end

%% Extraer acción de control

if isa(u_export, 'timeseries')
    u = u_export.Data;
elseif isstruct(u_export)
    u = u_export.signals.values;
else
    u = u_export;
end

%% Extraer referencia térmica variable

if isa(Tref_export, 'timeseries')
    Tref = Tref_export.Data;
elseif isstruct(Tref_export)
    Tref = Tref_export.signals.values;
else
    Tref = Tref_export;
end

%% Asegurar formato columna

t    = t(:);
T    = T(:);
u    = u(:);
Tref = Tref(:);

%% Igualar tamaños por seguridad

N = min([length(t), length(T), length(u), length(Tref)]);

t    = t(1:N);
T    = T(1:N);
u    = u(1:N);
Tref = Tref(1:N);

%% Calcular error respecto a referencia variable

e = T - Tref;

%% Indicadores principales

MSE = mean(e.^2);

IAE = trapz(t, abs(e));

StdError = std(e);

StdT = std(T);

EsfuerzoControl = sum(diff(u).^2);

ErrorMax = max(abs(e));

%% Banda de tolerancia

banda = 0.10;   % ±0.10 °C alrededor de la referencia

idx_fuera = find(abs(e) > banda);

% Último instante fuera de banda
if isempty(idx_fuera)
    UltimoInstanteFueraBanda = 0;
else
    UltimoInstanteFueraBanda = t(idx_fuera(end));
end

% Tiempo acumulado fuera de banda
dt_local = mean(diff(t));
TiempoAcumuladoFueraBanda = sum(abs(e) > banda)*dt_local;

%% Mostrar resultados

fprintf('\n=====================================================\n');
fprintf('INDICADORES PID DESDE SIMULINK - PERFIL 15 DIAS\n');
fprintf('=====================================================\n');
fprintf('MSE: %.6f\n', MSE);
fprintf('IAE: %.6f\n', IAE);
fprintf('StdError: %.6f\n', StdError);
fprintf('StdT: %.6f\n', StdT);
fprintf('Esfuerzo de control: %.6f\n', EsfuerzoControl);
fprintf('Error máximo absoluto: %.6f °C\n', ErrorMax);
fprintf('Último instante fuera de banda: %.2f h\n', UltimoInstanteFueraBanda);
fprintf('Tiempo acumulado fuera de banda: %.2f h\n', TiempoAcumuladoFueraBanda);

%% Tabla resumen

Tabla_PID_Simulink = table( ...
    MSE, IAE, StdError, StdT, EsfuerzoControl, ErrorMax, ...
    UltimoInstanteFueraBanda, TiempoAcumuladoFueraBanda);

disp(Tabla_PID_Simulink);

%% Gráfica temperatura vs referencia

figure;
plot(t,Tref,'k--','LineWidth',1.5); hold on;
plot(t,T,'LineWidth',1.5);
xlabel('Tiempo [h]');
ylabel('Temperatura [°C]');
title('Seguimiento térmico PID en Simulink - Fermentación y maduración 15 días');
legend('Referencia térmica','Temperatura simulada','Location','best');
grid on;

%% Gráfica error térmico

figure;
plot(t,e,'LineWidth',1.5); hold on;
yline(0,'--','LineWidth',1.0);
xlabel('Tiempo [h]');
ylabel('Error térmico [°C]');
title('Error térmico PID respecto a referencia variable');
legend('Error térmico','Referencia error 0','Location','best');
grid on;

%% Gráfica acción de control

figure;
plot(t,u,'LineWidth',1.5);
xlabel('Tiempo [h]');
ylabel('Acción de enfriamiento normalizada');
title('Acción de control PID exportada desde Simulink');
grid on;