%% SIMULACION MULTIESCENARIO DE FERMENTACION Y MADURACION CERVECERA
% Comparacion PID vs MPC
% Perfil tipo pilsen/lager en TCC
%
% Proceso total: 15 dias = 360 h
% Fermentacion: 5 dias = 120 h
% Maduracion: 10 dias = 240 h
%
% NOTA:
% Los parametros usados son referenciales para simulacion academica.
% No representan datos oficiales de planta.
% La validacion corresponde al entorno computacional.
%
% DESARROLADO POR
% Ing. MSc. Abad L. Aguilar M.
clear; clc; close all;

%% 1. PARAMETROS DEL MODELO

par.mu_max = 0.030;      % 1/h, tasa maxima de crecimiento, antes 0.12
par.Ks     = 10;        % g/L, constante de saturacion
par.Yxs    = 0.25;      % gX/gS, rendimiento biomasa/sustrato, antes 0.10
par.Yps    = 0.45;      % gP/gS, rendimiento producto/sustrato

% Parametros termicos simplificados
par.alpha  = 0.08;      % efecto termico por consumo de sustrato [°C/(g/L)]
par.beta   = 1.20;      % capacidad maxima de enfriamiento [°C/h]
par.Tamb   = 20;        % °C, temperatura ambiente simulada
par.k_env  = 0.02;      % 1/h, intercambio con ambiente

% Extracto residual aproximado
par.Sres   = 28;        % g/L, equivalente aproximado a 2.8 °P residual

%% 2. CONDICIONES BASE DE SIMULACION

base.X0 = 1.0;          % g/L, biomasa inicial
base.S0 = 140.0;        % g/L, sustrato inicial aprox. 14 °P
base.P0 = 0.0;          % g/L, etanol inicial
base.T0 = 10.0;         % °C, temperatura inicial de inoculacion

dt = 0.25;              % h, tiempo de muestreo
tf = 360;               % h, 15 dias de proceso total
t  = 0:dt:tf;
N  = length(t);

%% 3. PARAMETROS DEL CONTROLADOR PID

% Valores iniciales referenciales.
% Luego pueden ser sintonizados para comparacion mas justa.
pid.Kp = 0.90;
pid.Ki = 0.08;
pid.Kd = 0.02;

%% 4. PARAMETROS DEL CONTROLADOR MPC

mpc.Np = 24;            % horizonte de prediccion
mpc.Nc = 6;             % horizonte de control
mpc.qT = 30;            % peso del error de temperatura
mpc.ru = 1.0;           % peso del cambio de control

u_min = 0.0;            % enfriamiento minimo normalizado
u_max = 1.0;            % enfriamiento maximo normalizado

%% 5. DEFINICION DE ESCENARIOS

% tipoPerturbacion:
% 0 = sin perturbacion
% 1 = perturbacion moderada
% 2 = perturbacion fuerte
%
% tipoReferencia:
% 1 = perfil pilsen/lager 15 dias

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

%% 6. CONFIGURACION DE OPTIMIZACION

opciones = optimoptions('fmincon', ...
    'Display','none', ...
    'Algorithm','sqp', ...
    'MaxIterations', 80, ...
    'OptimalityTolerance', 1e-4, ...
    'StepTolerance', 1e-4);

%% 7. REFERENCIA TERMICA VARIABLE

Tref_vec = zeros(size(t));

for k = 1:N
    Tref_vec(k) = referencia_pilsen_15dias(t(k));
end

%% 8. EJECUCION AUTOMATICA DE ESCENARIOS

Resultados = table();

