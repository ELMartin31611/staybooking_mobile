# StayBooking

Aplicacion integral de reservas de hotel desarrollada como proyecto academico. El sistema permite a clientes buscar hoteles, seleccionar habitaciones, registrar huespedes, crear reservas, pagar y consultar facturas. Tambien dispone de un panel administrativo para gestionar la oferta hotelera.

La solucion esta formada por una API REST desplegada con Django REST Framework y una aplicacion Flutter multiplataforma. La comunicacion se realiza mediante HTTP, JSON y autenticacion JWT.

## Objetivo

Centralizar el proceso de reserva de habitaciones de hotel en una sola plataforma:

- Clientes: consultar hoteles, habitaciones y servicios; crear y pagar reservas; revisar pagos, facturas y perfil.
- Administradores: crear y administrar hoteles, tipos de habitacion, habitaciones, imagenes, reservas, pagos y facturas.
- Sistema: mantener relaciones entre hoteles, habitaciones, tarifas, temporadas, reservas, huespedes y comprobantes de pago.

## Tecnologias utilizadas

| Capa | Tecnologias |
|---|---|
| Aplicacion movil/web | Flutter y Dart |
| Gestion de estado | Riverpod |
| Navegacion | go_router |
| Consumo de API | Dio |
| Sesion segura | flutter_secure_storage y JWT |
| Seleccion de imagenes | image_picker |
| Backend | Python, Django y Django REST Framework |
| Autenticacion | SimpleJWT |
| Base de datos | PostgreSQL |
| Documentacion API | drf-spectacular / Swagger |
| Despliegue | Gunicorn, Nginx, SSL y GitHub Actions |

## Enlaces principales

- API desplegada: `https://staybooking-api.uaeftt-ute.site/api/`
- Repositorio movil: `staybooking_mobile`
- Repositorio backend: `reserva_hotel_backend`

## Arquitectura

El proyecto movil utiliza una separacion por capas para mantener el codigo claro y escalable.

```text
lib/
├── core/
│   ├── config/                 # URLs y configuracion de API
│   └── error/                  # Excepciones y manejo de errores
├── data/
│   ├── remote/api/             # Dio y fuentes remotas
│   └── repository/             # Implementaciones de repositorios
├── domain/
│   ├── model/                  # Entidades del negocio
│   └── repository/             # Contratos de repositorios
├── presentation/
│   ├── navigation/             # Rutas y navegacion
│   ├── providers/              # Estado Riverpod
│   ├── screens/                # Pantallas de cliente y administrador
│   └── widgets/                # Componentes reutilizables
├── theme/                      # Colores y estilos globales
└── main.dart
```

Flujo tecnico:

```text
Pantalla Flutter -> Provider Riverpod -> Repository / DataSource -> API Django -> PostgreSQL
```

## Diseno visual

La interfaz sigue una linea inspirada en Airbnb:

- Color principal: `#FF385C`.
- Fondos claros, tarjetas blancas y bordes suaves.
- Acciones principales visibles en rosa.
- Estados de reserva diferenciados por color.
- Formularios simples, responsivos y pensados para movil y web.

## Autenticacion y seguridad

StayBooking usa JWT para proteger la informacion privada.

1. El usuario inicia sesion con credenciales.
2. La API devuelve un `access token` y un `refresh token`.
3. Flutter guarda los tokens en almacenamiento seguro.
4. El interceptor de Dio agrega `Authorization: Bearer <token>` en cada solicitud protegida.
5. Si la sesion expira, se solicita renovacion mediante el refresh token.
6. Al cerrar sesion se eliminan los tokens y se redirige al login.

Las rutas de administracion y las operaciones de escritura estan restringidas por rol.

## Roles del sistema

| Rol | Acciones principales |
|---|---|
| Cliente | Registrarse, iniciar sesion, buscar hoteles, consultar habitaciones, crear reservas, agregar huespedes, pagar, ver facturas y actualizar perfil. |
| Administrador | Acceder al dashboard, administrar hoteles, tipos de habitacion, habitaciones, imagenes, reservas, pagos y facturas. |

## Modelo de datos

El backend contiene las siguientes entidades principales.

### Usuarios y clientes

1. PerfilUsuario
2. Cliente
3. DireccionCliente
4. DocumentoCliente

