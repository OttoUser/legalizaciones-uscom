# Legalizaciones USCOM SAS

Monorepo para la legalización corporativa de gastos de viaje: API Node.js, aplicación Flutter (Android, iOS y PWA) y panel web de administración.

## Inicio rápido

1. Copie `backend/.env.example` a `backend/.env` y complete las variables.
2. `cd backend && npm install && npx prisma migrate dev && npm run seed && npm run dev`
3. `cd mobile && flutter pub get && flutter run --dart-define=API_BASE_URL=http://localhost:3000/api`
4. `cd admin-web && npm install && npm run dev`

Consulte [docs](docs/) para despliegue, instalación y API.
