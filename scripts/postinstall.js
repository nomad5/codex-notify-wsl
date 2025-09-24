#!/usr/bin/env node

const os = require('os');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Check if running in WSL
function isWSL() {
  try {
    const version = fs.readFileSync('/proc/version', 'utf8');
    return version.toLowerCase().includes('microsoft');
  } catch {
    return false;
  }
}

// Check if command exists
function commandExists(cmd) {
  try {
    execSync(`which ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

// Check for Windows tools
function checkWindowsTools() {
  const tools = {
    burnttoast: false,
    snoretoast: false,
    msg: false
  };

  try {
    const result = execSync('powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Module -ListAvailable -Name BurntToast"', { encoding: 'utf8' });
    tools.burnttoast = result.includes('BurntToast');
  } catch {}

  tools.snoretoast = fs.existsSync('/mnt/c/Windows/System32/snoretoast.exe');
  tools.msg = commandExists('msg.exe');

  return tools;
}

// Main setup
function setup() {
  console.log('Codex Notify WSL - Post-install Setup');
  console.log('=====================================\n');

  // Check environment
  if (!process.env.GITHUB_ACTIONS && !isWSL()) {
    console.error('Error: This package must be installed in WSL');
    console.log('Please install from within Windows Subsystem for Linux');
    process.exit(1);
  }

  if (!commandExists('codex')) {
    console.error('Warning: Codex not found in PATH');
    console.log('Install Codex first: npm install -g @openai/codex');
  }

  // Check Windows notification tools
  console.log('Checking Windows notification tools...');
  const tools = checkWindowsTools();

  if (tools.burnttoast) {
    console.log('✓ BurntToast found');
  } else {
    console.log('! BurntToast not installed (recommended)');
    console.log('  Install: Install-Module -Name BurntToast -Force');
  }

  if (tools.snoretoast) {
    console.log('✓ SnoreToast found');
  } else {
    console.log('! SnoreToast not installed');
  }

  if (!tools.burnttoast && !tools.snoretoast) {
    console.log('\nWarning: No notification tools found');
    console.log('Install BurntToast for best experience');
  }

  // Create config directory
  const configDir = path.join(os.homedir(), '.codex');
  if (!fs.existsSync(configDir)) {
    fs.mkdirSync(configDir, { recursive: true });
  }

  // Copy config template if needed
  const configFile = path.join(configDir, 'notify.env');
  if (!fs.existsSync(configFile)) {
    const template = path.join(__dirname, '..', 'config', '.env.example');
    if (fs.existsSync(template)) {
      fs.copyFileSync(template, configFile);
      console.log('✓ Created config file: ~/.codex/notify.env');
    }
  }

  // Copy notify.py for Codex hooks
  const notifyPy = path.join(__dirname, '..', 'lib', 'notify.py');
  if (fs.existsSync(notifyPy)) {
    const dest = path.join(configDir, 'notify.py');
    fs.copyFileSync(notifyPy, dest);
    fs.chmodSync(dest, '755');
    console.log('✓ Installed Codex hook: ~/.codex/notify.py');
  }

  // Setup shell aliases
  const shellRc = process.env.SHELL?.includes('zsh')
    ? path.join(os.homedir(), '.zshrc')
    : path.join(os.homedir(), '.bashrc');

  const aliases = `
# Codex Notify
alias codex="npx codex-notify"
alias codex-real="$(which codex)"
alias codex-silent="CODEX_NOTIFY_ENABLED=false codex"
`;

  try {
    const rcContent = fs.readFileSync(shellRc, 'utf8');
    if (!rcContent.includes('# Codex Notify')) {
      fs.appendFileSync(shellRc, aliases);
      console.log(`✓ Added aliases to ${path.basename(shellRc)}`);
    }
  } catch {
    console.log('! Could not add aliases automatically');
    console.log('  Add these to your shell config:');
    console.log(aliases);
  }

  // Setup Codex config
  const codexConfig = path.join(configDir, 'config.toml');
  if (fs.existsSync(codexConfig)) {
    const content = fs.readFileSync(codexConfig, 'utf8');
    if (!content.includes('notify =')) {
      const hook = `notify = ["python3", "${path.join(configDir, 'notify.py')}"]\n`;
      fs.writeFileSync(codexConfig, hook + content);
      console.log('✓ Added Codex notify hook');
    }
  } else {
    console.log('! Codex config not found');
    console.log('  Add to ~/.codex/config.toml:');
    console.log(`  notify = ["python3", "${path.join(configDir, 'notify.py')}"]`);
  }

  console.log('\nSetup complete!');
  console.log('\nNext steps:');
  console.log('1. Reload shell: source ~/.bashrc');
  console.log('2. Edit config: codex-notify config');
  console.log('3. Test: codex-notify test all');
  console.log('4. Use: codex "your prompt"');

  if (!tools.burnttoast) {
    console.log('\nRecommended:');
    console.log('Install BurntToast: Install-Module -Name BurntToast -Force');
  }
}

// Run setup
if (require.main === module) {
  setup();
}
