// routes.js - Main API router for the backend
// This file defines all API endpoints for the supply chain management system.

const express = require('express');
const router = express.Router();
const controllers = require('./controllers');
const { authMiddleware, authorizeRoles } = require('./middleware');
const client = require('prom-client');

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check endpoint
 *     description: Returns API status and timestamp.
 *     responses:
 *       200:
 *         description: API is healthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 */

/**
 * @swagger
 * /metrics:
 *   get:
 *     summary: Prometheus metrics endpoint
 *     description: Exposes Prometheus metrics for monitoring.
 *     responses:
 *       200:
 *         description: Prometheus metrics
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 */

/**
 * @swagger
 * /suppliers:
 *   get:
 *     summary: Get all suppliers
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of suppliers
 *   post:
 *     summary: Create a new supplier
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       201:
 *         description: Supplier created
 */

/**
 * @swagger
 * /products:
 *   get:
 *     summary: Get all products
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of products
 *   post:
 *     summary: Create a new product
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       201:
 *         description: Product created
 */

/**
 * @swagger
 * /orders:
 *   get:
 *     summary: Get all orders
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of orders
 *   post:
 *     summary: Create a new order
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       201:
 *         description: Order created
 */

/**
 * @swagger
 * /trackings:
 *   get:
 *     summary: Get all tracking records
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of tracking records
 *   post:
 *     summary: Create a new tracking record
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       201:
 *         description: Tracking record created
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               name:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [ADMIN, MANAGER, SUPPLIER, USER]
 *     responses:
 *       201:
 *         description: User registered
 *       409:
 *         description: User already exists
 *
 * /auth/login:
 *   post:
 *     summary: Login a user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: JWT token and user info
 *       401:
 *         description: Invalid credentials
 */

// Health check endpoint (public)
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Prometheus metrics endpoint (public)
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();
router.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// Supplier routes
router.get('/suppliers', authMiddleware, controllers.getSuppliers);
router.post('/suppliers', authMiddleware, authorizeRoles('ADMIN'), controllers.createSupplier);

// Product routes
router.get('/products', authMiddleware, controllers.getProducts);
router.post('/products', authMiddleware, authorizeRoles('ADMIN', 'MANAGER'), controllers.createProduct);

// Order routes
router.get('/orders', authMiddleware, controllers.getOrders);
router.post('/orders', authMiddleware, controllers.createOrder);

// Tracking routes
router.get('/trackings', authMiddleware, controllers.getTrackings);
router.post('/trackings', authMiddleware, controllers.createTracking);

// Auth routes (public)
router.post('/auth/register', controllers.register);
router.post('/auth/login', controllers.login);

module.exports = router;