### Empleados y operacion

5. CargoEmpleado
6. Empleado
7. Turno
8. EmpleadoTurno

### Catalogo hotelero

9. Hotel
10. DireccionHotel
11. TipoHabitacion
12. Habitacion
13. Cama
14. TipoHabitacionCama
15. ImagenHabitacion
16. Servicio
17. TipoHabitacionServicio

### Tarifas y temporadas

18. Temporada
19. TarifaHabitacion

### Reservas y facturacion

20. Reserva
21. ReservaHabitacion
22. HuespedReserva
23. Pago
24. Factura
25. NotificacionSistema

### Relaciones relevantes

| Relacion | Descripcion |
|---|---|
| Hotel 1:N TipoHabitacion | Un hotel puede ofrecer varios tipos de habitacion. |
| TipoHabitacion 1:N Habitacion | Cada tipo puede tener varias habitaciones fisicas. |
| Habitacion 1:N ImagenHabitacion | Cada habitacion puede tener una o varias imagenes. |
| TipoHabitacion N:N Servicio | Una habitacion puede ofrecer varios servicios. |
| TipoHabitacion N:N Cama | Un tipo puede incluir una o varias camas. |
| TipoHabitacion 1:N TarifaHabitacion | El precio depende de tipo y temporada. |
| Reserva N:N Habitacion | Se representa mediante ReservaHabitacion. |
| Reserva 1:N HuespedReserva | Una reserva puede tener varios huespedes. |
| Reserva 1:N Pago | Una reserva puede registrar uno o mas pagos. |
| Reserva 1:N Factura | La reserva genera comprobantes de facturacion. |

## Endpoints consumidos

Todos los endpoints se encuentran bajo el prefijo `/api/`.

| Recurso | Endpoint |
|---|---|
| Autenticacion | `auth/login/`, `auth/register/`, `auth/token/refresh/`, `auth/logout/` |
| Perfil | `perfil-usuario/` |
| Hoteles | `hoteles/` |
| Tipos de habitacion | `tipos-habitacion/` |
| Habitaciones | `habitaciones/` |
| Imagenes de habitacion | `imagenes-habitacion/` |
| Camas y servicios | `camas/`, `servicios/` |
| Temporadas | `temporadas/` |
| Tarifas | `tarifas-habitacion/` |
| Reservas | `reservas/`, `reserva-habitaciones/`, `huespedes-reserva/` |
| Pagos | `pagos/` |
| Facturas | `facturas/` |

## Flujo del cliente

1. El cliente se registra o inicia sesion.
2. Consulta el catalogo de hoteles.
3. Ingresa al detalle de un hotel y revisa los tipos y habitaciones disponibles.
4. Selecciona fechas de entrada y salida.
5. Indica cantidad de adultos y ninos.
6. Selecciona una o varias habitaciones.
7. La aplicacion calcula noches, subtotal, impuestos y total.
8. Registra los huespedes de acuerdo con la capacidad solicitada.
9. Confirma la reserva, inicialmente con estado pendiente.
10. Desde el detalle de reserva puede iniciar el pago.
11. Al registrar o confirmar un pago, puede consultar su factura.

### Calculo de reserva

El precio usa la tarifa activa de la habitacion para la temporada aplicable.

```text
Subtotal = precio por noche x numero de noches x habitaciones seleccionadas
Impuestos = subtotal x porcentaje de impuesto
Total = subtotal + impuestos - descuentos
```

La interfaz tambien valida que la cantidad de huespedes registrada no exceda la capacidad solicitada en la reserva.

## Flujo del administrador

1. El administrador inicia sesion con un usuario que tiene rol administrativo.
2. Accede al Dashboard desde el menu administrativo.
3. Crea o edita hoteles, incluyendo logo cargado desde el dispositivo.
4. En administracion de habitaciones crea tipos como Individual, Doble, Familiar o Suite.
5. Para cada tipo define capacidad, tamano y precio base.
6. Crea habitaciones fisicas asociadas al hotel y tipo seleccionado.
7. Carga una imagen principal de cada habitacion desde la galeria o dispositivo.
8. Consulta y administra reservas, pagos y facturas.

El panel administrativo incluye acciones para actualizar, editar, eliminar y administrar imagenes de las habitaciones.

