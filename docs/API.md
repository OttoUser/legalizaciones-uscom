# API REST

Autenticación: `POST /api/auth/login`, `GET /api/auth/me`, `POST /api/auth/logout`.

Administración: `POST|GET /api/admin/users`, `PATCH /api/admin/users/:id`, `PATCH /api/admin/users/:id/activate|deactivate`, `GET /api/admin/legalizations`, `GET /api/admin/legalizations/:projectId`.

Operación: `POST|GET /api/projects`, `GET|PATCH /api/projects/:id`, `POST /api/projects/:id/finalize`, `POST|GET /api/projects/:projectId/expenses`, `DELETE /api/expenses/:id`, `POST /api/expenses/:expenseId/receipt`, `GET /api/projects/:projectId/summary`, `POST /api/projects/:projectId/reports/pdf|excel`.

Todas las rutas `/api` salvo login requieren `Authorization: Bearer <JWT>`. `GET /health` es público.
