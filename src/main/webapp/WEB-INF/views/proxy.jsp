<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Proxy - Mock Server</title>
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
  
  .dark-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 14px; overflow: hidden; margin-bottom: 1.5rem; }
  .dark-card .card-header { background: transparent; border-bottom: 1px solid #2a2d3e; font-weight: 600; color: #fff; padding: 1rem 1.2rem; }
  .dark-card .card-body { padding: 1.5rem; }
  .dark-card .card-footer { background: transparent; border-top: 1px solid #2a2d3e; padding: .7rem 1.2rem; color: #8890a4; }
  
  .dark-table { background: transparent; color: #c0c0c0; margin: 0; }
  .dark-table thead th { background: #252840; border-bottom: 1px solid #2a2d3e; color: #8890a4; font-size: .78rem; text-transform: uppercase; letter-spacing: .8px; padding: 1rem 1.2rem; }
  .dark-table tbody tr { border-bottom: 1px solid #1e2235; transition: background .15s; }
  .dark-table tbody tr:hover { background: rgba(99,102,241,.08); }
  .dark-table td { padding: 1rem 1.2rem; vertical-align: middle; }
  
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  label { color: #8890a4; font-size: .82rem; font-weight: 500; }
</style>
</head>
<body>
<div class="sidebar d-flex flex-column">
  <div class="brand"><i class="bi bi-server me-2"></i>Mock Server</div>
  <nav class="nav flex-column mt-2">
    <a href="/dashboard" class="nav-link"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a>
    <a href="/apis" class="nav-link"><i class="bi bi-list-ul me-2"></i>APIs</a>
    <a href="/scenarios" class="nav-link"><i class="bi bi-diagram-3 me-2"></i>Scenarios</a>
    <a href="/logs" class="nav-link"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy" class="nav-link active"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings" class="nav-link"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>
<div class="main-content">
  <h1 style="font-size:1.6rem;font-weight:700;color:#fff;margin-bottom:1.5rem;"><i class="bi bi-globe me-2 text-indigo"></i>Proxy + Record Mode</h1>

  <div class="dark-card shadow-sm">
    <div class="card-header"><i class="bi bi-sliders me-2"></i>Proxy Configuration</div>
    <div class="card-body">
      <div class="row g-3">
        <div class="col-md-6">
          <label>Target Base URL</label>
          <input type="text" class="form-control dark-input" id="proxyTarget"
            value="${proxyTarget}" placeholder="https://api.example.com"/>
        </div>
        <div class="col-md-3 d-flex align-items-end pb-1">
          <div class="form-check">
            <input class="form-check-input" type="checkbox" id="proxyEnabled" ${proxyEnabled == 'true' ? 'checked' : ''}/>
            <label class="form-check-label text-white">Enable Proxy Mode</label>
          </div>
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button class="btn btn-primary" onclick="saveProxySettings()">Save Settings</button>
        </div>
      </div>
      <div class="mt-3">
        <small class="text-muted">
          When enabled, all <code style="color:#a5b4fc;">/mock/**</code> requests will be forwarded to the target URL and recorded.
        </small>
      </div>
      <div id="proxyMsg" class="mt-2"></div>
    </div>
  </div>

  <div class="dark-card shadow-sm">
    <div class="card-header d-flex justify-content-between align-items-center">
      <span><i class="bi bi-camera-video me-2"></i>Recorded Requests</span>
      <button class="btn btn-sm btn-outline-primary" onclick="loadRecordings(0)">
        <i class="bi bi-arrow-clockwise"></i> Refresh
      </button>
    </div>
    <div style="overflow-x:auto;">
      <table class="table table-dark table-hover dark-table">
        <thead>
          <tr><th>Time</th><th>Method</th><th>Path</th><th>Status</th><th>Imported</th><th style="text-align:right;">Actions</th></tr>
        </thead>
        <tbody id="recordingBody"></tbody>
      </table>
    </div>
    <div class="card-footer d-flex justify-content-between align-items-center">
      <span id="recPageInfo">Page 1</span>
      <div>
        <button class="btn btn-sm btn-outline-secondary me-1" onclick="prevRecPage()">
          <i class="bi bi-chevron-left"></i>
        </button>
        <button class="btn btn-sm btn-outline-secondary" onclick="nextRecPage()">
          <i class="bi bi-chevron-right"></i>
        </button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
var recPage = 0, recTotalPages = 0;

$(document).ready(function() { loadRecordings(0); });

function saveProxySettings() {
  var settings = {
    'proxy.enabled': document.getElementById('proxyEnabled').checked ? 'true' : 'false',
    'proxy.targetUrl': document.getElementById('proxyTarget').value
  };
  $.ajax({url: '/settings/api/save', method: 'POST', contentType: 'application/json',
    data: JSON.stringify(settings),
    success: function() {
      document.getElementById('proxyMsg').innerHTML =
        '<div class="alert alert-success" style="background:rgba(34,197,94,.1);border:1px solid #22c55e;color:#22c55e;">Settings saved</div>';
    }
  });
}

function loadRecordings(page) {
  recPage = page;
  $.get('/proxy/api/recordings', {page: page, size: 20}, function(data) {
    recTotalPages = data.totalPages;
    document.getElementById('recPageInfo').textContent =
      'Page ' + (page+1) + ' of ' + (recTotalPages || 1);
    var html = '';
    data.content.forEach(function(r) {
      var statusClass = r.responseStatus < 300 ? 'success' : r.responseStatus < 400 ? 'warning' : 'danger';
      html += '<tr>' +
        '<td><small>' + (r.timestamp||'').replace('T',' ').substring(0,19) + '</small></td>' +
        '<td><span class="badge bg-primary">' + r.httpMethod + '</span></td>' +
        '<td><code style="color:#a5b4fc;font-size:.85rem;">' + r.requestPath + '</code></td>' +
        '<td><span class="badge bg-' + statusClass + '">' + r.responseStatus + '</span></td>' +
        '<td>' + (r.imported ? '<i class="bi bi-check-circle-fill text-success"></i>' : '') + '</td>' +
        '<td style="text-align:right;">' +
          '<button class="btn btn-sm btn-outline-success me-1" onclick="importRec(' + r.id + ')" title="Import as API">' +
            '<i class="bi bi-box-arrow-in-down"></i></button>' +
          '<button class="btn btn-sm btn-outline-danger" onclick="deleteRec(' + r.id + ')">' +
            '<i class="bi bi-trash"></i></button>' +
        '</td>' +
        '</tr>';
    });
    document.getElementById('recordingBody').innerHTML = html ||
      '<tr><td colspan="6" class="text-center text-muted py-5">No recordings yet</td></tr>';
  });
}

function importRec(id) {
  $.post('/proxy/api/import/' + id, function() {
    alert('Imported as API!');
    loadRecordings(recPage);
  }).fail(function(e) { alert('Error: ' + e.responseText); });
}

function deleteRec(id) {
  if (!confirm('Delete recording?')) return;
  $.ajax({url: '/proxy/api/recordings/' + id, method: 'DELETE',
    success: function() { loadRecordings(recPage); }
  });
}

function prevRecPage() { if (recPage > 0) loadRecordings(recPage - 1); }
function nextRecPage() { if (recPage < recTotalPages - 1) loadRecordings(recPage + 1); }
</script>
</body>
</html>
