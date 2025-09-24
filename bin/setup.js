#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Run the postinstall script which handles setup
const postinstallPath = path.join(__dirname, '..', 'scripts', 'postinstall.js');

if (fs.existsSync(postinstallPath)) {
  try {
    require(postinstallPath);
  } catch (error) {
    console.error('Setup failed:', error.message);
    process.exit(1);
  }
} else {
  console.error('Setup script not found');
  process.exit(1);
}