for e = 1:length(escenarios)

    nombreEsc = escenarios(e).nombre;
    S0_esc = escenarios(e).S0;
    T0_esc = escenarios(e).T0;
    tipoPert = escenarios(e).tipoPerturbacion;

    fprintf('\n=============================================\n');
    fprintf('Ejecutando escenario: %s\n', nombreEsc);
    fprintf('=============================================\n');

    x0 = [base.X0; S0_esc; base.P0; T0_esc];

    %% Simular PID
    [x_pid, u_pid] = simular_PID_variable(x0, t, dt, pid, par, u_min, u_max, tipoPert);

    %% Simular MPC
    [x_mpc, u_mpc] = simular_MPC_variable(x0, t, dt, mpc, par, u_min, u_max, tipoPert, opciones);

    %% Calcular indicadores
    ind_pid = calcular_indicadores_variable(t, x_pid(4,:), u_pid, Tref_vec);
    ind_mpc = calcular_indicadores_variable(t, x_mpc(4,:), u_mpc, Tref_vec);

    %% Calcular mejora porcentual del MPC respecto al PID
    mejora_MSE = 100*(ind_pid.MSE - ind_mpc.MSE)/ind_pid.MSE;
    mejora_IAE = 100*(ind_pid.IAE - ind_mpc.IAE)/ind_pid.IAE;
    mejora_StdError = 100*(ind_pid.StdError - ind_mpc.StdError)/ind_pid.StdError;
    mejora_ErrorMax = 100*(ind_pid.ErrorMax - ind_mpc.ErrorMax)/ind_pid.ErrorMax;

    % Para esfuerzo de control, si es positivo significa incremento del MPC
    incremento_Eu = 100*(ind_mpc.EsfuerzoControl - ind_pid.EsfuerzoControl)/ind_pid.EsfuerzoControl;

   %% Agregar resultados a tabla final

nuevaFila = table( ...
    string(nombreEsc), ...
    ind_pid.MSE, ind_mpc.MSE, mejora_MSE, ...
    ind_pid.IAE, ind_mpc.IAE, mejora_IAE, ...
    ind_pid.StdError, ind_mpc.StdError, mejora_StdError, ...
    ind_pid.StdT, ind_mpc.StdT, ...
    ind_pid.ErrorMax, ind_mpc.ErrorMax, mejora_ErrorMax, ...
    ind_pid.EsfuerzoControl, ind_mpc.EsfuerzoControl, incremento_Eu, ...
    ind_pid.UltimoInstanteFueraBanda, ind_mpc.UltimoInstanteFueraBanda, ...
    ind_pid.TiempoAcumuladoFueraBanda, ind_mpc.TiempoAcumuladoFueraBanda, ...
    'VariableNames', { ...
    'Escenario', ...
    'MSE_PID', 'MSE_MPC', 'Mejora_MSE_pct', ...
    'IAE_PID', 'IAE_MPC', 'Mejora_IAE_pct', ...
    'StdError_PID', 'StdError_MPC', 'Mejora_StdError_pct', ...
    'StdT_PID', 'StdT_MPC', ...
    'ErrorMax_PID', 'ErrorMax_MPC', 'Mejora_ErrorMax_pct', ...
    'Eu_PID', 'Eu_MPC', 'Incremento_Eu_pct', ...
    'UltimoInstanteFueraBanda_PID', 'UltimoInstanteFueraBanda_MPC', ...
    'TiempoAcumuladoFueraBanda_PID', 'TiempoAcumuladoFueraBanda_MPC'} );

Resultados = [Resultados; nuevaFila];

    %% Mostrar resultados en consola
    fprintf('\nIndicadores PID:\n');
    disp(ind_pid);

    fprintf('Indicadores MPC:\n');
    disp(ind_mpc);

    fprintf('Mejora MSE MPC respecto a PID: %.2f %%\n', mejora_MSE);
    fprintf('Mejora IAE MPC respecto a PID: %.2f %%\n', mejora_IAE);
    fprintf('Mejora StdError MPC respecto a PID: %.2f %%\n', mejora_StdError);
    fprintf('Mejora ErrorMax MPC respecto a PID: %.2f %%\n', mejora_ErrorMax);
    fprintf('Incremento esfuerzo de control MPC respecto a PID: %.2f %%\n', incremento_Eu);

    %% Graficas del escenario
    graficar_escenario_variable(t, x_pid, u_pid, x_mpc, u_mpc, Tref_vec, nombreEsc);

end

%% 9. TABLA FINAL

disp(' ');
disp('==========================================================================');
disp('TABLA COMPARATIVA FINAL - FERMENTACION Y MADURACION PID vs MPC');
disp('==========================================================================');
disp(Resultados);

%% 10. EXPORTAR TABLA A EXCEL

nombreExcel = 'Resultados_PID_vs_MPC_Fermentacion_Maduracion_15dias.xlsx';
writetable(Resultados, nombreExcel);

