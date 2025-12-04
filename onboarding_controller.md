# 📂 onboarding_controller.dart

Este controlador centraliza los datos del formulario de onboarding, permitiendo que las tres pantallas compartan estado sin perder modularidad ni calidez.

---

## 🎯 Propósito

- Capturar y mantener los datos del usuario durante el proceso de onboarding.
- Facilitar la navegación entre pantallas sin perder información.
- Preparar los datos para ser enviados a Firestore al finalizar.

---

## 🧩 Campos compartidos

```dart
String? nombre;
String? edad;
String? género;

String? horaDesayuno;
String? horaAlmuerzo;
String? horaCena;

List<String> actividadesPreferidas = [];
String? nivelEnergía;