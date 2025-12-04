# 🧾 Pantalla 1: Identidad del usuario

Primera pantalla del flujo de onboarding. Su objetivo es recoger información básica del usuario de forma cálida, accesible y sin presión.

---

## 🎯 Propósito

- Iniciar el vínculo emocional con el usuario.
- Recoger datos esenciales de identidad: nombre, edad y género.
- Validar que los campos estén completos antes de avanzar.

---

## 🧱 Estructura visual

- **Encabezado cálido**: "Queremos conocerte mejor"
- **Campo 1**: Nombre (input de texto)
- **Campo 2**: Edad (input numérico)
- **Campo 3**: Género (selector tipo dropdown o botones)
  - Opciones sugeridas: Mujer, Hombre, Otro, Prefiero no decirlo
- **Botón “Siguiente”**: Solo se habilita si todos los campos están completos

---

## 🔄 Lógica

- Al presionar “Siguiente”:
  - Validar que los tres campos estén llenos
  - Llamar a `onboardingController.actualizarIdentidad(...)`
  - Navegar a la pantalla de rutina

---

## 🧠 Estado

- Usa `OnboardingController` como fuente de datos
- Puede usar `TextEditingController` para nombre y edad
- El selector de género puede ser un `DropdownButtonFormField` o `ToggleButtons`

---

## 💡 Tono emocional

- Amable, sin prisa
- Texto grande, legible
- Mensajes como: “Tómate tu tiempo”, “Esto nos ayudará a acompañarte mejor”

---

¿Confirmas esta estructura antes de pasar al código Dart de la pantalla `Identidad`? Puedo generarlo en cuanto me des luz verde.