fprintf('\nTabla final exportada a: %s\n', nombreExcel);

%% 11. GUARDAR RESULTADOS EN MAT

save('Resultados_PID_vs_MPC_Fermentacion_Maduracion_15dias.mat', 'Resultados');

fprintf('Resultados guardados en archivo MAT.\n');

%% ========================================================================
% FUNCIONES LOCALES
%% ========================================================================

function Tref = referencia_pilsen_15dias(t)
% Perfil termico referencial para fermentacion y maduracion tipo pilsen/lager
% Proceso total: 15 dias = 360 h
% Fermentacion: 5 dias = 120 h
% Maduracion: 10 dias = 240 h
% t en horas
%
% Perfil teorico basado en curva referencial.
% Debe confirmarse posteriormente con datos reales de planta.

    if t <= 24
        % Dia 0 a 1: subida de 10 a 12 °C
        Tref = 10 + (12 - 10)*(t/24);

    elseif t <= 72
        % Dia 1 a 3: mantener 12 °C
        Tref = 12;

    elseif t <= 96
        % Dia 3 a 4: subida de 12 a 14 °C
        Tref = 12 + (14 - 12)*((t - 72)/24);

    elseif t <= 120
        % Dia 4 a 5: mantener 14 °C
        Tref = 14;

    elseif t <= 144
        % Dia 5 a 6: enfriamiento de 14 a -1.5 °C
        Tref = 14 + (-1.5 - 14)*((t - 120)/24);

    else
        % Dia 6 a 15: maduracion fria a -1.5 °C
        Tref = -1.5;
    end
end

function [x_pid, u_pid] = simular_PID_variable(x0, t, dt, pid, par, u_min, u_max, tipoPert)

    N = length(t);

    x_pid = zeros(4, N);
    u_pid = zeros(1, N);

    x_pid(:,1) = x0;

    int_e = 0;
    e_old = 0;

    for k = 1:N-1

        T_actual = x_pid(4,k);
        Tref_k = referencia_pilsen_15dias(t(k));

        % Error positivo si T esta por encima de referencia
        e = T_actual - Tref_k;

        int_e = int_e + e*dt;
        der_e = (e - e_old)/dt;

        u = pid.Kp*e + pid.Ki*int_e + pid.Kd*der_e;

        % Saturacion
        u = max(u_min, min(u_max, u));

        u_pid(k) = u;

        d = perturbacion_termica_15dias(t(k), tipoPert);

        dx = modelo_fermentacion_maduracion(x_pid(:,k), u, d, par);

        x_pid(:,k+1) = x_pid(:,k) + dt*dx;

        % Evitar valores negativos no fisicos
        x_pid(1,k+1) = max(x_pid(1,k+1), 0);             % X
        x_pid(2,k+1) = max(x_pid(2,k+1), par.Sres);      % S no baja del residual
        x_pid(3,k+1) = max(x_pid(3,k+1), 0);             % P

        e_old = e;
    end

    u_pid(N) = u_pid(N-1);
end

function [x_mpc, u_mpc] = simular_MPC_variable(x0, t, dt, mpc, par, u_min, u_max, tipoPert, opciones)

    N = length(t);

    x_mpc = zeros(4, N);
    u_mpc = zeros(1, N);

    x_mpc(:,1) = x0;

    u_anterior = 0;

    for k = 1:N-1

        xk = x_mpc(:,k);

        % Vector inicial de optimizacion
        u0 = u_anterior*ones(mpc.Nc,1);

        % Limites de la accion de control
        lb = u_min*ones(mpc.Nc,1);
        ub = u_max*ones(mpc.Nc,1);

        % Funcion objetivo
        Jfun = @(Useq) costo_mpc_variable(Useq, xk, u_anterior, dt, par, mpc, t(k), tipoPert);

        % Optimizacion
        Useq_opt = fmincon(Jfun, u0, [], [], [], [], lb, ub, [], opciones);

        % Aplicar solo la primera accion de control
        u = Useq_opt(1);
        u_mpc(k) = u;

        d = perturbacion_termica_15dias(t(k), tipoPert);

        dx = modelo_fermentacion_maduracion(x_mpc(:,k), u, d, par);

        x_mpc(:,k+1) = x_mpc(:,k) + dt*dx;

        % Evitar valores negativos no fisicos
        x_mpc(1,k+1) = max(x_mpc(1,k+1), 0);             % X
        x_mpc(2,k+1) = max(x_mpc(2,k+1), par.Sres);      % S
        x_mpc(3,k+1) = max(x_mpc(3,k+1), 0);             % P

        u_anterior = u;
    end

    u_mpc(N) = u_mpc(N-1);
