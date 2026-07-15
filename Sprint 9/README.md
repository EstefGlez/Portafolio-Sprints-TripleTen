# Prueba A/B: ¿la nueva landing realmente convierte más?

## Desafío

El equipo de producto había lanzado una segunda versión (B) de la landing page principal y quería saber, con evidencia estadística y no solo intuición, si de verdad generaba más conversión y más gasto que la versión original (A) — y si factores como el dispositivo o el canal de tráfico estaban influyendo en el resultado.

## Proceso

Planteé una hipótesis nula y una alternativa para cada pregunta de negocio, y usé la prueba estadística correcta según el tipo de variable: **prueba t de Student** (varianzas no asumidas iguales) para comparar el gasto promedio entre usuarios convertidos de A y B, y **pruebas Chi-cuadrado de independencia** para evaluar si la conversión dependía de la versión de landing, la fuente de tráfico, el tipo de dispositivo o el tipo de usuario (nuevo vs. recurrente). Fijé un nivel de significancia de α = 0.05 en todas las pruebas.

```python
t_stat, p_value_gasto = ttest_ind(gasto_A, gasto_B, equal_var=False)
chi2_stat, p_value, dof, expected = chi2_contingency(tabla_landing)
```

## Resultado

- **Landing B gana con evidencia sólida:** mayor gasto promedio ($68.75 vs. $61.09, p<0.001) y mayor tasa de conversión (15.96% vs. 12.57%, ~27% de incremento relativo, p<0.001). **Recomendación: migrar el tráfico a la versión B.**
- **El dispositivo sí importa** (chi²=67.28, p<0.001): la conversión no es uniforme entre plataformas, lo que abre una oportunidad concreta de optimizar la UI/UX por tipo de dispositivo.
- **La fuente de tráfico también está asociada a la conversión** (chi²=8.66, p=0.034), útil para priorizar presupuesto de marketing.
- **El tipo de usuario no es relevante** (14.36% nuevos vs. 14.09% recurrentes, p=0.474): no hace falta diferenciar la estrategia de conversión por este segmento.

## Visuales

*(Agregar aquí: el boxplot de gasto por versión y las gráficas de tasa de conversión por fuente de tráfico y dispositivo.)*

## Lección

Este proyecto me enseñó a elegir la prueba correcta según la pregunta, no solo aplicar "una prueba estadística" en automático: medias continuas piden t-test, relaciones entre categóricas piden Chi-cuadrado. También aprendí que un resultado *no significativo* (como el tipo de usuario) es información igual de valiosa que uno significativo — te dice claramente en qué **no** vale la pena invertir esfuerzo de segmentación, y evita que el equipo persiga diferencias que en realidad no existen.

**Tecnologías:** Python (Pandas, SciPy — `ttest_ind`, `chi2_contingency`), Seaborn, Matplotlib, pruebas de hipótesis.
