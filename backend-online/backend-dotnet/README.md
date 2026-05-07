# Jobito .NET Backend (SQL Server)

Backend API for the Flutter app using ASP.NET Core + EF Core + SQL Server + JWT.

## Project Path

- `backend-dotnet/Jobito.Api`

## Endpoints Implemented

- `POST /api/auth/login`
- `GET /api/jobs`
- `POST /api/jobs`
- `GET /api/applications`
- `POST /api/applications`
- `PATCH /api/applications/{id}/status`
- `GET /api/messages`
- `POST /api/messages`
- `GET /api/notifications`
- `GET /health`
- `GET /swagger`

## SQL Server Connection

Configured in:
- `backend-dotnet/Jobito.Api/appsettings.json`
- `backend-dotnet/Jobito.Api/appsettings.Production.json`

Update these before deploy:
- `ConnectionStrings:DefaultConnection`
- `Jwt:Key`

## Local Run

```bash
cd backend-dotnet/Jobito.Api
dotnet restore
dotnet run
```

Swagger:
- `http://localhost:5000/swagger`
- or `https://localhost:5001/swagger`

## Publish Folder

From repo root:

```bash
powershell -ExecutionPolicy Bypass -File backend-dotnet/publish.ps1
```

On most IIS hosts, the app pool is 64-bit. The default publish runtime has been changed to x64.

Use the single helper file to publish the backend:

```bash
backend-dotnet\update.bat
```

If your host app pool is 32-bit, run:

```bash
backend-dotnet\update.bat -Runtime win-x86
```

If you need framework-dependent deployment instead of self-contained, run:

```bash
backend-dotnet\update.bat -Runtime win-x64 -SelfContained false
```

This script cleans the old publish output and recreates the `logs` folder so IIS can write ASP.NET Core stdout logs.

Important: upload the contents of `backend-dotnet/publish` to the site root, not a subfolder. The `web.config` file must be at the root of the deployed app.

Then upload contents of `backend-dotnet/publish` to your hosting target (`jobito.runasp.net`).

## If you get HTTP 500.30

- Check `logs/stdout*.log` inside published folder on server.
- Confirm `appsettings.Production.json` has valid:
  - SQL Server connection string
  - JWT key