## Manejo de imagenes

Las imagenes se cargan como archivos `multipart/form-data`.

- Logo de hotel: se envia al crear o editar un hotel.
- Imagen de habitacion: se sube al crear una habitacion y se registra como imagen principal.
- Formatos permitidos: JPG, JPEG, PNG y WebP.
- El backend valida tipo de archivo y tamano maximo.
- Nginx publica los archivos desde `/media/`.

## Estructura del backend

```text
reserva_hotel_backend/
├── config/
│   ├── settings.py
│   └── urls.py
├── hotel_app/
│   ├── models/
│   ├── serializers/
│   ├── views/
│   ├── permissions.py
│   ├── validators.py
│   └── migrations/
├── media/
├── staticfiles/
├── manage.py
├── pyproject.toml
└── .env
```

## Configuracion local del movil

1. Clonar el repositorio.
2. Crear el archivo `.env` en la raiz del proyecto.
3. Definir la URL de API.
4. Instalar dependencias y ejecutar Flutter.

Ejemplo de `.env`:

```env
API_BASE_URL=https://staybooking-api.uaeftt-ute.site/api/
APP_NAME=StayBooking
```

Comandos:

```bash
flutter pub get
flutter analyze lib
flutter run
```

En Windows, si Flutter solicita soporte de enlaces simbolicos, habilitar Developer Mode.

## Configuracion local del backend

Variables principales del archivo `.env`:

```env
SECRET_KEY=tu_clave_secreta
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,staybooking-api.uaeftt-ute.site
DB_NAME=nombre_base_datos
DB_USER=usuario_base_datos
DB_PASSWORD=contrasena_base_datos
DB_HOST=localhost
DB_PORT=5432
```

Comandos de mantenimiento:

```bash
uv run python manage.py makemigrations
uv run python manage.py migrate
uv run python manage.py check
uv run python manage.py runserver
```

## Despliegue

El backend se despliega con los siguientes componentes:

```text
Internet -> Nginx con SSL -> Gunicorn -> Django REST Framework -> PostgreSQL
```

- Nginx atiende HTTPS y publica `static/` y `media/`.
- Gunicorn ejecuta Django mediante socket Unix.
- Certbot administra el certificado SSL.
- GitHub Actions automatiza el despliegue al integrar cambios en `main`.

## Division del trabajo

| Integrante | Responsabilidad |
|---|---|
| Integrante 1 | Autenticacion JWT, usuarios, perfiles, clientes y seccion publica inicial. |
| Integrante 2 | Catalogo hotelero: hoteles, habitaciones, camas, servicios, imagenes y tipos de habitacion. |
| Integrante 3 - Martin | Temporadas, tarifas, reservas, reserva-habitaciones, huespedes, pagos, facturas, flujo de compra y consolidacion del panel administrador. |

## Control de versiones

El equipo trabaja con ramas por modulo y fusiona las funcionalidades terminadas a `main`.

Ejemplo de flujo:

```bash
git checkout nombre-rama
git pull origin nombre-rama
flutter analyze lib
git add lib
git commit -m "feat: descripcion del cambio"
git push origin nombre-rama
```

Posteriormente se crea Pull Request o se integra mediante merge controlado a `main`.

## Validaciones implementadas

- Inicio de sesion mediante JWT.
- Restriccion de pantallas y acciones por rol.
- Fechas de reserva validas.
- Registro de huespedes acorde a la reserva.
- Habitaciones disponibles antes de reservar.
- Seleccion obligatoria de hotel, tipo de habitacion, numero e imagen al crear una habitacion.
- Carga controlada de imagenes.
- Estados de reserva, pago y factura.
- Manejo visual de carga, error y reintento en las pantallas principales.

## Estados principales

| Modulo | Estados |
|---|---|
| Reserva | pendiente, confirmada, cancelada, finalizada |
| ReservaHabitacion | activa, cancelada, finalizada |
| Pago | pendiente, aprobado, rechazado, anulado |
| Factura | emitida, pagada, anulada |
| Habitacion | disponible, ocupada, mantenimiento, inactiva |

## Creditos

Proyecto desarrollado por el equipo de StayBooking para la asignatura de Desarrollo de Software / Seminario de Integracion.