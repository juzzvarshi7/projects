const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

const dbPath = path.join(__dirname, 'donation_platform.db');
let db;

function initializeDatabase() {
  return new Promise((resolve, reject) => {
    db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('Error opening database:', err);
        reject(err);
      } else {
        console.log('Connected to SQLite database');
        createTables()
          .then(() => {
            console.log('Database initialized successfully');
            resolve(db);
          })
          .catch(reject);
      }
    });
  });
}

function createTables() {
  return new Promise((resolve, reject) => {
    const tables = [
      // Users table
      `CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT DEFAULT 'student' CHECK(role IN ('student', 'admin')),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,
      
      // Items table
      `CREATE TABLE IF NOT EXISTS items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        condition TEXT NOT NULL CHECK(condition IN ('new', 'like-new', 'good', 'fair')),
        quantity INTEGER NOT NULL DEFAULT 1,
        expiry_date DATE,
        photo_url TEXT,
        location TEXT NOT NULL,
        donor_id TEXT NOT NULL,
        status TEXT DEFAULT 'available' CHECK(status IN ('available', 'claimed', 'completed')),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(donor_id) REFERENCES users(id)
      )`,
      
      // Claims table
      `CREATE TABLE IF NOT EXISTS claims (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        claimer_id TEXT NOT NULL,
        claim_code TEXT UNIQUE NOT NULL,
        status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'confirmed', 'completed')),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(item_id) REFERENCES items(id),
        FOREIGN KEY(claimer_id) REFERENCES users(id)
      )`,
      
      // Money box table
      `CREATE TABLE IF NOT EXISTS money_box (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('donation', 'withdrawal')),
        user_id TEXT NOT NULL,
        reason TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )`,
      
      // Vouchers table
      `CREATE TABLE IF NOT EXISTS vouchers (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        donor_id TEXT NOT NULL,
        claimer_id TEXT,
        status TEXT DEFAULT 'available' CHECK(status IN ('available', 'claimed', 'used')),
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(donor_id) REFERENCES users(id),
        FOREIGN KEY(claimer_id) REFERENCES users(id)
      )`
    ];

    let completed = 0;
    const total = tables.length;

    tables.forEach((sql, index) => {
      db.run(sql, (err) => {
        if (err) {
          console.error(`Error creating table ${index}:`, err);
          reject(err);
          return;
        }
        
        completed++;
        if (completed === total) {
          createAdminUser()
            .then(() => {
              console.log('All tables created successfully');
              resolve();
            })
            .catch(reject);
        }
      });
    });
  });
}

async function createAdminUser() {
  return new Promise(async (resolve, reject) => {
    const adminEmail = 'admin@college.edu';
    const adminPassword = 'admin123';
    
    db.get('SELECT id FROM users WHERE email = ?', [adminEmail], async (err, row) => {
      if (err) {
        console.error('Error checking admin user:', err);
        reject(err);
        return;
      }
      
      if (!row) {
        try {
          const hashedPassword = await bcrypt.hash(adminPassword, 10);
          const adminId = uuidv4();
          
          db.run(
            'INSERT INTO users (id, name, email, password_hash, role) VALUES (?, ?, ?, ?, ?)',
            [adminId, 'Admin User', adminEmail, hashedPassword, 'admin'],
            (err) => {
              if (err) {
                console.error('Error creating admin user:', err);
                reject(err);
              } else {
                console.log('Admin user created successfully');
                console.log('Admin credentials: admin@college.edu / admin123');
                resolve();
              }
            }
          );
        } catch (error) {
          console.error('Error hashing admin password:', error);
          reject(error);
        }
      } else {
        console.log('Admin user already exists');
        resolve();
      }
    });
  });
}

function getDatabase() {
  if (!db) {
    throw new Error('Database not initialized. Call initializeDatabase() first.');
  }
  return db;
}

module.exports = { initializeDatabase, getDatabase };