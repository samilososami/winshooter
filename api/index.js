const fs   = require('fs');
const path = require('path');

const SCRIPT_RAW_URL =
  'https://raw.githubusercontent.com/samilososami/winshooter/master/winshooter/script.ps1';

module.exports = function handler(req, res) {
  const ua = req.headers['user-agent'] || '';
  const isPowerShell =
    ua.includes('WindowsPowerShell') ||
    ua.includes('PowerShell') ||
    ua.includes('Mozilla/5.0 (Windows NT; Windows NT') /* some PS versions */;

  if (isPowerShell) {
    // irm ... | iex  →  redirect to raw GitHub script
    res.setHeader('Location', SCRIPT_RAW_URL);
    res.status(302).end();
    return;
  }

  // Browser  →  serve landing page
  try {
    const html = fs.readFileSync(path.join(process.cwd(), 'index.html'), 'utf8');
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.setHeader('Cache-Control', 'no-cache');
    res.status(200).send(html);
  } catch (e) {
    res.status(500).send('Error loading page: ' + e.message);
  }
};
