# Gemelo digital y control predictivo para la optimización térmica del proceso de fermentación y maduración cervecera

Este repositorio contiene el material complementario asociado al manuscrito “Gemelo digital y control predictivo para la optimización térmica del proceso de fermentación y maduración cervecera como aproximación hacia la Industria 4.0”.

**Gemelo digital y control predictivo para la optimización térmica del proceso de fermentación y maduración cervecera como aproximación hacia la Industria 4.0**

## Contenido

- Código MATLAB para simulación multiescenario PID/MPC.
- Código MATLAB para cálculo de indicadores exportados desde Simulink.
- Modelo Simulink del controlador PID/PI.
- Parámetros cinéticos, térmicos y condiciones iniciales.
- Escenarios de simulación.
- Resultados, tablas y figuras generadas.

## Software utilizado

- MATLAB R2022b.
- Simulink R2022b.

## Alcance

Los parámetros utilizados son referenciales para simulación académica. No corresponden a datos oficiales de planta ni a información confidencial de una empresa específica.

El desarrollo corresponde a una etapa inicial de gemelo digital basada en modelado dinámico y simulación computacional, sin conexión en tiempo real con planta, orientada a futura integración industrial.

## Cómo reproducir los resultados

1. Abrir MATLAB R2022b o versión compatible.
2. Ejecutar el archivo `matlab/sim_fermentacion_maduracion_pilsen_PID_MPC_v3.m`.
3. Revisar las tablas generadas en la consola y los archivos de resultados.
4. Abrir el modelo `simulink/modeloferpid.slx` para verificar la simulación complementaria PID/PI.
5. Ejecutar `matlab/calculoindicadoresfermad.m` después de correr el modelo Simulink.

## Cita

Si utiliza este material, cite el DOI generado por Zenodo. La referencia al artículo será actualizada una vez publicada la versión final en revista.
