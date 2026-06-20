# Despliegue en Railway

1. Cree un proyecto Railway llamado **Legalizaciones** y agregue PostgreSQL.
2. Despliegue la carpeta `backend` como servicio. Railway detecta `railway.toml`.
3. En Variables, copie los nombres de `backend/.env.example`; use la `DATABASE_URL` del servicio PostgreSQL y secretos nuevos para JWT y el administrador.
4. Configure `CORS_ORIGIN` con las URL de panel/PWA y `APP_BASE_URL` con el dominio público del backend.
5. Railway ejecuta `prisma migrate deploy`; luego ejecute una vez `npm run seed` tras definir `ADMIN_*`.
6. Valide `https://SU-DOMINIO/health` y compile Flutter con `--dart-define=API_BASE_URL=https://SU-DOMINIO/api`.

Para producción, almacene los recibos en un volumen persistente u objeto S3: el disco efímero de Railway no sobrevive a un redeploy.
