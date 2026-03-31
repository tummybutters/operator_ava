// Usage:
//   node skills/sandler-statements/pull.js [YYYY-MM] --email "user@example.com" --password "secret"
// or:
//   SANDLER_PORTAL_EMAIL=... SANDLER_PORTAL_PASSWORD=... node skills/sandler-statements/pull.js [YYYY-MM]
//
// Saves to workspace/data/statements/YYYY-MM.json
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'https://www.sandlerportal.com';
const STATEMENTS_URL = `${BASE_URL}/statements`;

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function parseMoney(value) {
  return parseFloat(String(value || '0').replace(/[$,\s]/g, '')) || 0;
}

function parseArgs(argv) {
  const args = { month: null, email: process.env.SANDLER_PORTAL_EMAIL || '', password: process.env.SANDLER_PORTAL_PASSWORD || '' };

  for (let i = 2; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token) continue;

    if (/^\d{4}-\d{2}$/.test(token) && !args.month) {
      args.month = token;
      continue;
    }

    if (token === '--email') {
      args.email = argv[i + 1] || '';
      i += 1;
      continue;
    }

    if (token === '--password') {
      args.password = argv[i + 1] || '';
      i += 1;
      continue;
    }
  }

  return args;
}

async function scrapeSummary(page) {
  try {
    const rows = await page.$$eval('table:first-of-type tbody tr', trs =>
      trs.map(tr => Array.from(tr.querySelectorAll('td')).map(td => td.textContent.trim()))
    );

    const summary = {};
    for (const row of rows) {
      if (row.length < 4) continue;
      const label = row[0];
      summary[label] = {
        items: parseInt(row[1], 10) || 0,
        net_billed: parseFloat(String(row[2] || '0').replace(/[$,\s]/g, '')) || 0,
        commissions: parseFloat(String(row[3] || '0').replace(/[$,\s]/g, '')) || 0
      };
    }
    return summary;
  } catch {
    return {};
  }
}

async function scrapeLineItems(page) {
  const rows = await page.$$eval('table:last-of-type tbody tr', trs =>
    trs.map(tr => Array.from(tr.querySelectorAll('td')).map(td => td.textContent.trim()))
  );

  const items = [];
  for (const row of rows) {
    if (row.length >= 8 && !row[0].startsWith('Install Date')) {
      items.push({
        customer: row[0],
        provider: row[1],
        account_number: row[2],
        address: row[3],
        commission_type: row[4],
        provider_identifier: row[5] || '',
        net_billed: parseMoney(row[6]),
        agent_commission: parseMoney(row[7]),
        product: '',
        invoice_date: ''
      });
      continue;
    }

    if (row.length >= 5 && items.length > 0) {
      for (const cell of row) {
        if (cell.startsWith('Product') && !cell.startsWith('Product Qty')) {
          items[items.length - 1].product = cell.replace(/^Product\s*/, '');
        }
        if (cell.startsWith('Invoice Date')) {
          items[items.length - 1].invoice_date = cell.replace(/^Invoice Date\s*/, '');
        }
      }
    }
  }

  return items;
}

async function hasNextPage(page) {
  return page.evaluate(() => {
    const next = document.querySelector('a[aria-label*="Page"][rel="next"]');
    return Boolean(next);
  });
}

async function goNextPage(page) {
  const clicked = await page.evaluate(() => {
    const next = document.querySelector('a[aria-label*="Page"][rel="next"]');
    if (!next) return false;
    next.click();
    return true;
  });

  if (!clicked) return false;

  await sleep(1500);
  await page.waitForLoadState('networkidle', { timeout: 10000 }).catch(() => {});
  await sleep(500);
  return true;
}

async function tryExportCsv(page, outputDir, month) {
  const downloadTrigger = await page.evaluate(() => {
    const buttons = Array.from(document.querySelectorAll('a, button'));
    const target = buttons.find(el => /export csv/i.test((el.textContent || '').trim()));
    if (!target) return false;
    target.click();
    return true;
  });

  if (!downloadTrigger) return null;

  const download = await page.waitForEvent('download', { timeout: 5000 }).catch(() => null);
  if (!download) return null;

  const csvPath = path.join(outputDir, `${month}.csv`);
  await download.saveAs(csvPath);
  return csvPath;
}

async function main() {
  const { month, email, password } = parseArgs(process.argv);
  const now = new Date();
  const label = month || `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;

  if (!email || !password) {
    console.error('Missing SandlerPortal credentials. Pass --email/--password or set SANDLER_PORTAL_EMAIL and SANDLER_PORTAL_PASSWORD.');
    process.exit(1);
  }

  const outputDir = path.resolve(__dirname, '../../data/statements');
  fs.mkdirSync(outputDir, { recursive: true });
  const jsonPath = path.join(outputDir, `${label}.json`);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ acceptDownloads: true });
  const page = await context.newPage();

  try {
    console.log(`Pulling SandlerPortal statements for ${label}...`);

    await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 30000 });
    await page.fill('#email', email);
    await page.fill('#password', password);
    await page.locator('button[type="submit"]').filter({ hasText: 'Login' }).click();
    await page.waitForLoadState('networkidle', { timeout: 20000 }).catch(() => {});
    await sleep(1500);

    await page.goto(STATEMENTS_URL, { waitUntil: 'networkidle', timeout: 30000 });
    await sleep(1500);

    const csvPath = await tryExportCsv(page, outputDir, label).catch(() => null);
    const summary = await scrapeSummary(page);

    let lineItems = [];
    let pageNumber = 1;
    while (true) {
      console.log(`Scraping page ${pageNumber}...`);
      lineItems = lineItems.concat(await scrapeLineItems(page));
      if (!(await hasNextPage(page))) break;
      await goNextPage(page);
      pageNumber += 1;
    }

    lineItems = lineItems.map((item, index) => ({ ...item, line_number: index + 1 }));

    const totalNet = lineItems.reduce((sum, item) => sum + item.net_billed, 0);
    const totalCommission = lineItems.reduce((sum, item) => sum + item.agent_commission, 0);

    const payload = {
      pulled_at: new Date().toISOString(),
      month: label,
      source: 'sandlerportal',
      export_csv_path: csvPath,
      total_items: lineItems.length,
      totals: {
        net_billed: totalNet,
        commissions: totalCommission
      },
      summary,
      line_items: lineItems
    };

    fs.writeFileSync(jsonPath, JSON.stringify(payload, null, 2));

    console.log(`Saved ${lineItems.length} items to ${jsonPath}`);
    if (csvPath) console.log(`CSV saved to ${csvPath}`);
    console.log(`Net billed: $${totalNet.toFixed(2)}`);
    console.log(`Commissions: $${totalCommission.toFixed(2)}`);
  } finally {
    await browser.close();
  }
}

main().catch(error => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
