// index.js - Entry point for the backend API
// This file sets up the Express app with security, error handling, and best practices.
// Documentation is provided inline for clarity and maintainability.

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const routes = require('./routes');
const { errorHandler, notFoundHandler } = require('./middleware');
const rateLimit = require('express-rate-limit');
const swaggerUi = require('swagger-ui-express');
const swaggerJSDoc = require('swagger-jsdoc');

const app = express();

// Middleware for security headers
app.use(helmet());
// Rate limiting: 100 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later.' }
});
app.use(limiter);

// Enable CORS for specific origins in production
const corsOptions = {
  origin: process.env.CORS_ORIGIN || '*', // Set to your frontend URL in production
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));
// Logging HTTP requests
app.use(morgan('combined'));
// Parse JSON bodies
app.use(express.json());

// Swagger/OpenAPI setup
const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'Supply Chain Management API',
    version: '1.0.0',
    description: 'API documentation for the food industry supply chain management system.'
  },
  servers: [
    { url: '/api/v1' }
  ]
};
const swaggerOptions = {
  swaggerDefinition,
  apis: ['./src/routes.js'], // Path to the API docs
};
const swaggerSpec = swaggerJSDoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Versioned API route
app.use('/api/v1', routes);

// 404 handler for unknown routes
app.use(notFoundHandler);
// Centralized error handler
app.use(errorHandler);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Backend API running on port ${PORT}`);
});
