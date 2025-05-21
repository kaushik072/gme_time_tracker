const express = require('express');
const router = express.Router();
const puppeteer = require('puppeteer');
const activities = require('../activities');
const path = require('path');
const fs = require('fs');
const QuickChart = require('quickchart-js');

// Helper to format duration in "Xh Ym"
function formatDuration(minutes) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return `${h > 0 ? h + 'h ' : ''}${m > 0 ? m + 'm' : h === 0 ? '0m' : ''}`.trim();
}

// Helper to format date as yyyy-MM-dd
function formatDate(dateStr) {
  const d = new Date(dateStr);
  return d.toISOString().slice(0, 10);
}

function chunkArray(array, size) {
  const result = [];
  for (let i = 0; i < array.length; i += size) {
    result.push(array.slice(i, i + size));
  }
  return result;
}

router.get('/getpdf', async (req, res) => {
  try {
    // User details (sample, can be replaced with req.body)
    const user = req.body && Object.keys(req.body).length > 0
      ? req.body
      : { Name: "John Doe", Email: "john@example.com", Department: "Medical Education", Role: "Resident" };

    // Chart data
    const chartTotals = {};
    for (const a of activities) {
      chartTotals[a.activityType] = (chartTotals[a.activityType] || 0) + a.durationMinutes;
    }

    // Create chart using QuickChart
    const chart = new QuickChart();
    chart
      .setWidth(600)
      .setHeight(600)
      .setConfig({
        type: 'doughnut',
        data: {
          labels: Object.keys(chartTotals),
          datasets: [{
            backgroundColor: [
              '#4A90E2', '#D0021B', '#F5A623', '#7ED321', '#50E3C2', '#B8E986'
            ],
            data: Object.values(chartTotals)
          }]
        },
        options: {
          layout: {
            padding: {
              top: 25
            }
          },
          plugins: {
            legend: {
              display: true,
              position: 'bottom',
              labels: {
                boxWidth: 40,
                boxHeight: 40,
                padding: 20,
                usePointStyle: true
              }
            },
            datalabels: {
              display: true,
              color: '#222',
              font: { weight: 'bold', size: 18 },
              padding: 8,
              borderRadius: 6,
              backgroundColor: 'rgba(255,255,255,0.8)',
              formatter: function(value) {
                const h = Math.floor(value / 60);
                const m = value % 60;
                return `${h > 0 ? h + 'h ' : ''}${m > 0 ? m + 'm' : h === 0 ? '0m' : ''}`.trim();
              }
            }
          }
        }
      });

    const chartImage = await chart.getShortUrl();

    // Logo as base64 (for embedding in HTML)
    const logoPath = path.join(__dirname, '../logo.png');
    let logoBase64 = '';
    if (fs.existsSync(logoPath)) {
      logoBase64 = fs.readFileSync(logoPath).toString('base64');
    }

    // Table rows, chunked for pagination
    const tableChunks = chunkArray(activities, 20);

    // Table HTML for each page
    const tablePages = tableChunks.map((chunk, pageIdx) => `
      <div class="pagebreak"></div>
      <div class="header">
        <div>
          <div class="title">Time Tracking Report</div>
          <div class="subtitle">Generated on: ${new Date().toLocaleString()}</div>
        </div>
        ${logoBase64 ? `<img src="data:image/png;base64,${logoBase64}" alt="Logo" style="height:60px;">` : ''}
      </div>
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Date</th>
              <th>Activity Name</th>
              <th>Duration</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            ${chunk.map((a, i) => `
              <tr>
                <td>${pageIdx * 20 + i + 1}</td>
                <td>${formatDate(a.date)}</td>
                <td>${a.activityType}</td>
                <td>${formatDuration(a.durationMinutes)}</td>
                <td>${a.notes || '-'}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
      <div class="footer">
        © 2025 GME Time Tracker
      </div>
    `).join('');

    // Build HTML dynamically
    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Time Tracking Report</title>
  <style>
    @page { margin: 40px; }
    html, body { height: 100%; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; margin: 0; min-height: 100vh; }
    .header {
      position: fixed;
      top: 40px;
      left: 40px;
      right: 40px;
      height: 80px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      z-index: 10;
      background: #fff;
      border-bottom: 1.5px solid #e0e7ef;
    }
    .title { font-size: 2.2em; font-weight: bold; color: #2a4365; letter-spacing: 0.5px; }
    .subtitle { font-size: 1.1em; color: #888; margin-top: 2px; }
    .user-details { margin: 140px 0 0 0; }
    .main-content {
      display: flex;
      flex-direction: column;
      min-height: calc(100vh - 220px);
      justify-content: flex-start;
    }
    .chart-row {
      display: flex;
      justify-content: center;
      align-items: center;
      margin-top: 32px;
      min-height: 520px;
      height: 520px;
    }
    .chart-section {
      flex: 1;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100%;
    }
    .table-container { margin-top: 140px; }
    table { width: 100%; border-collapse: collapse; margin-top: 0; }
    th, td { border: 1px solid #ccc; padding: 10px; font-size: 1.05em; }
    th { background: #f0f0f0; font-weight: 600; color: #2a4365; }
    tr:nth-child(even) { background: #f9f9f9; }
    .footer {
      position: fixed;
      left: 0;
      right: 0;
      bottom: 20px;
      text-align: center;
      color: #888;
      font-size: 0.95em;
      background: #fff;
      letter-spacing: 0.5px;
    }
    .pagebreak { page-break-before: always; }
    @media print {
      .header { position: fixed; }
      .footer { position: fixed; }
    }
  </style>
</head>
<body>
  <!-- First Page -->
  <div class="header">
    <div>
      <div class="title">Time Tracking Report</div>
      <div class="subtitle">Generated on: ${new Date().toLocaleString()}</div>
    </div>
    ${logoBase64 ? `<img src="data:image/png;base64,${logoBase64}" alt="Logo" style="height:60px;">` : ''}
  </div>
  <div class="main-content">
    <div class="user-details">
      <div style="display: flex; flex-wrap: wrap; background: #f8fafc; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1.5px solid #e0e7ef; padding: 20px 24px;">
        <div style="flex: 1 1 220px; min-width: 220px;">
          <div style='margin-bottom: 12px;'><span style='font-weight:600;color:#2a4365;'>Name:</span> <span style='color:#222;'>${user.Name}</span></div>
          <div style='margin-bottom: 12px;'><span style='font-weight:600;color:#2a4365;'>Email:</span> <span style='color:#222;'>${user.Email}</span></div>
        </div>
        <div style="flex: 1 1 220px; min-width: 220px;">
          <div style='margin-bottom: 12px;'><span style='font-weight:600;color:#2a4365;'>Department:</span> <span style='color:#222;'>${user.Department}</span></div>
          <div style='margin-bottom: 12px;'><span style='font-weight:600;color:#2a4365;'>Role:</span> <span style='color:#222;'>${user.Role}</span></div>
        </div>
      </div>
    </div>
    <div class="chart-row">
      <div class="chart-section">
        <img src="${chartImage}" style="max-width:520px;max-height:520px;">
      </div>
    </div>
  </div>
  <div class="footer">
    © 2025 GME Time Tracker
  </div>
  <!-- Table Pages -->
  ${tablePages}
</body>
</html>
`;

    // Render PDF with Puppeteer
    const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle0' });
    const pdfBuffer = await page.pdf({
      format: 'A4',
      printBackground: true,
      margin: { top: 40, bottom: 40, left: 40, right: 40 }
    });
    await browser.close();

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename=activity_report.pdf');
    res.end(pdfBuffer);
  } catch (error) {
    console.error('Error generating PDF:', error);
    res.status(500).json({ error: 'Failed to generate PDF' });
  }
});

module.exports = router; 