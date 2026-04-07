# GatherPay

GatherPay now includes:

- A Flutter frontend in [`frontend`](c:/Users/yaswanth/Downloads/GatherPay/GatherPay-p-ltd-/frontend)
- A Spring Boot backend in [`backend`](c:/Users/yaswanth/Downloads/GatherPay/GatherPay-p-ltd-/backend)

## Frontend

Run the app from [`frontend`](c:/Users/yaswanth/Downloads/GatherPay/GatherPay-p-ltd-/frontend):

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:9191/api
```

## Spring Boot Backend

The backend provides:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/forgot-password`
- `GET /api/pools`
- `GET /api/pools/{poolId}`
- `POST /api/pools`
- `PUT /api/pools/{poolId}`
- `POST /api/pools/{poolId}/contributions`
- `DELETE /api/pools/{poolId}`
- `GET /api/profile`
- `PUT /api/profile`
- `GET /api/notifications`
- `PATCH /api/notifications/{notificationId}`

### Backend run

From [`backend`](c:/Users/yaswanth/Downloads/GatherPay/GatherPay-p-ltd-/backend):

```bash
mvn spring-boot:run
```

If port `9191` is already occupied on your machine, run:

```bash
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=9292
```

The backend uses JWT authentication, real PostgreSQL persistence, editable user profiles, pool CRUD, contributions, pool-added notifications, pool-updated notifications, and daily reminder notifications. There is no seeded demo login now; register a real account first.

### Backend deployment on Render

This repo now includes [`render.yaml`](c:/Users/yaswanth/Downloads/GatherPay/GatherPay-p-ltd-/render.yaml) so you can deploy the backend without manually running Maven every time.

1. Push this repo to GitHub.
2. In Render, create a new Blueprint deployment from that GitHub repo.
3. Set these environment variables on the `gatherpay-backend` service:
   - `DATABASE_URL`
   - `DATABASE_USERNAME`
   - `DATABASE_PASSWORD`
   - `CORS_ALLOWED_ORIGINS`
4. Render will build with `mvn package -DskipTests` and start with `java -jar target/gatherpay-backend-0.0.1-SNAPSHOT.jar`.
5. After deploy, copy your public backend URL and build the Flutter app with:

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.onrender.com/api
```

For an Android release build, use the same `--dart-define=API_BASE_URL=...` value during `flutter build apk` or `flutter build appbundle`.

### Database config

If you want to override the default database, set these environment variables before starting the backend:

```bash
DATABASE_URL=postgresql://<user>:<password>@<host>/<db>
DATABASE_USERNAME=<user>
DATABASE_PASSWORD=<password>
```

The backend accepts either:

- `jdbc:postgresql://...`
- `postgresql://...`
- `postgres://...`

and will normalize non-JDBC PostgreSQL URLs automatically.

For Render-hosted Postgres, SSL is required. The backend now auto-appends
`sslmode=require` for Render database hosts if it is not already present.
