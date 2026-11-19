# Lista de la compra accesible · Grupo L

Aplicación Flutter de la asignatura de Accesibilidad. Permite crear y consultar
listas, añadir y editar productos, modificar cantidades, marcar compras,
eliminar productos con opción de recuperarlos y registrar el gasto de cada lista.
Inicio muestra también el total de listas vigentes y su calculadora.

## Entorno e instalación

Se usa Flutter 3.50.0 stable con Dart 3.14.0 en la validación de Semana 5. El
lockfile recoge el mínimo de las dependencias resueltas. Para Android hacen falta
el SDK de Android, Java 17 y un dispositivo o emulador. Para web puede usarse Edge.

Desde esta carpeta:

```sh
flutter doctor -v
flutter pub get
flutter devices
flutter run -d <id-del-dispositivo>
```

Para compilar Android en modo depuración, ejecuta `flutter build apk --debug`.
Para distribuir la versión web con el motor incluido en el alojamiento, ejecuta
`flutter build web --no-web-resources-cdn`. La prueba sin conexión en web
presupone que la aplicación ya se ha cargado. En el Windows de la auditoría se
añadió `--no-tree-shake-icons` a la compilación web para incluir los iconos completos
y evitar la herramienta de subconjuntos bloqueada por el sistema.

## Recorridos

1. **Crear y añadir.** En Inicio elige «Crear lista nueva», indica el nombre y crea
   la lista. En el detalle elige «Añadir producto», indica nombre y cantidad y
   guarda. Para abrir una lista existente usa «Abrir» en su tarjeta.
2. **Marcar y desmarcar.** Activa la casilla del producto en el detalle. Su estado
   cambia entre «Comprado» y «Pendiente» y se actualizan los totales. El menú del
   producto permite editar y eliminar. Tras confirmar una eliminación hay cinco
   segundos para pulsar «Deshacer» como mínimo habitual; con navegación accesible
   Flutter puede mantener visible el aviso durante más tiempo.
3. **Registrar gasto.** Desde el detalle, elige «Registrar gasto», escribe el
   importe y guarda. El resumen muestra el importe y los conteos; «Modificar
   importe» abre el gasto actual. «Sin gasto registrado» distingue una compra
   sin dato de un importe introducido de 0,00 €.

## Código y datos

- `lib/main.dart` configura rutas, idioma español y carga del estado.
- `lib/screens/` contiene P01–P07. `lib/widgets/` y `lib/theme/` contienen
  los componentes y estilos comunes.
- `lib/models/` contiene listas, productos y formato de importes.
- `lib/state/app_state.dart` aplica cambios y serializa una instantánea JSON.
  `SharedPreferencesAsync` delega el almacenamiento en la plataforma. Se lee
  antes de mostrar Inicio y las escrituras se encadenan en el orden de los cambios.
  Los identificadores permanecen estables entre sesiones y «Deshacer» usa el ID
  original de la lista. Los importes se guardan en céntimos enteros y pueden
  estar ausentes. Se aceptan coma o punto, hasta dos decimales, sin separadores
  de miles, y un máximo de 999999999,99 €.
- `assets/fonts/` incluye Source Sans 3 y su licencia para usarla sin red.
- `test/` contiene pruebas unitarias y de widgets.

El almacenamiento es local al dispositivo o al perfil y origen del navegador.
Cerrar la app durante una escritura todavía pendiente puede perder el último
cambio; la aplicación conserva la última instantánea escrita correctamente.
Un dato corrupto abre la app en vacío y muestra un aviso. Si falla la lectura
del almacenamiento, esa sesión conserva los cambios en memoria y evita
sobrescribir una instantánea que todavía podría ser válida.

## Accesibilidad y pruebas

La interfaz identifica los estados con texto, usa etiquetas contextuales en los
controles repetidos, muestra confirmaciones y comunica cambios de estado
mediante semántica. Los controles de cantidad y las teclas tienen objetivos
táctiles de al menos 48 dp; el detalle permite desplazar el contenido completo y
los formularios permiten desplazar campos y acciones con el teclado abierto.

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
```

Flutter 3.50 emite avisos informativos de deprecación sobre sus exportaciones
Material. La variante anterior del análisis conserva los mensajes y exige que
el recuento de errores y advertencias sea cero.

La [evidencia de Semana 5](docs/semana-5.md) contiene los resultados obtenidos y
el protocolo de TalkBack. La memoria y el prototipo de Penpot no estaban
incluidos en el repositorio auditado.


## Recursos de Flutter

- [Primeros pasos](https://docs.flutter.dev/get-started/learn-flutter)
- [Primera aplicación](https://docs.flutter.dev/get-started/codelab)
- [Recursos de aprendizaje](https://docs.flutter.dev/reference/learning-resources)
- [Documentación](https://docs.flutter.dev/)
