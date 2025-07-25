// controllers.js - Business logic for supply chain entities
// Each function handles a specific API operation and uses Prisma for DB access.

const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { sendEmail } = require('./utils');

/** SUPPLIER CONTROLLERS **/

/**
 * Get all suppliers
 */
async function getSuppliers(req, res, next) {
  try {
    const suppliers = await prisma.supplier.findMany();
    res.json(suppliers);
  } catch (err) {
    next(err);
  }
}

/**
 * Create a new supplier
 */
async function createSupplier(req, res, next) {
  try {
    const { name, contact, address } = req.body;
    const supplier = await prisma.supplier.create({
      data: { name, contact, address }
    });
    res.status(201).json(supplier);
  } catch (err) {
    next(err);
  }
}

/** PRODUCT CONTROLLERS **/

/**
 * Get all products
 */
async function getProducts(req, res, next) {
  try {
    const products = await prisma.product.findMany({ include: { supplier: true } });
    res.json(products);
  } catch (err) {
    next(err);
  }
}

/**
 * Create a new product
 */
async function createProduct(req, res, next) {
  try {
    const { name, description, quantity, supplierId } = req.body;
    const product = await prisma.product.create({
      data: { name, description, quantity, supplierId }
    });
    res.status(201).json(product);
  } catch (err) {
    next(err);
  }
}

/** ORDER CONTROLLERS **/

/**
 * Get all orders
 */
async function getOrders(req, res, next) {
  try {
    const orders = await prisma.order.findMany({ include: { product: true, tracking: true } });
    res.json(orders);
  } catch (err) {
    next(err);
  }
}

/**
 * Create a new order
 */
async function createOrder(req, res, next) {
  try {
    const { productId, quantity, status } = req.body;
    const order = await prisma.order.create({
      data: { productId, quantity, status }
    });
    // Send email notification if SMTP is configured
    if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS) {
      try {
        await sendEmail({
          to: process.env.NOTIFY_EMAIL || 'admin@example.com',
          subject: 'New Order Created',
          text: `A new order (ID: ${order.id}) was created for product ID ${productId} (quantity: ${quantity}).`
        });
      } catch (emailErr) {
        console.error('Failed to send order notification email:', emailErr);
      }
    }
    res.status(201).json(order);
  } catch (err) {
    next(err);
  }
}

/** TRACKING CONTROLLERS **/

/**
 * Get all tracking records
 */
async function getTrackings(req, res, next) {
  try {
    const trackings = await prisma.tracking.findMany({ include: { order: true } });
    res.json(trackings);
  } catch (err) {
    next(err);
  }
}

/**
 * Create a new tracking record
 */
async function createTracking(req, res, next) {
  try {
    const { orderId, status, location } = req.body;
    const tracking = await prisma.tracking.create({
      data: { orderId, status, location }
    });
    res.status(201).json(tracking);
  } catch (err) {
    next(err);
  }
}

/** USER AUTH CONTROLLERS **/

/**
 * Register a new user
 */
async function register(req, res, next) {
  try {
    const { email, password, name, role } = req.body;
    // Check if user already exists
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) return res.status(409).json({ error: 'User already exists' });
    // Hash password
    const hashed = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: { email, password: hashed, name, role }
    });
    res.status(201).json({ id: user.id, email: user.email, name: user.name, role: user.role });
  } catch (err) {
    next(err);
  }
}

/**
 * Login a user and issue JWT
 */
async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) return res.status(401).json({ error: 'Invalid credentials' });
    // Issue JWT
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET || 'changeme',
      { expiresIn: '1d' }
    );
    res.json({ token, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getSuppliers,
  createSupplier,
  getProducts,
  createProduct,
  getOrders,
  createOrder,
  getTrackings,
  createTracking,
  register,
  login
};
