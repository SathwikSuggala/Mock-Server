<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="description" content="Mock Server Call Logs - Browse, filter and inspect all API requests and responses."/>
<title>Call Logs - Mock Server</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
<style>
  * { font-family: 'Inter', sans-serif; }
  body { background: #0f1117; color: #e0e0e0; }
  .sidebar { width: 230px; min-height: 100vh; background: linear-gradient(180deg, #1a1d2e 0%, #12151f 100%);
             position: fixed; top: 0; left: 0; z-index: 100; border-right: 1px solid #2a2d3e; }
  .sidebar .nav-link { color: #8890a4; padding: .65rem 1.2rem; border-radius: 8px; margin: 2px 8px; transition: all .2s; font-size: .9rem; }
  .sidebar .nav-link:hover { color: #fff; background: rgba(99,102,241,.15); }
  .sidebar .nav-link.active { color: #fff; background: rgba(99,102,241,.25); border-left: 3px solid #6366f1; }
  .sidebar .brand { color: #fff; font-size: 1.1rem; padding: 1.2rem; border-bottom: 1px solid #2a2d3e; font-weight: 600; }
  .main-content { margin-left: 230px; padding: 1.8rem; }
  .filter-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 12px; padding: 1rem; margin-bottom: 1rem; }
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  .dark-select { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); }
  .log-table { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 12px; overflow: hidden; }
  .log-table table { margin: 0; }
  .log-table thead th { background: #252840; border-bottom: 1px solid #2a2d3e; color: #8890a4;
                        font-size: .78rem; text-transform: uppercase; letter-spacing: .8px; }
  .log-table tbody tr { border-bottom: 1px solid #1e2235; color: #c0c0c0; transition: background .15s; cursor: pointer; }
  .log-table tbody tr:hover { background: rgba(99,102,241,.1); }
  .log-table td { font-size: .82rem; vertical-align: middle; }
  .modal-content { background: #1a1d2e; border: 1px solid #2a2d3e; }
  .modal-header { border-bottom: 1px solid #2a2d3e; }
  .code-block { background: #12151f; border: 1px solid #2a2d3e; border-radius: 8px; padding: .8rem;
                font-family: monospace; font-size: .82rem; white-space: pre-wrap; word-break: break-all;
                max-height: 320px; overflow: auto; color: #a5b4fc; }
  .page-footer { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 0 0 12px 12px;
                 padding: .7rem 1.2rem; display: flex; justify-content: space-between; align-items: center; }
</style>
<%@ include file="theme.jsp" %>
</head>
<body>
<div class="sidebar d-flex flex-column">
  <div class="brand"><i class="bi bi-server me-2"></i>Mock Server</div>
  <nav class="nav flex-column mt-2">
    <a href="/dashboard" class="nav-link"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a>
    <a href="/apis" class="nav-link"><i class="bi bi-list-ul me-2"></i>APIs</a>
    <a href="/scenarios" class="nav-link"><i class="bi bi-diagram-3 me-2"></i>Scenarios</a>
    <a href="/logs" class="nav-link active"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy" class="nav-link"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings" class="nav-link"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>
<div class="main-content">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h1 style="font-size:1.6rem;font-weight:700;color:#fff;"><i class="bi bi-journal-text me-2"></i>Call Logs</h1>
    <button class="btn btn-danger btn-sm" onclick="clearLogs()">
      <i class="bi bi-trash me-1"></i>Clear All
    </button>
  </div>

  <!-- Filters -->
  <div class="filter-card">
    <div class="row g-2 align-items-center">
      <div class="col-md-2">
        <select class="form-select dark-select" id="filterMethod">
          <option value="">All Methods</option>
          <option>GET</option><option>POST</option><option>PUT</option>
          <option>DELETE</option><option>PATCH</option>
        </select>
      </div>
      <div class="col-md-3">
        <input type="text" class="form-control dark-input" id="filterPath" placeholder="Path contains..."/>
      </div>
      <div class="col-md-2">
        <input type="number" class="form-control dark-input" id="filterStatus" placeholder="Status code"/>
      </div>
      <div class="col-md-2">
        <input type="datetime-local" class="form-control dark-input" id="filterFrom"/>
      </div>
      <div class="col-md-2">
        <input type="datetime-local" class="form-control dark-input" id="filterTo"/>
      </div>
      <div class="col-md-1">
        <button class="btn btn-primary w-100" onclick="loadLogs(0)">
          <i class="bi bi-search"></i>
        </button>
      </div>
    </div>
  </div>

  <!-- Table -->
  <div class="log-table">
    <div style="overflow-x:auto;">
      <table class="table table-sm table-dark table-hover mb-0">
        <thead>
          <tr>
            <th>Time</th><th>Method</th><th>Path</th><th>Status</th>
            <th>Matcher</th><th>Exec(ms)</th><th>Scenario</th><th></th>
          </tr>
        </thead>
        <tbody id="logBody"></tbody>
      </table>
    </div>
    <div class="page-footer">
      <span id="pageInfo" class="text-muted" style="font-size:.82rem;">Loading...</span>
      <div class="d-flex gap-1">
        <button class="btn btn-sm btn-outline-secondary" onclick="prevPage()"><i class="bi bi-chevron-left"></i></button>
        <button class="btn btn-sm btn-outline-secondary" onclick="nextPage()"><i class="bi bi-chevron-right"></i></button>
      </div>
    </div>
  </div>
</div>

<!-- Detail Modal -->
<div class="modal fade" id="detailModal" tabindex="-1">
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-white"><i class="bi bi-journal-code me-2"></i>Request / Response Detail</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row g-3">
          <div class="col-md-6">
            <h6 class="text-light mb-2"><i class="bi bi-arrow-up-right me-1"></i>Request</h6>
            <div class="mb-2">
              <small class="text-muted">HEADERS</small>
              <div id="detailReqHeaders" class="code-block mt-1"></div>
            </div>
            <div class="mb-2">
              <small class="text-muted">QUERY PARAMS</small>
              <div id="detailQuery" class="code-block mt-1" style="min-height:30px;"></div>
            </div>
            <div>
              <small class="text-muted">BODY</small>
              <div id="detailReqBody" class="code-block mt-1"></div>
            </div>
          </div>
          <div class="col-md-6">
            <h6 class="text-light mb-2"><i class="bi bi-arrow-down-left me-1"></i>Response</h6>
            <div id="detailRespBody" class="code-block" style="max-height:430px;"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
var currentPage = 0;
var totalPages = 0;
var detailModal = new bootstrap.Modal(document.getElementById('detailModal'));
var currentLogs = [];

$(document).ready(function() {
  // Pre-fill path filter from URL param (e.g. from dashboard shortcut)
  var urlParams = new URLSearchParams(window.location.search);
  var pathParam = urlParams.get('path');
  if (pathParam) $('#filterPath').val(pathParam);
  loadLogs(0);

  // Enter key on filter inputs
  $('#filterMethod,#filterPath,#filterStatus,#filterFrom,#filterTo').on('keydown', function(e) {
    if (e.key === 'Enter') loadLogs(0);
  });
});

function loadLogs(page) {
  currentPage = page;
  var params = {
    method: $('#filterMethod').val(),
    path: $('#filterPath').val(),
    status: $('#filterStatus').val(),
    from: $('#filterFrom').val() ? $('#filterFrom').val() + ':00' : '',
    to: $('#filterTo').val() ? $('#filterTo').val() + ':00' : '',
    page: page,
    size: 20
  };
  $.get('/logs/api/search', params, function(data) {
    currentLogs = data.content;
    totalPages = data.totalPages;
    $('#pageInfo').text('Page ' + (page+1) + ' of ' + (totalPages || 1) + ' (' + data.totalElements + ' total)');
    var html = '';
    data.content.forEach(function(log) {
      var sc = log.statusCode;
      var statusClass = sc < 300 ? 'success' : sc < 400 ? 'warning' : 'danger';
      var methodColors = {GET:'primary',POST:'success',PUT:'warning',DELETE:'danger',PATCH:'info'};
      var methodColor = methodColors[log.httpMethod] || 'secondary';
      html += '<tr onclick="showDetail(' + log.id + ')">' +
        '<td><small>' + (log.timestamp||'').replace('T',' ').substring(0,19) + '</small></td>' +
        '<td><span class="badge bg-' + methodColor + '" style="font-size:.75rem;">' + log.httpMethod + '</span></td>' +
        '<td><code style="color:#a5b4fc;font-size:.8rem;">' + (log.requestPath||'') + '</code></td>' +
        '<td><span class="badge bg-' + statusClass + '">' + sc + '</span></td>' +
        '<td><small class="text-muted">' + (log.matcherName||'-') + '</small></td>' +
        '<td><small>' + (log.executionTimeMs||0) + 'ms</small></td>' +
        '<td><small class="text-muted">' + (log.scenarioName||'-') + '</small></td>' +
        '<td><button class="btn btn-sm btn-outline-secondary" onclick="event.stopPropagation();showDetail(' + log.id + ')"><i class="bi bi-eye"></i></button></td>' +
        '</tr>';
    });
    $('#logBody').html(html || '<tr><td colspan="8" class="text-center text-muted py-4">No logs found</td></tr>');
  });
}

function showDetail(id) {
  var log = currentLogs.find(function(l) { return l.id == id; });
  if (!log) return;
  function tryFormat(txt) {
    if (!txt) return '(empty)';
    try { return JSON.stringify(JSON.parse(txt), null, 2); } catch(e) { return txt; }
  }
  document.getElementById('detailReqHeaders').textContent = tryFormat(log.requestHeaders);
  document.getElementById('detailQuery').textContent = log.queryParams || '(none)';
  document.getElementById('detailReqBody').textContent = tryFormat(log.requestBody);
  document.getElementById('detailRespBody').textContent = tryFormat(log.responseBody);
  detailModal.show();
}

function prevPage() { if (currentPage > 0) loadLogs(currentPage - 1); }
function nextPage() { if (currentPage < totalPages - 1) loadLogs(currentPage + 1); }

function clearLogs() {
  if (!confirm('Clear ALL call logs?')) return;
  $.ajax({ url: '/logs/api/clear', method: 'DELETE', success: function() { loadLogs(0); } });
}
</script>
</body>
</html>
