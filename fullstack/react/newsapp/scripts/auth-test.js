// Simple Node script to register then login and print responses
// Usage: node scripts/auth-test.js

async function run() {
  const base = 'http://localhost:5000/api/auth';
  const ts = Date.now();
  const email = `auto+${ts}@example.com`;
  const name = 'Auto Tester';
  const password = 'Passw0rd!';

  const fetchOpts = (body) => ({
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Origin': 'http://localhost:5174' },
    body: JSON.stringify(body),
  });

  try {
    console.log('=> Registering', email);
    const regRes = await fetch(`${base}/register`, fetchOpts({ name, email, password }));
    const regText = await regRes.text();
    console.log('REGISTER HTTP', regRes.status);
    try { console.log('REGISTER BODY', JSON.parse(regText)); } catch { console.log('REGISTER BODY', regText); }

    console.log('\n=> Logging in');
    const loginRes = await fetch(`${base}/login`, fetchOpts({ email, password }));
    const loginText = await loginRes.text();
    console.log('LOGIN HTTP', loginRes.status);
    try { console.log('LOGIN BODY', JSON.parse(loginText)); } catch { console.log('LOGIN BODY', loginText); }

    if (loginRes.ok) {
      const data = JSON.parse(loginText);
      if (data.token) console.log('\nToken received (truncated):', data.token.slice(0, 40) + '...');
    }
  } catch (err) {
    console.error('Error during test:', err);
  }
}

// Node >=18 has global fetch. If not available, show an error.
if (typeof fetch !== 'function') {
  console.error('Global fetch is not available in this Node runtime. Use Node 18+ or run in PowerShell/curl.');
  process.exit(1);
}

run();