end

function dx = modelo_fermentacion_maduracion(x, u, d, par)

    X = x(1);
    S = x(2);
    P = x(3);
    T = x(4);

    % Proteccion numerica
    X = max(X, 0);
    S = max(S, par.Sres);

    % Sustrato fermentable disponible
    Sf = max(S - par.Sres, 0);

    % Factor termico de actividad fermentativa
    % Durante maduracion fria la actividad se reduce fuertemente.
    if T < 2
        fT = 0.05;
    elseif T < 6
        fT = 0.30;
    else
        fT = 1.00;
    end

    % Cinetica tipo Monod modificada
    mu = fT * par.mu_max * Sf/(par.Ks + Sf + eps);

    % Balance de biomasa
    dX = mu*X;

    % Balance de sustrato
    dS = -(1/par.Yxs)*mu*X;

    % Evitar consumo bajo residual
    if S <= par.Sres && dS < 0
        dS = 0;
    end

    % Balance de producto
    dP = par.Yps*(-dS);

    % Generacion termica asociada al consumo de sustrato
    Qgen = par.alpha*(-dS);

    % Enfriamiento normalizado
    Qcool = par.beta*u;

    % Intercambio termico con ambiente
    Qenv = par.k_env*(par.Tamb - T);

    % Balance energetico simplificado
    dT = Qgen - Qcool + Qenv + d;

    dx = [dX; dS; dP; dT];
end

function d = perturbacion_termica_15dias(t, tipoPert)
% Perturbacion termica aplicada durante una ventana critica del proceso.
% Se ubica durante la fase de fermentacion activa, alrededor de 60 a 72 h.

    if t >= 60 && t <= 72

        switch tipoPert
            case 0
                d = 0.0;     % sin perturbacion
            case 1
                d = 0.20;    % perturbacion moderada [°C/h]
            case 2
                d = 0.40;    % perturbacion fuerte [°C/h]
            otherwise
                d = 0.0;
        end

    else
        d = 0.0;
    end
end

function J = costo_mpc_variable(Useq, x0, u_ant, dt, par, mpc, t_actual, tipoPert)

    x = x0;
    J = 0;

    for i = 1:mpc.Np

        % Move blocking:
        % se optimizan Nc acciones; despues se mantiene la ultima
        if i <= mpc.Nc
            u = Useq(i);
        else
            u = Useq(end);
        end

        tiempo_pred = t_actual + (i-1)*dt;
        Tref_pred = referencia_pilsen_15dias(tiempo_pred);

        d = perturbacion_termica_15dias(tiempo_pred, tipoPert);

        dx = modelo_fermentacion_maduracion(x, u, d, par);

        x = x + dt*dx;

        % Proteccion numerica
        x(1) = max(x(1), 0);
        x(2) = max(x(2), par.Sres);
        x(3) = max(x(3), 0);

        Tpred = x(4);

        if i == 1
            du = u - u_ant;
        else
            if i <= mpc.Nc
                du = Useq(i) - Useq(i-1);
            else
                du = 0;
            end
        end

        J = J + mpc.qT*(Tpred - Tref_pred)^2 + mpc.ru*(du)^2;
    end
end

function ind = calcular_indicadores_variable(t, T, u, Tref_vec)

    T = T(:);
    u = u(:);
    Tref_vec = Tref_vec(:);
    t = t(:);

    N = min([length(t), length(T), length(u), length(Tref_vec)]);

    t = t(1:N);
    T = T(1:N);
    u = u(1:N);
    Tref_vec = Tref_vec(1:N);

    e = T - Tref_vec;

    ind.MSE = mean(e.^2);
    ind.IAE = trapz(t, abs(e));
    ind.StdError = std(e);
    ind.StdT = std(T);
    ind.EsfuerzoControl = sum(diff(u).^2);
    ind.ErrorMax = max(abs(e));

   % Banda de tolerancia alrededor de la referencia variable
