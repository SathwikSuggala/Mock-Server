<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="description" content="Import and Export mock configurations. Supports Mock Server JSON, OpenAPI, and Postman Collections."/>
<title>Import / Export - Mock Server</title>
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
  .dark-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 14px; height: 100%; transition: transform .2s, box-shadow .2s; }
  .dark-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.4); }
  .dark-card .card-header { background: transparent; border-bottom: 1px solid #2a2d3e; font-weight: 600; color: #fff; padding: 1rem 1.2rem; }
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  .dark-input::file-selector-button { background: #252840; color: #a5b4fc; border: none; padding: .375rem .75rem; margin-right: 1rem; border-radius: 4px; transition: background .2s; }
  .dark-input::file-selector-button:hover { background: #2d3150; }
  .btn-indigo { background: #6366f1; color: #fff; border: none; }
  .btn-indigo:hover { background: #4f46e5; color: #fff; }
  .btn-orange { background: #f97316; color: #fff; border: none; }
  .btn-orange:hover { background: #ea580c; color: #fff; }
  .icon-circle { width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-bottom: 1rem; }
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
    <a href="/logs" class="nav-link"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link active"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy" class="nav-link"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings" class="nav-link"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>
<div class="main-content">
  <h1 style="font-size:1.6rem;font-weight:700;color:#fff;margin-bottom:1.5rem;"><i class="bi bi-arrow-left-right me-2 text-indigo"></i>Import / Export</h1>

  <div class="row g-4">
    <!-- Export -->
    <div class="col-md-3">
      <div class="dark-card">
        <div class="card-body d-flex flex-column text-center p-4">
          <div class="icon-circle bg-success bg-opacity-10 text-success mx-auto"><i class="bi bi-download"></i></div>
          <h5 class="text-white mb-3">Export Config</h5>
          <p class="text-muted small flex-grow-1">Export all APIs, Matchers, Responses, and Scenarios as a JSON file for backup or sharing.</p>
          <a href="/import-export/export" class="btn btn-success w-100">
            <i class="bi bi-download me-2"></i>Download JSON
          </a>
        </div>
      </div>
    </div>

    <!-- Import Mock Server -->
    <div class="col-md-3">
      <div class="dark-card">
        <div class="card-body d-flex flex-column text-center p-4">
          <div class="icon-circle bg-primary bg-opacity-10 text-primary mx-auto"><i class="bi bi-upload"></i></div>
          <h5 class="text-white mb-3">Import Config</h5>
          <p class="text-muted small flex-grow-1">Import a previously exported Mock Server configuration JSON file.</p>
          <div class="mb-3 text-start">
            <input type="file" class="form-control dark-input form-control-sm" id="importFile" accept=".json"/>
          </div>
          <button class="btn btn-primary w-100" onclick="importConfig()">
            <i class="bi bi-upload me-2"></i>Import JSON
          </button>
          <div id="importMsg" class="mt-2 text-start small"></div>
        </div>
      </div>
    </div>

    <!-- Import OpenAPI -->
    <div class="col-md-3">
      <div class="dark-card">
        <div class="card-body d-flex flex-column text-center p-4">
          <div class="icon-circle bg-info bg-opacity-10 text-info mx-auto"><i class="bi bi-file-earmark-code"></i></div>
          <h5 class="text-white mb-3">OpenAPI Import</h5>
          <p class="text-muted small flex-grow-1">Import endpoints from a Swagger or OpenAPI v3 specification (JSON or YAML).</p>
          <div class="mb-3 text-start">
            <input type="file" class="form-control dark-input form-control-sm" id="openApiFile" accept=".json,.yaml,.yml"/>
          </div>
          <button class="btn btn-info text-white w-100" onclick="importOpenApi()">
            <i class="bi bi-cloud-upload me-2"></i>Import OpenAPI
          </button>
          <div id="openApiMsg" class="mt-2 text-start small"></div>
        </div>
      </div>
    </div>

    <!-- Import Postman -->
    <div class="col-md-3">
      <div class="dark-card">
        <div class="card-body d-flex flex-column text-center p-4">
          <div class="icon-circle bg-warning bg-opacity-10 text-warning mx-auto"><i class="bi bi-box-seam"></i></div>
          <h5 class="text-white mb-3">Postman Import</h5>
          <p class="text-muted small flex-grow-1">Import endpoints and example responses from a Postman Collection v2.1 JSON file.</p>
          <div class="mb-3 text-start">
            <input type="file" class="form-control dark-input form-control-sm" id="postmanFile" accept=".json"/>
          </div>
          <button class="btn btn-orange w-100" onclick="importPostman()">
            <i class="bi bi-box-arrow-in-right me-2"></i>Import Postman
          </button>
          <div id="postmanMsg" class="mt-2 text-start small"></div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
function showMsg(id, type, text) {
  document.getElementById(id).innerHTML = '<div class="alert alert-' + type + ' py-2 mb-0">' + text + '</div>';
}

function uploadFile(url, fileId, msgId) {
  var file = document.getElementById(fileId).files[0];
  if (!file) { showMsg(msgId, 'warning', 'Please select a file first.'); return; }
  var fd = new FormData();
  fd.append('file', file);
  showMsg(msgId, 'info', '<i class="bi bi-hourglass-split me-1"></i>Importing...');
  $.ajax({
    url: url, method: 'POST', data: fd, processData: false, contentType: false,
    success: function(r) {
      try { var data = JSON.parse(r); showMsg(msgId, 'success', '<i class="bi bi-check-circle me-1"></i>' + data.message); }
      catch(e) { showMsg(msgId, 'success', '<i class="bi bi-check-circle me-1"></i>Import successful.'); }
      document.getElementById(fileId).value = '';
    },
    error: function(e) {
      try { var data = JSON.parse(e.responseText); showMsg(msgId, 'danger', '<i class="bi bi-x-circle me-1"></i>' + data.error); }
      catch(err) { showMsg(msgId, 'danger', '<i class="bi bi-x-circle me-1"></i>' + e.responseText); }
    }
  });
}

function importConfig() { uploadFile('/import-export/import', 'importFile', 'importMsg'); }
function importOpenApi() { uploadFile('/import-export/openapi', 'openApiFile', 'openApiMsg'); }
function importPostman() { uploadFile('/import-export/postman', 'postmanFile', 'postmanMsg'); }
</script>
</body>
</html>
