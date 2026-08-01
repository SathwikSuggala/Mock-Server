<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<meta name="description" content="Mock Server Dashboard - Monitor API calls, view top endpoints, and track request statistics."/>
<title>Local Mock Server - Dashboard</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
<style>
  * { font-family: 'Inter', sans-serif; }
  body { background: #0f1117; color: #e0e0e0; }
  .sidebar { width: 230px; min-height: 100vh; background: linear-gradient(180deg, #1a1d2e 0%, #12151f 100%);
             position: fixed; top: 0; left: 0; z-index: 100; border-right: 1px solid #2a2d3e; }
  .sidebar .nav-link { color: #94a3b8; padding: .65rem 1.2rem; border-radius: 8px; margin: 2px 8px;
                       transition: all .2s ease; font-size: .9rem; }
  .sidebar .nav-link:hover { color: #fff; background: rgba(99,102,241,.15); }
  .sidebar .nav-link.active { color: #fff; background: rgba(99,102,241,.25); border-left: 3px solid #6366f1; }
  .sidebar .brand { color: #fff; font-size: 1.1rem; padding: 1.2rem 1.2rem; border-bottom: 1px solid #2a2d3e;
                    font-weight: 600; letter-spacing: .5px; }
  .main-content { margin-left: 230px; padding: 2rem; }
  h1.page-title { font-size: 1.6rem; font-weight: 700; color: #fff; margin-bottom: 1.5rem; }

  /* Stat cards */
  .stat-card { border: 1px solid #2a2d3e; border-radius: 14px; padding: 1.4rem;
               background: linear-gradient(135deg, #1e2235, #252840); transition: transform .2s, box-shadow .2s; }
  .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.4); }
  .stat-card .stat-number { font-size: 2.2rem; font-weight: 700; }
  .stat-card .stat-label { font-size: .78rem; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; }
  .stat-card.primary .stat-number { color: #6366f1; }
  .stat-card.success .stat-number { color: #22c55e; }
  .stat-card.info .stat-number { color: #38bdf8; }
  .stat-card.warning .stat-number { color: #fbbf24; }
  .stat-card.secondary .stat-number { color: #a78bfa; }
  .stat-card.dark .stat-number { font-size: 1.1rem; color: #fb923c; }

  /* Global search */
  .global-search { background: #1e2235; border: 1px solid #2a2d3e; border-radius: 10px;
                   color: #e0e0e0; padding: .6rem 1rem .6rem 2.8rem; width: 320px; }
  .global-search:focus { outline: none; border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); }
  .search-wrapper { position: relative; }
  .search-icon { position: absolute; left: .9rem; top: 50%; transform: translateY(-50%); color: #94a3b8; }

  /* Charts & tables */
  .dark-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 14px; }
  .dark-card .card-header { background: transparent; border-bottom: 1px solid #2a2d3e;
                             font-weight: 600; color: #fff; padding: 1rem 1.2rem; }
  .dark-table { background: transparent; color: #c0c0c0; }
  .dark-table thead th { border-bottom: 1px solid #2a2d3e; color: #94a3b8; font-size: .8rem;
                         text-transform: uppercase; letter-spacing: .8px; }
  .dark-table tbody tr { border-bottom: 1px solid #1e2235; }
  .dark-table tbody tr:hover { background: rgba(99,102,241,.08); cursor: pointer; }
  .dark-table td, .dark-table th { vertical-align: middle; }
  .shortcut-badge { background: rgba(99,102,241,.15); color: #a5b4fc; border-radius: 6px;
                    padding: 2px 8px; font-size: .75rem; cursor: pointer; transition: all .15s; }
  .shortcut-badge:hover { background: rgba(99,102,241,.35); }
  canvas { max-height: 220px; }
</style>
<%@ include file="theme.jsp" %>
</head>
<body>
<div class="sidebar d-flex flex-column">
  <div class="brand"><i class="bi bi-server me-2"></i>Mock Server</div>
  <nav class="nav flex-column mt-2">
    <a href="/dashboard" class="nav-link active"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a>
    <a href="/apis" class="nav-link"><i class="bi bi-list-ul me-2"></i>APIs</a>
    <a href="/scenarios" class="nav-link"><i class="bi bi-diagram-3 me-2"></i>Scenarios</a>
    <a href="/logs" class="nav-link"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy" class="nav-link"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings" class="nav-link"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>

<div class="main-content">
  <!-- Header with search -->
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1 class="page-title mb-0"><i class="bi bi-speedometer2 me-2 text-indigo"></i>Dashboard</h1>
    <div class="search-wrapper">
      <i class="bi bi-search search-icon"></i>
      <input type="text" id="globalSearch" class="global-search" placeholder="Search APIs by name or path..." autocomplete="off"/>
    </div>
  </div>

  <!-- Search results dropdown -->
  <div id="searchResults" class="position-absolute bg-dark border border-secondary rounded-3 shadow-lg" style="width:320px;right:2rem;top:5.5rem;z-index:999;display:none;max-height:300px;overflow-y:auto;"></div>

  <!-- Stat cards -->
  <div class="row g-3 mb-4">
    <div class="col-md-2">
      <div class="stat-card primary">
        <div class="stat-number">${dashboard.totalApis}</div>
        <div class="stat-label"><i class="bi bi-list-ul me-1"></i>Total APIs</div>
      </div>
    </div>
    <div class="col-md-2">
      <div class="stat-card success">
        <div class="stat-number">${dashboard.totalMatchers}</div>
        <div class="stat-label"><i class="bi bi-funnel me-1"></i>Matchers</div>
      </div>
    </div>
    <div class="col-md-2">
      <div class="stat-card info">
        <div class="stat-number">${dashboard.totalResponses}</div>
        <div class="stat-label"><i class="bi bi-reply me-1"></i>Responses</div>
      </div>
    </div>
    <div class="col-md-2">
      <div class="stat-card warning">
        <div class="stat-number">${dashboard.requestsToday}</div>
        <div class="stat-label"><i class="bi bi-calendar-day me-1"></i>Today</div>
      </div>
    </div>
    <div class="col-md-2">
      <div class="stat-card secondary">
        <div class="stat-number">${dashboard.requestsLastHour}</div>
        <div class="stat-label"><i class="bi bi-clock me-1"></i>Last Hour</div>
      </div>
    </div>
    <div class="col-md-2">
      <div class="stat-card dark">
        <div class="stat-number">${empty dashboard.activeScenario ? 'None' : dashboard.activeScenario}</div>
        <div class="stat-label"><i class="bi bi-diagram-3 me-1"></i>Active Scenario</div>
      </div>
    </div>
  </div>

  <!-- Charts + Top APIs row -->
  <div class="row g-3">
    <div class="col-md-7">
      <div class="dark-card">
        <div class="card-header d-flex justify-content-between">
          <span><i class="bi bi-bar-chart me-2"></i>Requests (Last 24h)</span>
          <small class="text-muted" style="font-weight:400;font-size:.8rem;">Auto-refreshes every 60s</small>
        </div>
        <div class="card-body">
          <canvas id="activityChart"></canvas>
        </div>
      </div>
    </div>

    <div class="col-md-5">
      <div class="dark-card h-100">
        <div class="card-header"><i class="bi bi-trophy me-2"></i>Top Called APIs
          <small class="text-muted ms-2" style="font-weight:400;font-size:.8rem;">Click row → view logs</small>
        </div>
        <div class="card-body p-0">
          <table class="table dark-table mb-0">
            <thead><tr><th>Path</th><th>Calls</th><th></th></tr></thead>
            <tbody>
              <c:forEach var="row" items="${dashboard.topCalledApis}">
                <tr onclick="viewLogsFor('${row[0]}')" title="Click to view logs for ${row[0]}">
                  <td class="text-truncate" style="max-width:180px;" title="${row[0]}">
                    <code style="color:#a5b4fc;font-size:.82rem;">${row[0]}</code>
                  </td>
                  <td><span class="badge bg-indigo" style="background:#6366f1!important;">${row[1]}</span></td>
                  <td>
                    <span class="shortcut-badge" onclick="event.stopPropagation();viewLogsFor('${row[0]}')">
                      <i class="bi bi-journal-text me-1"></i>Logs
                    </span>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty dashboard.topCalledApis}">
                <tr><td colspan="3" class="text-center text-muted py-3">No calls recorded yet</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
// Navigate to logs filtered by path
function viewLogsFor(path) {
  window.location.href = '/logs?path=' + encodeURIComponent(path);
}

// Chart.js line chart
let activityChart;
function loadChart() {
  $.getJSON('/dashboard/api/chart-data', function(d) {
    if (activityChart) activityChart.destroy();
    const ctx = document.getElementById('activityChart').getContext('2d');
    activityChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: d.labels,
        datasets: [{
          label: 'Requests',
          data: d.data,
          borderColor: '#6366f1',
          backgroundColor: 'rgba(99,102,241,0.12)',
          borderWidth: 2,
          pointBackgroundColor: '#6366f1',
          pointRadius: 3,
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
          x: { grid: { color: '#2a2d3e' }, ticks: { color: '#94a3b8', maxRotation: 0 } },
          y: { grid: { color: '#2a2d3e' }, ticks: { color: '#94a3b8' }, beginAtZero: true }
        }
      }
    });
  });
}
loadChart();
setInterval(loadChart, 60000);

// Global search
let searchTimer;
$('#globalSearch').on('input', function() {
  clearTimeout(searchTimer);
  const q = $(this).val().trim();
  if (!q) { $('#searchResults').hide(); return; }
  searchTimer = setTimeout(function() {
    $.getJSON('/apis/api/search?q=' + encodeURIComponent(q), function(apis) {
      const $res = $('#searchResults').empty().show();
      if (!apis.length) {
        $res.append('<div class="p-3 text-muted">No results</div>');
        return;
      }
      apis.slice(0,8).forEach(function(api) {
        const badge = api.enabled ? 'success' : 'secondary';
        $res.append(
          '<a href="/apis/' + api.id + '" class="d-flex align-items-center p-2 text-decoration-none" ' +
          'style="color:#e0e0e0;border-bottom:1px solid #2a2d3e;">' +
          '<span class="badge bg-' + badge + ' me-2" style="font-size:.7rem;">' + api.httpMethod + '</span>' +
          '<span class="flex-grow-1 text-truncate" style="font-size:.85rem;">' + api.endpointPath + '</span>' +
          '<small class="text-muted ms-2">' + (api.name || '') + '</small>' +
          '</a>'
        );
      });
    });
  }, 250);
});
$(document).on('click', function(e) {
  if (!$(e.target).closest('#globalSearch, #searchResults').length) $('#searchResults').hide();
});
</script>
</body>
</html>
