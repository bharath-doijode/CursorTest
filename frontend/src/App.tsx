import React, { useState } from 'react';
import type { ReactNode, FormEvent } from 'react';
import './App.css';

// Error Boundary for robust error handling
class ErrorBoundary extends React.Component<{ children: ReactNode }, { hasError: boolean }> {
  constructor(props: { children: ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }
  static getDerivedStateFromError() { return { hasError: true }; }
  componentDidCatch(error: any, info: any) { console.error('ErrorBoundary caught:', error, info); }
  render() {
    if (this.state.hasError) return <div style={{ color: 'red' }}>Something went wrong. Please reload the page.</div>;
    return this.props.children;
  }
}

// Backend API base URL
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:4000/api/v1';

// Entity tabs
const TABS = ['Suppliers', 'Products', 'Orders', 'Tracking'];

function App() {
  // Auth state
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [role, setRole] = useState('USER');
  const [token, setToken] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showRegister, setShowRegister] = useState(false);

  // Tab state
  const [tab, setTab] = useState('Suppliers');

  // Entity state (no type arguments for useState)
  const [suppliers, setSuppliers] = useState([]);
  const [products, setProducts] = useState([]);
  const [orders, setOrders] = useState([]);
  const [trackings, setTrackings] = useState([]);

  // Form state for each entity
  const [supplierForm, setSupplierForm] = useState({ name: '', contact: '', address: '' });
  const [productForm, setProductForm] = useState({ name: '', description: '', quantity: 0, supplierId: '' });
  const [orderForm, setOrderForm] = useState({ productId: '', quantity: 1, status: 'pending' });
  const [trackingForm, setTrackingForm] = useState({ orderId: '', status: 'in transit', location: '' });

  // Per-entity error/success
  const [entityError, setEntityError] = useState('');
  const [entitySuccess, setEntitySuccess] = useState('');

  // Login handler
  const handleLogin = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault(); setError(null); setSuccess(null);
    try {
      const res = await fetch(`${API_URL}/auth/login`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      if (!res.ok) throw new Error('Login failed');
      const data = await res.json();
      setToken(data.token); setError(null); setSuccess('Login successful!');
    } catch (err: any) { setError(err.message || 'Login error'); }
  };

