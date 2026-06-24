---
epoch: 1782261434176
modelKey: "gemini-3.1-flash-lite|google"
topic: "Problema visualización plantillas notas"



tags:
  - copilot-conversation
---

**user**: {copilot/copilot-custom-prompts} Porque, si solo tengo dos plantillas: Plantilla_Herramienta y Plantilla_Operación, cuando veo de forma gráfica las notas hay un nobre nota herramienta 1, 2, nombre operacion anterior etc?
[Timestamp: 2026/06/23 18:37:14]

**ai**: La razón por la que ves nombres como "nombre nota herramienta 1", "nombre operacion anterior", etc., al visualizar tus notas de forma gráfica (probablemente usando el **Grafo de Obsidian** o un plugin de visualización), se debe a que **estás viendo los marcadores de posición (placeholders) que quedaron en tus notas**.

Aquí te explico por qué sucede esto y cómo solucionarlo:

### 1. El origen del problema: "Plantillas vs. Notas Finales"
Cuando utilizas una plantilla, esta contiene texto descriptivo que sirve como guía para que tú (o el asistente) sepas qué información debe ir en cada lugar. Por ejemplo, en tu `Plantilla_Operacion.md` aparece:

```markdown
- **Operación previa:** [[Nombre_Operacion_Anterior]]
- **Siguiente operación:** [[Nombre_Operacion_Siguiente]]
```

Si al crear la nota final no reemplazaste `[[Nombre_Operacion_Anterior]]` por el nombre real de una nota existente (como `[[Limpieza_y_Normalizacion]]`), Obsidian crea un **enlace roto** hacia una nota que literalmente se llama "Nombre_Operacion_Anterior".

### 2. ¿Por qué aparecen en el grafo?
El grafo de Obsidian detecta todos los enlaces internos (`[[...]]`). Si en tu nota tienes un enlace a `[[Nombre_Operacion_Anterior]]`, Obsidian asume que esa es una nota que debería existir. Al no existir, el grafo la muestra como un nodo "fantasma" o desconectado.

### 3. Cómo solucionarlo
Para limpiar tu grafo y que la estructura sea profesional, debes realizar una "limpieza de metadatos" en tus notas:

- **Reemplaza los placeholders:** Cada vez que crees una nota nueva a partir de la plantilla, asegúrate de borrar los textos genéricos y sustituirlos por enlaces reales a notas que sí existan en tu vault.
- **Usa enlaces vacíos si no hay conexión:** Si una operación no tiene una "operación anterior", simplemente borra esa línea o déjala como texto plano, no como un enlace `[[...]]`.
- **Revisa las notas existentes:** Busca en tu vault si tienes notas creadas con nombres genéricos (como "nombre herramienta 1"). Si las encuentras, puedes borrarlas o renombrarlas correctamente.

### Recomendación para el futuro
Cuando le pidas al asistente que genere una nota usando estas plantillas, añade esta instrucción adicional:

> "Por favor, asegúrate de que todos los enlaces internos `[[...]]` apunten a notas reales existentes en mi vault. Si no existe una conexión (como una operación anterior), deja el campo vacío o elimina la línea, pero no dejes los nombres de los placeholders de la plantilla."

Esto evitará que el asistente genere enlaces a notas que no existen y mantendrá tu grafo limpio y organizado.
[Timestamp: 2026/06/23 18:37:17]