# Backend API - Supply Chain Management (Food Industry)

This backend is a secure, production-ready Node.js (Express) API for managing supply chain operations in the food industry. It follows best practices for security, error handling, and maintainability.

## Key Features
- **Express.js**: Fast, unopinionated web framework
- **Security**: Helmet, CORS, JWT authentication, input validation
- **Error Handling**: Centralized, never leaks sensitive info
- **Logging**: HTTP request logging with Morgan
- **Database**: PostgreSQL via Prisma ORM
- **Scalable Structure**: Organized by routes, controllers, middleware, services, and models

## Project Structure
```
backend/
  src/
    controllers.js   # Business logic for each route
    index.js         # App entry point, middleware, error handling
    middleware.js    # Security, error, and 404 handlers
    models/          # Database models (via Prisma)
    routes.js        # API endpoints
    services/        # Service layer for business logic
    utils.js         # Utility functions
  prisma/
    schema.prisma    # Database schema
  .env               # Environment variables
```

## Security Best Practices
- All endpoints protected by security middleware (Helmet, CORS)
- JWT authentication for sensitive routes (to be implemented)
- Never expose stack traces or sensitive info in production
- Input validation and sanitization (to be implemented)

## Error Handling
- All errors are handled centrally in `middleware.js`
- 404s and server errors return JSON with safe messages
- Logs errors for monitoring and debugging

## Getting Started
1. Install dependencies: `npm install`
2. Configure your database in `.env` and `prisma/schema.prisma`
3. Run migrations: `npx prisma migrate dev`
4. Start the server: `npm start`

## Why This Structure?
- **Separation of concerns**: Each file/folder has a clear responsibility
- **Security first**: Middleware and error handling are prioritized
- **Scalability**: Easy to add new features (routes, services, models)
- **Maintainability**: Well-documented, easy to onboard new developers

---

For more details, see inline code comments and the top-level project documentation. 