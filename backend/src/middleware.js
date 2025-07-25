// middleware.js - Centralized error and 404 handling for the backend API
// Provides best-practice error handling and security-focused responses.

const jwt = require('jsonwebtoken');

/**
 * Handles 404 Not Found errors for unknown routes.
 */
function notFoundHandler(req, res, next) {
  res.status(404).json({ error: 'Not Found' });
}

/**
 * Centralized error handler for all exceptions.
 * Never exposes stack traces or sensitive info in production.
 */
function errorHandler(err, req, res, next) {
  console.error(err); // Log for monitoring
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    // Only show stack in development
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
}

/**
 * Middleware to authenticate JWT tokens
 */
function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid token' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET || 'changeme');
    req.user = payload;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

/**
 * Middleware to authorize based on user roles
 * Usage: authorizeRoles('ADMIN', 'MANAGER')
 */
function authorizeRoles(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden: insufficient role' });
    }
    next();
  };
}

module.exports = { notFoundHandler, errorHandler, authMiddleware, authorizeRoles };
