# SeniorCareApp – Reformulación Humanizada

## 🎯 Propósito Central

Una app diseñada para acompañar a personas mayores en su día a día, respetando su ritmo, sus hábitos y su autonomía. No es un panel de control. Es un compañero digital cálido, útil y emocionalmente inteligente.

---

## 🧭 Estructura Modular

### 1. Inicio emocional

- Pantalla de bienvenida con voz:  
  “Hola Milton, empezamos un nuevo día juntos. Hoy te acompaño con cariño.”
- Transición suave a la pantalla principal

---

### 2. Pantalla principal: “Tu día, a tu ritmo”

- Mensaje central dinámico según la hora y el estado:
  - “¡Buenos días, Milton! ¿Ya desayunaste?”
  - “Es hora de tu pastilla: Lisinopril 10mg”
  - “Recuerda moverte un poco. ¿Te apetece caminar?”
- Botones grandes y claros:
  - ✅ TOMADA / ❌ SALTAR
  - 📞 LLAMAR A HIJO
  - 🏠 VOLVER A CASA
- Clima y hora como contexto, no como foco
- Recordatorios suaves y aleatorios:
  - “Hidrátate”
  - “Descansa la vista”
  - “Camina unos pasos”

---

### 3. Formulario inicial de rutina

- Se muestra al instalar la app
- Campos:
  - Nombre, edad, sexo
  - Horarios de despertar, comidas, sueño
  - Hábitos nocturnos (levantarse a orinar)
  - Preferencias de recordatorios (voz, texto, clima)
- Datos guardados en Firestore (`usuario_actual`)
- Usados para personalizar alarmas y mensajes

---

### 4. Gestión de medicamentos

- Pantalla secundaria: “Mis medicamentos”
- Funciones:
  - Agregar, editar, borrar
  - No visible en la pantalla principal
- Medicamentos activos se muestran solo:
  - 2 horas antes y 2 horas después de la toma
  - Integrados en el flujo del día

---

### 5. Sistema de activación inteligente

- Medicamentos aparecen solo cuando toca
- Recordatorios suaves intercalados según rutina
- Nada está fijo: todo se adapta al usuario

---

## 🧠 Filosofía de diseño

- **Humanizar la tecnología**
- **Respetar el ritmo del usuario**
- **Evitar sobrecarga visual o funcional**
- **Crear una experiencia emocionalmente significativa**

---

## 🛑 Desviaciones que debemos evitar

- Convertir la app en un panel técnico
- Mostrar listas o botones de gestión en la pantalla principal
- Imponer horarios sin conocer la rutina del usuario
- Priorizar funciones sobre emociones

---

## ✅ Confirmación

Este documento representa el nuevo norte de SeniorCareApp.  
Toda decisión futura debe alinearse con esta visión.