  // Registration handler
  const handleRegister = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault(); setError(null); setSuccess(null);
    try {
      const res = await fetch(`${API_URL}/auth/register`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, name, role })
      });
      if (!res.ok) { const data = await res.json(); throw new Error(data.error || 'Registration failed'); }
      setSuccess('Registration successful! You can now log in.'); setShowRegister(false);
      setEmail(''); setPassword(''); setName(''); setRole('USER');
    } catch (err: any) { setError(err.message || 'Registration error'); }
  };

  // Generic fetch helper
  const apiFetch = async (url: string, options: any = {}) => {
    setEntityError(''); setEntitySuccess('');
    const headers = { ...(options.headers || {}), Authorization: `Bearer ${token}` };
    const res = await fetch(url, { ...options, headers });
    if (!res.ok) throw new Error((await res.json()).error || 'API error');
    return res.json();
  };

  // CRUD: Suppliers
  const fetchSuppliers = async () => {
    try { setSuppliers(await apiFetch(`${API_URL}/suppliers`)); setEntitySuccess('Fetched suppliers.'); }
    catch (err: any) { setEntityError(err.message); }
  };
  const createSupplier = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      await apiFetch(`${API_URL}/suppliers`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(supplierForm)
      });
      setEntitySuccess('Supplier created!'); setSupplierForm({ name: '', contact: '', address: '' }); fetchSuppliers();
    } catch (err: any) { setEntityError(err.message); }
  };

  // CRUD: Products
  const fetchProducts = async () => {
    try { setProducts(await apiFetch(`${API_URL}/products`)); setEntitySuccess('Fetched products.'); }
    catch (err: any) { setEntityError(err.message); }
  };
  const createProduct = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      await apiFetch(`${API_URL}/products`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...productForm, supplierId: Number(productForm.supplierId) })
      });
      setEntitySuccess('Product created!'); setProductForm({ name: '', description: '', quantity: 0, supplierId: '' }); fetchProducts();
    } catch (err: any) { setEntityError(err.message); }
  };

  // CRUD: Orders
  const fetchOrders = async () => {
    try { setOrders(await apiFetch(`${API_URL}/orders`)); setEntitySuccess('Fetched orders.'); }
    catch (err: any) { setEntityError(err.message); }
  };
  const createOrder = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      await apiFetch(`${API_URL}/orders`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...orderForm, productId: Number(orderForm.productId), quantity: Number(orderForm.quantity) })
      });
      setEntitySuccess('Order created!'); setOrderForm({ productId: '', quantity: 1, status: 'pending' }); fetchOrders();
    } catch (err: any) { setEntityError(err.message); }
  };

  // CRUD: Tracking
  const fetchTrackings = async () => {
    try { setTrackings(await apiFetch(`${API_URL}/trackings`)); setEntitySuccess('Fetched tracking records.'); }
    catch (err: any) { setEntityError(err.message); }
  };
  const createTracking = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      await apiFetch(`${API_URL}/trackings`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...trackingForm, orderId: Number(trackingForm.orderId) })
      });
      setEntitySuccess('Tracking record created!'); setTrackingForm({ orderId: '', status: 'in transit', location: '' }); fetchTrackings();
    } catch (err: any) { setEntityError(err.message); }
  };

  // Tab content renderers (no type arguments for arrays)
  const renderTab = () => {
    if (tab === 'Suppliers') {
      return (
        <div>
          <button onClick={fetchSuppliers}>Refresh Suppliers</button>
          <ul>{suppliers.map((s: any) => <li key={s.id}>{s.name} ({s.contact})</li>)}</ul>
          <form onSubmit={createSupplier} style={{ marginTop: 8 }}>
            <input placeholder="Name" value={supplierForm.name} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSupplierForm(f => ({ ...f, name: e.target.value }))} required />
            <input placeholder="Contact" value={supplierForm.contact} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSupplierForm(f => ({ ...f, contact: e.target.value }))} />
            <input placeholder="Address" value={supplierForm.address} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSupplierForm(f => ({ ...f, address: e.target.value }))} />
            <button type="submit">Add Supplier</button>
          </form>
        </div>
      );
    }
    if (tab === 'Products') {
      return (
        <div>
          <button onClick={fetchProducts}>Refresh Products</button>
          <ul>{products.map((p: any) => <li key={p.id}>{p.name} (Qty: {p.quantity})</li>)}</ul>
          <form onSubmit={createProduct} style={{ marginTop: 8 }}>
            <input placeholder="Name" value={productForm.name} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProductForm(f => ({ ...f, name: e.target.value }))} required />
            <input placeholder="Description" value={productForm.description} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProductForm(f => ({ ...f, description: e.target.value }))} />
            <input type="number" placeholder="Quantity" value={productForm.quantity} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProductForm(f => ({ ...f, quantity: Number(e.target.value) }))} required />
            <input placeholder="Supplier ID" value={productForm.supplierId} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProductForm(f => ({ ...f, supplierId: e.target.value }))} required />
            <button type="submit">Add Product</button>
          </form>
        </div>
      );
    }
    if (tab === 'Orders') {
      return (
        <div>
          <button onClick={fetchOrders}>Refresh Orders</button>
          <ul>{orders.map((o: any) => <li key={o.id}>Product ID: {o.productId}, Qty: {o.quantity}, Status: {o.status}</li>)}</ul>
          <form onSubmit={createOrder} style={{ marginTop: 8 }}>
            <input placeholder="Product ID" value={orderForm.productId} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setOrderForm(f => ({ ...f, productId: e.target.value }))} required />
            <input type="number" placeholder="Quantity" value={orderForm.quantity} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setOrderForm(f => ({ ...f, quantity: Number(e.target.value) }))} required />
            <select value={orderForm.status} onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setOrderForm(f => ({ ...f, status: e.target.value }))}>
              <option value="pending">Pending</option>
              <option value="shipped">Shipped</option>
              <option value="delivered">Delivered</option>
            </select>
            <button type="submit">Add Order</button>
          </form>
        </div>
      );
    }
    if (tab === 'Tracking') {
      return (
        <div>
          <button onClick={fetchTrackings}>Refresh Tracking</button>
          <ul>{trackings.map((t: any) => <li key={t.id}>Order ID: {t.orderId}, Status: {t.status}, Location: {t.location}</li>)}</ul>
          <form onSubmit={createTracking} style={{ marginTop: 8 }}>
            <input placeholder="Order ID" value={trackingForm.orderId} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setTrackingForm(f => ({ ...f, orderId: e.target.value }))} required />
            <input placeholder="Location" value={trackingForm.location} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setTrackingForm(f => ({ ...f, location: e.target.value }))} />
            <select value={trackingForm.status} onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setTrackingForm(f => ({ ...f, status: e.target.value }))}>
              <option value="in transit">In Transit</option>
              <option value="delivered">Delivered</option>
            </select>
            <button type="submit">Add Tracking</button>
          </form>
        </div>
      );
    }
    return null;
  };

  return (
    <ErrorBoundary>
      <div className="App">
        <header className="App-header">
          <h1>Supply Chain Management (Demo)</h1>
          {!token ? (
            showRegister ? (
              <form onSubmit={handleRegister} style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                <input type="email" placeholder="Email" value={email} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)} required />
                <input type="password" placeholder="Password" value={password} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)} required />
                <input type="text" placeholder="Name" value={name} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setName(e.target.value)} />
                <select value={role} onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setRole(e.target.value)}>
                  <option value="USER">User</option>
                  <option value="SUPPLIER">Supplier</option>
                  <option value="MANAGER">Manager</option>
                  <option value="ADMIN">Admin</option>
                </select>
                <button type="submit">Register</button>
                <button type="button" onClick={() => { setShowRegister(false); setError(null); setSuccess(null); }}>Back to Login</button>
              </form>
            ) : (
              <>
                <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  <input type="email" placeholder="Email" value={email} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)} required />
                  <input type="password" placeholder="Password" value={password} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)} required />
                  <button type="submit">Login</button>
                </form>
                <button style={{ marginTop: 8 }} onClick={() => { setShowRegister(true); setError(null); setSuccess(null); }}>Register</button>
              </>
            )
          ) : (
            <>
              {/* Entity Tabs */}
              <nav style={{ marginBottom: 16 }}>
                {TABS.map(t => (
                  <button key={t} onClick={() => { setTab(t); setEntityError(''); setEntitySuccess(''); }} style={{ fontWeight: tab === t ? 'bold' : 'normal', marginRight: 8 }}>{t}</button>
                ))}
                <button onClick={() => setToken(null)} style={{ float: 'right' }}>Logout</button>
              </nav>
              {/* Entity Content */}
              <div style={{ minHeight: 200, width: 350 }}>{renderTab()}</div>
              {entityError && <div style={{ color: 'red' }}>{entityError}</div>}
              {entitySuccess && <div style={{ color: 'green' }}>{entitySuccess}</div>}
            </>
          )}
          {error && <div style={{ color: 'red' }}>{error}</div>}
          {success && <div style={{ color: 'green' }}>{success}</div>}
        </header>
      </div>
    </ErrorBoundary>
  );
}

export default App;
