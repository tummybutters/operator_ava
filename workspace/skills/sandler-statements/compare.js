// Usage:
//   node skills/sandler-statements/compare.js [current YYYY-MM] [prior YYYY-MM]
//
// Loads workspace/data/statements/*.json and writes a markdown comparison report.
const fs = require('fs');
const path = require('path');

function makeKey(item) {
  return [
    item.customer || '',
    item.provider || '',
    item.account_number || '',
    item.address || '',
    item.provider_identifier || '',
    item.product || '',
    item.commission_type || ''
  ].join('|');
}

function sortWithinKey(a, b) {
  const aInvoice = a.invoice_date || '';
  const bInvoice = b.invoice_date || '';
  if (aInvoice !== bInvoice) return aInvoice.localeCompare(bInvoice);

  const aNet = a.net_billed || 0;
  const bNet = b.net_billed || 0;
  if (aNet !== bNet) return aNet - bNet;

  const aCommission = a.agent_commission || 0;
  const bCommission = b.agent_commission || 0;
  if (aCommission !== bCommission) return aCommission - bCommission;

  return (a.line_number || 0) - (b.line_number || 0);
}

function dollars(value) {
  const sign = value >= 0 ? '' : '-';
  return `${sign}$${Math.abs(value).toFixed(2)}`;
}