banda = 0.10; % ±0.10 °C

idx_fuera = find(abs(e) > banda);

% Último instante fuera de banda
if isempty(idx_fuera)
    ind.UltimoInstanteFueraBanda = 0;
else
    ind.UltimoInstanteFueraBanda = t(idx_fuera(end));
end

% Tiempo acumulado fuera de banda
dt_local = mean(diff(t));
ind.TiempoAcumuladoFueraBanda = sum(abs(e) > banda)*dt_local;

end

function graficar_escenario_variable(t, x_pid, u_pid, x_mpc, u_mpc, Tref_vec, nombreEsc)

    nombreLimpio = strrep(nombreEsc, '_', ' ');

    %% Figura 1: Temperatura vs referencia
    figure('Name', ['Temperatura - ' nombreEsc]);
    plot(t, Tref_vec, 'k--', 'LineWidth', 1.5); hold on;
    plot(t, x_pid(4,:), 'LineWidth', 1.3);
    plot(t, x_mpc(4,:), 'LineWidth', 1.3);
    xlabel('Tiempo [h]');
    ylabel('Temperatura [°C]');
    title(['Seguimiento térmico PID vs MPC: ' nombreLimpio]);
    legend('Referencia','PID','MPC', 'Location','best');
    grid on;

    guardar_figura(['Fig_Temperatura_' nombreEsc]);

    %% Figura 2: Error térmico
    figure('Name', ['Error - ' nombreEsc]);
    e_pid = x_pid(4,:) - Tref_vec;
    e_mpc = x_mpc(4,:) - Tref_vec;
    plot(t, e_pid, 'LineWidth', 1.3); hold on;
    plot(t, e_mpc, 'LineWidth', 1.3);
    yline(0, '--', 'LineWidth', 1.0);
    xlabel('Tiempo [h]');
    ylabel('Error térmico [°C]');
    title(['Error térmico PID vs MPC: ' nombreLimpio]);
    legend('PID','MPC','Referencia error 0', 'Location','best');
    grid on;

    guardar_figura(['Fig_Error_' nombreEsc]);

    %% Figura 3: Accion de control
    figure('Name', ['Control - ' nombreEsc]);
    plot(t, u_pid, 'LineWidth', 1.3); hold on;
    plot(t, u_mpc, 'LineWidth', 1.3);
    xlabel('Tiempo [h]');
    ylabel('Acción de enfriamiento normalizada');
    title(['Acción de control PID vs MPC: ' nombreLimpio]);
    legend('PID','MPC', 'Location','best');
    grid on;

    guardar_figura(['Fig_Control_' nombreEsc]);

    %% Figura 4: Variables de fermentacion con MPC
    figure('Name', ['Variables MPC - ' nombreEsc]);
    plot(t, x_mpc(1,:), 'LineWidth', 1.3); hold on;
    plot(t, x_mpc(2,:), 'LineWidth', 1.3);
    plot(t, x_mpc(3,:), 'LineWidth', 1.3);
    xlabel('Tiempo [h]');
    ylabel('Concentración [g/L]');
    title(['Variables simuladas con MPC: ' nombreLimpio]);
    legend('Biomasa X','Sustrato S','Etanol P', 'Location','best');
    grid on;

    guardar_figura(['Fig_Variables_MPC_' nombreEsc]);

    %% Figura 5: Sustrato PID vs MPC
    figure('Name', ['Sustrato - ' nombreEsc]);
    plot(t, x_pid(2,:), 'LineWidth', 1.3); hold on;
    plot(t, x_mpc(2,:), 'LineWidth', 1.3);
    yline(28, '--', 'LineWidth', 1.0);
    xlabel('Tiempo [h]');
    ylabel('Sustrato [g/L]');
    title(['Evolución de sustrato PID vs MPC: ' nombreLimpio]);
    legend('PID','MPC','Sustrato residual', 'Location','best');
    grid on;

    guardar_figura(['Fig_Sustrato_' nombreEsc]);
end

function guardar_figura(nombreArchivo)

    % Guarda en PNG y FIG
    saveas(gcf, [nombreArchivo '.png']);
    saveas(gcf, [nombreArchivo '.fig']);
end