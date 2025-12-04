# 🧭 Flujo completo de Onboarding

Este documento consolida la lógica, estructura y propósito de los tres pasos del formulario de onboarding, el contenedor general y la pantalla final de confirmación. Todo el flujo está orquestado por `onboarding_screen.dart` y gestionado por `onboarding_controller.dart`.

---

## 🧩 Paso 1: Identidad del usuario (`step_identity.dart`)

### 🎯 Propósito
Recoger información básica del usuario para iniciar el vínculo emocional y adaptar la experiencia.

### 🧱 Campos
- `nombre`: Campo de texto
- `edad`: Campo numérico
- `genero`: Selector (Mujer, Hombre, Otro, Prefiero no decirlo)

### 🔄 Lógica
- Validar que los tres campos estén llenos
- Llamar a `onboardingController.actualizarIdentidad(...)`
- Navegar a `step_routine.dart`

### 💡 Tono emocional
- Cálido, sin prisa
- Frases como: “Queremos conocerte mejor”, “Esto nos ayudará a acompañarte mejor”

---

## 🧩 Paso 2: Rutina diaria (`step_routine.dart`)

### 🎯 Propósito
Recoger los horarios habituales del usuario para desayuno, almuerzo y cena. Esto permite adaptar notificaciones y sugerencias a su ritmo real.

### 🧱 Campos
- `horaDesayuno`: Selector de hora
- `horaAlmuerzo`: Selector de hora
- `horaCena`: Selector de hora

### 🔄 Lógica
- Validar que los tres campos estén definidos
- Llamar a `actualizarRutina(...)`
- Navegar a `step_preferences.dart`

### 💡 Tono emocional
- Cálido y respetuoso del ritmo del usuario
- Frases como: “¿A qué hora sueles desayunar?”, “Queremos acompañarte en tus momentos importantes”

---

## 🧩 Paso 3: Actividades y energía (`step_preferences.dart`)

### 🎯 Propósito
Conocer qué actividades disfruta el usuario y cómo se siente energéticamente para ofrecerle sugerencias acordes.

### 🧱 Campos
- `actividadesPreferidas`: Lista de actividades seleccionables (caminar, leer, música, jardinería, etc.)
- `nivelEnergia`: Selector (Alta, Media, Baja)

### 🔄 Lógica
- Validar que haya al menos una actividad y un nivel de energía
- Llamar a `actualizarPreferencias(...)`
- Navegar a la pantalla de confirmación

### 💡 Tono emocional
- Empático, con frases como: “¿Qué te hace sentir bien?”, “¿Cómo te sientes últimamente?”

---

## 🧭 Contenedor del flujo (`onboarding_screen.dart`)

### 🎯 Propósito
Orquestar el flujo entre los tres pasos del onboarding.

### 🔄 Lógica
- Usa `PageView` o `IndexedStack` para mostrar cada paso
- Controla el avance y retroceso
- Escucha al `OnboardingController` para validar cada paso
- Al finalizar, navega a la pantalla de confirmación

---

## ✅ Pantalla final: Confirmación (`pantalla_confirmacion.dart`)

### 🎯 Propósito
Cerrar el onboarding con calidez y gratitud. Confirmar que los datos fueron recibidos.

### 🧱 Contenido
- Mensaje: “Gracias por compartir tu rutina. Estamos aquí para ti.”
- Botón: “Comenzar” → Navega al `home` o `dashboard`

### 🔄 Lógica
- Llama a:
  ```dart
  FirebaseFirestore.instance
    .collection('usuarios')
    .add(onboardingController.obtenerDatos());