function loadMonth(label) {
  const filePath = path.resolve(__dirname, `../../data/statements/${label}.json`);
  if (!fs.existsSync(filePath)) {
    throw new Error(`Statement snapshot not found: ${filePath}`);
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function monthLabels(args) {
  const now = new Date();
  const currentDefault = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  const priorDate = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const priorDefault = `${priorDate.getFullYear()}-${String(priorDate.getMonth() + 1).padStart(2, '0')}`;

  return {
    current: args[2] || currentDefault,
    prior: args[3] || priorDefault
  };
}

function totalFor(items, field) {
  return items.reduce((sum, item) => sum + (item[field] || 0), 0);
}

function markdownTable(headers, rows) {
  const headerLine = `| ${headers.join(' | ')} |`;
  const divider = `|${headers.map(() => '---').join('|')}|`;
  const body = rows.map(row => `| ${row.join(' | ')} |`).join('\n');
  return `${headerLine}\n${divider}\n${body}`;
}

function main() {
  const { current, prior } = monthLabels(process.argv);
  const currentData = loadMonth(current);
  const priorData = loadMonth(prior);

  const currentMap = new Map();
  for (const item of currentData.line_items) {
    const key = makeKey(item);
    const bucket = currentMap.get(key) || [];
    bucket.push(item);
    currentMap.set(key, bucket);
  }

  const priorMap = new Map();
  for (const item of priorData.line_items) {
    const key = makeKey(item);
    const bucket = priorMap.get(key) || [];
    bucket.push(item);
    priorMap.set(key, bucket);
  }

  const added = [];
  const removed = [];
  const commissionChanged = [];
  const netChanged = [];
  let unchanged = 0;

  const allKeys = new Set([...currentMap.keys(), ...priorMap.keys()]);
  for (const key of allKeys) {
    const currentItems = [...(currentMap.get(key) || [])].sort(sortWithinKey);
    const priorItems = [...(priorMap.get(key) || [])].sort(sortWithinKey);
    const sharedCount = Math.min(currentItems.length, priorItems.length);

    for (let index = 0; index < sharedCount; index += 1) {
      const currentItem = currentItems[index];
      const priorItem = priorItems[index];
      const commissionDelta = currentItem.agent_commission - priorItem.agent_commission;
      const netDelta = currentItem.net_billed - priorItem.net_billed;

      if (Math.abs(commissionDelta) > 0.005) {
        commissionChanged.push({ currentItem, priorItem, commissionDelta, netDelta });
        continue;
      }

      if (Math.abs(netDelta) > 0.005) {
        netChanged.push({ currentItem, priorItem, netDelta });
        continue;
      }

      unchanged += 1;
    }

    if (currentItems.length > sharedCount) {
      added.push(...currentItems.slice(sharedCount));
    }

    if (priorItems.length > sharedCount) {
      removed.push(...priorItems.slice(sharedCount));
    }
  }

  commissionChanged.sort((a, b) => Math.abs(b.commissionDelta) - Math.abs(a.commissionDelta));
  netChanged.sort((a, b) => Math.abs(b.netDelta) - Math.abs(a.netDelta));

  const reportLines = [];
  reportLines.push('## Month-Over-Month Comparison');
  reportLines.push(`**${prior} -> ${current}**`);
  reportLines.push('');
  reportLines.push(markdownTable(
    ['Metric', prior, current, 'Delta'],
    [
      ['Line Items', String(priorData.total_items || priorData.line_items.length), String(currentData.total_items || currentData.line_items.length), String((currentData.total_items || currentData.line_items.length) - (priorData.total_items || priorData.line_items.length))],
      ['Net Billed', dollars(totalFor(priorData.line_items, 'net_billed')), dollars(totalFor(currentData.line_items, 'net_billed')), dollars(totalFor(currentData.line_items, 'net_billed') - totalFor(priorData.line_items, 'net_billed'))],
      ['Commissions', dollars(totalFor(priorData.line_items, 'agent_commission')), dollars(totalFor(currentData.line_items, 'agent_commission')), dollars(totalFor(currentData.line_items, 'agent_commission') - totalFor(priorData.line_items, 'agent_commission'))]
    ]
  ));
  reportLines.push('');

  if (added.length) {
    reportLines.push(`### New This Month (${added.length})`);
    reportLines.push(markdownTable(
      ['Customer', 'Acct #', 'Product', 'Net Billed', 'Commission'],
      added.map(item => [item.customer, item.account_number, item.product, dollars(item.net_billed), dollars(item.agent_commission)])
    ));
    reportLines.push('');
  }

  if (removed.length) {
    reportLines.push(`### Removed This Month (${removed.length})`);
    reportLines.push(markdownTable(
      ['Customer', 'Acct #', 'Product', 'Prior Net', 'Prior Commission'],
      removed.map(item => [item.customer, item.account_number, item.product, dollars(item.net_billed), dollars(item.agent_commission)])
    ));
    reportLines.push('');
  }

  if (commissionChanged.length) {
    reportLines.push(`### Commission Changed (${commissionChanged.length})`);
    reportLines.push(markdownTable(
      ['Customer', 'Acct #', 'Product', 'Prior', 'Current', 'Delta'],
      commissionChanged.map(({ currentItem, priorItem, commissionDelta }) => [
        currentItem.customer,
        currentItem.account_number,
        currentItem.product,
        dollars(priorItem.agent_commission),
        dollars(currentItem.agent_commission),
        dollars(commissionDelta)
      ])
    ));
    reportLines.push('');
  }

  if (netChanged.length) {
    reportLines.push(`### Net Billed Changed (${netChanged.length})`);
    reportLines.push(markdownTable(
      ['Customer', 'Acct #', 'Product', 'Prior', 'Current', 'Delta'],
      netChanged.map(({ currentItem, priorItem, netDelta }) => [
        currentItem.customer,
        currentItem.account_number,
        currentItem.product,
        dollars(priorItem.net_billed),
        dollars(currentItem.net_billed),
        dollars(netDelta)
      ])
    ));
    reportLines.push('');
  }

  reportLines.push(`### Unchanged: ${unchanged} items`);
  reportLines.push('');

  const report = `${reportLines.join('\n')}\n`;
  const outputPath = path.resolve(__dirname, `../../data/statements/compare-${prior}-vs-${current}.md`);
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, report);

  process.stdout.write(report);
  console.log(`Report saved to ${outputPath}`);
}

try {
  main();
} catch (error) {
  console.error(error.message || String(error));
  process.exit(1);
}
