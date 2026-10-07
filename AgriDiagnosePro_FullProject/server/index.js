// server/index.js
const express = require('express');
const path = require('path');
const fs = require('fs');
const routes = require('./routes');
const { connect } = require('./db');
require('dotenv').config();

const app = express();
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ensure uploads dir
const UP = path.join(__dirname, 'uploads');
if (!fs.existsSync(UP)) fs.mkdirSync(UP);
app.use('/uploads', express.static(UP));

app.use(routes);

const PORT = process.env.PORT || 3001;
connect().then(()=>{
  app.listen(PORT, ()=> console.log('Server listening on', PORT));
});
