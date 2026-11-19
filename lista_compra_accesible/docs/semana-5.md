# Semana 5 · Evidencias técnicas

Los criterios de referencia son RF01–RF08 y RNF01–RNF12 incluidos en el encargo.
La memoria y Penpot deben contrastarse cuando el equipo facilite su acceso.

## Evidencia automatizada

| Requisito | Componentes y corrección | Prueba o evidencia |
| --- | --- | --- |
| RF01–RF04 y RF08 | P01–P07, `AppState`, `money.dart`. Alta y edición, cantidades, marcado, importes en céntimos y ausencia distinta de cero. | Pruebas de estado y los tres recorridos de widgets, con cancelaciones y entradas inválidas. |
| RF05, RF07, RNF03, RNF05–RNF07 | Casillas e interruptores con nombre contextual, etiquetas de estado visibles, regiones vivas y gestos estándar. | Inspección del árbol semántico y cambios de estado en Flutter Test. La locución y el foco con TalkBack quedan pendientes. |
| RF06, RNF08 | Borrado con diálogo y aviso de cinco segundos. «Deshacer» verifica el ID de la lista original. | Regresión de dos listas y origen eliminado, más prueba de widget que activa «Deshacer» tras cuatro segundos. |
| RNF01 | Los pares de la paleta probados superan 4,5:1 para texto y 3:1 para el borde del control. | Prueba de luminancia sobre los colores declarados. Falta validar los estados dibujados en Android. |
| RNF02 y RNF04 | Área táctil mínima de 48 dp en selector y calculadora. P03 desplaza cabecera, productos y acciones. | Guía táctil de Flutter en P01–P07 y calculadora. Recorridos al 200 % a 320 × 568. En P06 se simuló un teclado con un margen inferior de 240 dp. |
| RNF09 y RNF10 | La interfaz refleja las mutaciones inmediatamente. Se carga una instantánea antes de montar Inicio y se guardan las escrituras en orden. | Pruebas de cambio de estado, restauración con ID estable, ausencia y corrupción de datos, escritura fallida y recuperación. No hubo medición de latencia ni reinicio de un proceso Android. |
| RNF11 y RNF12 | La app usa almacenamiento local y la fuente se incluye en los recursos. Flutter y el plugin Android declaran un mínimo 24 para el SDK validado. | Compilación web con recursos locales y arranque en Edge. La instalación y el uso en modo avión en Android API 26 quedan pendientes. |

## Resultados del entorno

- `flutter pub get` completó la resolución.
- `dart format --output=none --set-exit-if-changed lib test` indicó 19 archivos y
  ningún cambio necesario.
- `flutter analyze` informó 15 avisos informativos de deprecación de Material en
  Flutter 3.50, cero errores y cero advertencias. `flutter analyze --no-pub
  --no-fatal-infos` terminó con código 0.
- `flutter test --no-pub --reporter expanded` ejecutó 13 pruebas, todas superadas.
- `flutter devices` enumeró Edge 157.0.4341.60 y Windows. `flutter doctor -v`
  encontró Flutter 3.50.0 y Dart 3.14.0 y no encontró el SDK de Android ni Visual
  Studio.
- `flutter run -d edge --no-pub --no-resident` arrancó la app. `flutter build
  web --no-pub --no-web-resources-cdn --no-tree-shake-icons` generó `build/web`.
  El intento de compilación con reducción de iconos fue bloqueado por la política
  de aplicaciones de Windows al lanzar `font-subset.exe`. Las protecciones del
  sistema se mantuvieron activas.
- `flutter build apk --debug --no-pub` terminó con «No Android SDK found».
  TalkBack y la prueba nativa en Android quedaron pendientes.
- Con la build final servida en localhost, Edge en un perfil temporal creó
  «Compra semanal» con la red del navegador desactivada. La instantánea de
  `localStorage` contenía su ID. Al restablecer la red y abrir Inicio en una
  carga nueva, la lista apareció y la instantánea conservó el mismo ID.
  Para repetirlo, sirve `build/web` en localhost, desactiva la red desde
  DevTools con la app cargada, crea la lista y verifica que sigue apareciendo
  tras restablecer la conexión y volver a abrir Inicio.

## Protocolo inicial de TalkBack

Registra el commit o estado del código, dispositivo, versión de Android,
versión de TalkBack, modo de navegación, tamaño de texto y fecha. Realiza la
primera pasada con TalkBack activado y repite con escalado de texto al 200 %
cuando el dispositivo permita configurarlo.

| Paso | Acción | Resultado esperado | Resultado observado |
| --- | --- | --- | --- |
| 1 | En Inicio, desliza para localizar «Crear lista nueva». Crea «Mercado» y después «Farmacia». | El lector anuncia el botón, la etiqueta del campo, el título de detalle y el estado vacío. Cada interruptor de vigencia identifica su lista y estado. | Pendiente |
| 2 | Abre «Mercado», añade «Leche» y «Pan». Intenta guardar un nombre vacío antes de completar el alta. | El campo tiene nombre, el error se puede localizar, el teclado permite corregirlo y el botón de guardar sigue accesible. | Pendiente |
| 3 | Recorre ambos productos por deslizamiento. Marca y desmarca «Leche». | Se identifica la casilla de Leche, su estado actualizado y el texto de confirmación. El foco permite seguir al producto siguiente. | Pendiente |
| 4 | Incrementa y decrementa la cantidad. Abre el menú y elimina «Leche». | Los botones identifican la acción y el producto. El diálogo identifica el elemento. El aviso permite activar «Deshacer» y comunica la recuperación. | Pendiente |
| 5 | Registra primero un importe inválido y luego 0,00 €. Abre «Modificar importe». | Se identifica la causa del error y el campo conserva el valor. El resumen muestra 0,00 € como registrado y el formulario lo precarga. | Pendiente |
| 6 | Con la app instalada, activa modo avión, cierra el proceso tras guardar y vuelve a abrirlo. En API 26 repite si hay dispositivo. | La lista, sus datos y el gasto se conservan. Las funciones y la fuente siguen disponibles. | Pendiente |

Para cada incidencia, anota ruta, gesto, locución literal, foco antes y después,
resultado visual y reproducibilidad. Corrige las incidencias y vuelve a ejecutar
el mismo paso con el entorno anotado.
