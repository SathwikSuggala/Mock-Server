<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<meta name="description" content="Import and Export mock API configurations with selective control and cURL support."/>
<title>Import / Export - Mock Server</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
<style>
  * { font-family: 'Inter', sans-serif; }
  body { background: #0f1117; color: #e0e0e0; }

  /* Sidebar */
  .sidebar { width: 230px; min-height: 100vh; background: linear-gradient(180deg, #1a1d2e 0%, #12151f 100%);
             position: fixed; top: 0; left: 0; z-index: 100; border-right: 1px solid #2a2d3e; }
  .sidebar .nav-link { color: #8890a4; padding: .65rem 1.2rem; border-radius: 8px; margin: 2px 8px; transition: all .2s; font-size: .9rem; }
  .sidebar .nav-link:hover { color: #fff; background: rgba(99,102,241,.15); }
  .sidebar .nav-link.active { color: #fff; background: rgba(99,102,241,.25); border-left: 3px solid #6366f1; }
  .sidebar .brand { color: #fff; font-size: 1.1rem; padding: 1.2rem; border-bottom: 1px solid #2a2d3e; font-weight: 600; }
  .main-content { margin-left: 230px; padding: 2rem; }

  /* Cards */
  .dark-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 14px; }
  .dark-card .card-header { background: transparent; border-bottom: 1px solid #2a2d3e; font-weight: 600; color: #fff; padding: .9rem 1.2rem; }

  /* Inputs */
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  .dark-input::file-selector-button { background: #252840; color: #a5b4fc; border: none; padding: .375rem .75rem; margin-right: 1rem; border-radius: 4px; }
  textarea.dark-input { resize: vertical; min-height: 110px; }

  /* Buttons */
  .btn-indigo { background: #6366f1; color: #fff; border: none; }
  .btn-indigo:hover { background: #4f46e5; color: #fff; }
  .btn-orange { background: #f97316; color: #fff; border: none; }
  .btn-orange:hover { background: #ea580c; color: #fff; }

  /* Method badges */
  .badge-GET    { background:#10b981; color:#fff; }
  .badge-POST   { background:#6366f1; color:#fff; }
  .badge-PUT    { background:#f59e0b; color:#fff; }
  .badge-DELETE { background:#ef4444; color:#fff; }
  .badge-PATCH  { background:#8b5cf6; color:#fff; }
  .badge-HEAD, .badge-OPTIONS { background:#6b7280; color:#fff; }
  .method-badge { display:inline-block; padding:2px 7px; border-radius:4px; font-size:.72rem; font-weight:600; font-family:monospace; min-width:58px; text-align:center; }

  /* Section tabs */
  .section-tabs .nav-link { color: #8890a4; border: none; border-bottom: 2px solid transparent; border-radius: 0; padding: .6rem 1.2rem; }
  .section-tabs .nav-link.active { color: #a5b4fc; border-bottom-color: #6366f1; background: transparent; }

  /* Preview table */
  .preview-table { background: #12151f; border-radius: 8px; }
  .preview-table thead th { background: #1a1d2e; color: #8890a4; font-size:.8rem; font-weight:600; border-color:#2a2d3e; }
  .preview-table tbody tr { border-color:#2a2d3e; }
  .preview-table tbody td { color:#e0e0e0; font-size:.88rem; vertical-align:middle; border-color:#2a2d3e; }
  .preview-table tbody tr:hover td { background: rgba(99,102,241,.07); }

  /* Conflict row */
  .conflict-row td { background: rgba(239,68,68,.07) !important; }

  /* Step indicators */
  .step-badge { width:24px; height:24px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; font-size:.75rem; font-weight:700; }
  .step-badge.done { background:#10b981; color:#fff; }
  .step-badge.active { background:#6366f1; color:#fff; }
  .step-badge.idle { background:#2a2d3e; color:#8890a4; }

  /* Inline result */
  .curl-result { border-radius:8px; padding:.75rem 1rem; font-size:.88rem; margin-top:.6rem; }
  .curl-result.success { background: rgba(16,185,129,.1); border: 1px solid rgba(16,185,129,.3); color: #6ee7b7; }
  .curl-result.danger  { background: rgba(239,68,68,.1);  border: 1px solid rgba(239,68,68,.3);  color: #fca5a5; }

  /* Select-all bar */
  .select-bar { background:#12151f; border-radius:8px; padding:.5rem .75rem; margin-bottom:.75rem; font-size:.85rem; }

  /* Scrollable checklist */
  .checklist-scroll { max-height: 320px; overflow-y: auto; }

  /* Smooth transitions */
  .fade-in { animation: fadeIn .25s ease; }
  @keyframes fadeIn { from { opacity:0; transform:translateY(6px); } to { opacity:1; transform:none; } }
</style>
<%@ include file="theme.jsp" %>
</head>
<body>

<div class="sidebar d-flex flex-column">
  <div class="brand"><i class="bi bi-server me-2"></i>Mock Server</div>
  <nav class="nav flex-column mt-2">
    <a href="/dashboard"     class="nav-link"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a>
    <a href="/apis"          class="nav-link"><i class="bi bi-list-ul me-2"></i>APIs</a>
    <a href="/scenarios"     class="nav-link"><i class="bi bi-diagram-3 me-2"></i>Scenarios</a>
    <a href="/logs"          class="nav-link"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link active"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy"         class="nav-link"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings"      class="nav-link"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>

<div class="main-content">
  <h1 style="font-size:1.6rem;font-weight:700;color:#fff;margin-bottom:.4rem;">
    <i class="bi bi-arrow-left-right me-2" style="color:#6366f1"></i>Import / Export
  </h1>
  <p class="text-muted mb-4" style="font-size:.9rem;">Selective import with preview, smart conflict resolution, and cURL import.</p>

  <!-- ================================================================ -->
  <!-- EXPORT SECTION                                                     -->
  <!-- ================================================================ -->
  <div class="dark-card mb-4">
    <div class="card-header d-flex align-items-center gap-3">
      <i class="bi bi-download text-success"></i>
      <span>Export</span>
      <div class="ms-auto d-flex gap-2">
        <button class="btn btn-sm btn-outline-secondary" id="exportModeApis"   onclick="setExportMode('apis')"    style="font-size:.8rem">APIs</button>
        <button class="btn btn-sm btn-outline-secondary" id="exportModeScenario" onclick="setExportMode('scenario')" style="font-size:.8rem">Scenario</button>
      </div>
    </div>
    <div class="card-body p-3">

      <!-- APIs export mode -->
      <div id="exportApisPane">
        <div class="d-flex align-items-center justify-content-between select-bar">
          <label class="d-flex align-items-center gap-2 mb-0" style="cursor:pointer">
            <input type="checkbox" id="selectAllApis" onchange="toggleAllApis(this.checked)"/> <span class="text-white">Select All</span>
          </label>
          <span id="apisSelectedCount" class="text-muted">0 selected</span>
        </div>
        <div class="checklist-scroll">
          <table class="table preview-table mb-0" id="apisExportTable">
            <thead><tr><th style="width:36px"></th><th>Method</th><th>Path</th><th>Name</th></tr></thead>
            <tbody id="apisExportBody"><tr><td colspan="4" class="text-center text-muted py-3"><i class="bi bi-hourglass-split me-1"></i>Loading...</td></tr></tbody>
          </table>
        </div>
        <div class="mt-3 d-flex gap-2">
          <button class="btn btn-success btn-sm" onclick="doExportApis()"><i class="bi bi-download me-1"></i>Export Selected</button>
          <a href="/import-export/export" class="btn btn-outline-secondary btn-sm"><i class="bi bi-cloud-download me-1"></i>Export All</a>
        </div>
      </div>

      <!-- Scenario export mode -->
      <div id="exportScenarioPane" style="display:none">
        <div class="row g-3">
          <div class="col-md-5">
            <label class="text-muted small mb-1">Select Scenario</label>
            <select id="scenarioSelect" class="form-select dark-input" onchange="loadScenarioMappings()">
              <option value="">— Choose a scenario —</option>
            </select>
          </div>
        </div>
        <div id="scenarioMappingsArea" class="mt-3" style="display:none">
          <div class="d-flex align-items-center justify-content-between select-bar">
            <label class="d-flex align-items-center gap-2 mb-0" style="cursor:pointer">
              <input type="checkbox" id="selectAllMappings" onchange="toggleAllMappings(this.checked)"/> <span class="text-white">Select All Mappings</span>
            </label>
            <span id="mappingsSelectedCount" class="text-muted">0 selected</span>
          </div>
          <div class="checklist-scroll">
            <table class="table preview-table mb-0" id="scenarioMappingsTable">
              <thead><tr><th style="width:36px"></th><th>Method</th><th>Path</th><th>API Name</th><th>Response</th></tr></thead>
              <tbody id="scenarioMappingsBody"></tbody>
            </table>
          </div>
          <div class="mt-3">
            <button class="btn btn-success btn-sm" onclick="doExportScenario()"><i class="bi bi-download me-1"></i>Export Selected Mappings</button>
          </div>
        </div>
      </div>

    </div>
  </div>

  <!-- ================================================================ -->
  <!-- IMPORT SECTION                                                     -->
  <!-- ================================================================ -->
  <div class="dark-card mb-4">
    <div class="card-header">
      <i class="bi bi-upload text-primary me-2"></i>Import
    </div>
    <div class="card-body p-0">
      <ul class="nav section-tabs px-3 pt-2" id="importTabs">
        <li class="nav-item"><a class="nav-link active" href="#" onclick="showImportTab('mockserver',this)">Mock Server JSON</a></li>
        <li class="nav-item"><a class="nav-link" href="#" onclick="showImportTab('openapi',this)">OpenAPI / Swagger</a></li>
        <li class="nav-item"><a class="nav-link" href="#" onclick="showImportTab('postman',this)">Postman Collection</a></li>
      </ul>

      <div class="p-3">
        <!-- Step 1: File picker -->
        <div class="mb-3 d-flex align-items-end gap-3">
          <div class="flex-grow-1">
            <label class="text-muted small mb-1">
              <span class="step-badge active me-1" id="step1badge">1</span> Select File
            </label>
            <input type="file" class="form-control dark-input" id="importFile" accept=".json,.yaml,.yml" onchange="resetImportPreview()"/>
          </div>
          <button class="btn btn-indigo" onclick="previewImport()" id="previewBtn" style="min-width:110px">
            <i class="bi bi-eye me-1"></i>Preview
          </button>
        </div>

        <!-- Step 2: Preview & Conflict Resolution -->
        <div id="importPreviewArea" style="display:none">
          <div class="mb-2 d-flex align-items-center gap-2">
            <span class="step-badge active">2</span>
            <span class="text-white fw-600">Review Endpoints</span>
            <span id="previewCountBadge" class="badge bg-secondary ms-1"></span>
            <span id="conflictBadge" class="badge bg-danger ms-1" style="display:none"></span>
          </div>

          <!-- Conflict resolution notice -->
          <div id="conflictNotice" class="alert alert-warning py-2 mb-3" style="display:none; background:rgba(245,158,11,.1); border-color:rgba(245,158,11,.3); color:#fde68a;">
            <i class="bi bi-exclamation-triangle me-2"></i>
            <strong>Conflicts detected!</strong> Some APIs below already exist. Choose how to handle each one.
          </div>

          <div class="d-flex align-items-center justify-content-between select-bar mb-2">
            <label class="d-flex align-items-center gap-2 mb-0" style="cursor:pointer">
              <input type="checkbox" id="selectAllPreview" onchange="toggleAllPreview(this.checked)" checked/> <span class="text-white">Select All</span>
            </label>
            <span id="previewSelectedCount" class="text-muted">0 selected</span>
          </div>

          <div class="checklist-scroll fade-in">
            <table class="table preview-table mb-0">
              <thead>
                <tr>
                  <th style="width:36px"></th>
                  <th>Method</th>
                  <th>Path</th>
                  <th>Name</th>
                  <th id="conflictColHeader" style="display:none">Conflict Resolution</th>
                </tr>
              </thead>
              <tbody id="previewTableBody"></tbody>
            </table>
          </div>

          <div class="mt-3 d-flex gap-2 align-items-center">
            <button class="btn btn-indigo" onclick="doImportSelective()" id="importBtn">
              <i class="bi bi-upload me-1"></i>Import Selected
            </button>
            <button class="btn btn-outline-secondary btn-sm" onclick="resetImportPreview()">
              <i class="bi bi-arrow-counterclockwise me-1"></i>Reset
            </button>
            <span id="importResultMsg" class="ms-2"></span>
          </div>
        </div>

      </div>
    </div>
  </div>

  <!-- ================================================================ -->
  <!-- CURL IMPORT                                                        -->
  <!-- ================================================================ -->
  <div class="dark-card mb-4">
    <div class="card-header">
      <i class="bi bi-terminal me-2" style="color:#f59e0b"></i>Import from cURL
    </div>
    <div class="card-body p-3">
      <p class="text-muted small mb-2">Paste any <code>curl</code> command to instantly create a mock API from it.</p>
      <textarea id="curlInput" class="form-control dark-input mb-2" rows="4"
        placeholder="curl -X POST 'https://api.example.com/users' \&#10;  -H 'Content-Type: application/json' \&#10;  -d '{&quot;name&quot;: &quot;test&quot;}'"></textarea>
      <button class="btn btn-warning text-dark fw-600" onclick="importCurl()">
        <i class="bi bi-lightning-fill me-1"></i>Parse &amp; Import
      </button>
      <div id="curlResult" class="mt-2"></div>
    </div>
  </div>

</div><!-- /main-content -->


<!-- ================================================================ -->
<!-- SCRIPTS                                                            -->
<!-- ================================================================ -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
// ============================================================
// STATE
// ============================================================
let currentImportType  = 'mockserver';
let currentFileContent = '';
let currentFilename    = '';
let previewItems       = [];
let conflictKeys       = [];

// ============================================================
// EXPORT — APIs mode
// ============================================================
function setExportMode(mode) {
  document.getElementById('exportApisPane').style.display     = mode === 'apis'     ? '' : 'none';
  document.getElementById('exportScenarioPane').style.display = mode === 'scenario' ? '' : 'none';
  document.getElementById('exportModeApis').classList.toggle('btn-indigo', mode === 'apis');
  document.getElementById('exportModeApis').classList.toggle('btn-outline-secondary', mode !== 'apis');
  document.getElementById('exportModeScenario').classList.toggle('btn-indigo', mode === 'scenario');
  document.getElementById('exportModeScenario').classList.toggle('btn-outline-secondary', mode !== 'scenario');
  if (mode === 'apis' && document.getElementById('apisExportBody').children.length <= 1) loadApisForExport();
  if (mode === 'scenario' && document.getElementById('scenarioSelect').options.length <= 1) loadScenariosForExport();
}

function loadApisForExport() {
  fetch('/import-export/apis-list').then(r => r.json()).then(apis => {
    const tbody = document.getElementById('apisExportBody');
    if (!apis.length) { tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">No APIs found.</td></tr>'; return; }
    tbody.innerHTML = apis.map(a => `
      <tr>
        <td><input type="checkbox" class="api-export-chk" value="${a.id}" onchange="updateApisCount()"/></td>
        <td><span class="method-badge badge-${a.httpMethod}">${a.httpMethod}</span></td>
        <td><code style="color:#c4b5fd">${a.endpointPath}</code></td>
        <td class="text-muted">${escHtml(a.name)}</td>
      </tr>`).join('');
    updateApisCount();
  });
}

function toggleAllApis(checked) {
  document.querySelectorAll('.api-export-chk').forEach(c => c.checked = checked);
  updateApisCount();
}

function updateApisCount() {
  const n = document.querySelectorAll('.api-export-chk:checked').length;
  document.getElementById('apisSelectedCount').textContent = n + ' selected';
}

function doExportApis() {
  const ids = [...document.querySelectorAll('.api-export-chk:checked')].map(c => parseInt(c.value));
  if (!ids.length) { alert('Please select at least one API to export.'); return; }
  fetch('/import-export/export-apis', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ ids })
  }).then(r => r.blob()).then(blob => triggerDownload(blob, 'mock-apis-' + ts() + '.json'));
}

// ============================================================
// EXPORT — Scenario mode
// ============================================================
function loadScenariosForExport() {
  fetch('/import-export/scenarios-list').then(r => r.json()).then(scenarios => {
    const sel = document.getElementById('scenarioSelect');
    scenarios.forEach(s => {
      const opt = document.createElement('option');
      opt.value = s.id; opt.textContent = s.name + ' (' + s.mappingCount + ' mappings)';
      sel.appendChild(opt);
    });
  });
}

function loadScenarioMappings() {
  const id = document.getElementById('scenarioSelect').value;
  const area = document.getElementById('scenarioMappingsArea');
  if (!id) { area.style.display = 'none'; return; }
  fetch('/import-export/scenario-mappings/' + id).then(r => r.json()).then(mappings => {
    area.style.display = '';
    const tbody = document.getElementById('scenarioMappingsBody');
    if (!mappings.length) { tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-3">No mappings found.</td></tr>'; return; }
    tbody.innerHTML = mappings.map(m => `
      <tr>
        <td><input type="checkbox" class="mapping-chk" value="${m.mappingId}" checked onchange="updateMappingsCount()"/></td>
        <td><span class="method-badge badge-${m.httpMethod}">${m.httpMethod}</span></td>
        <td><code style="color:#c4b5fd">${escHtml(m.endpointPath)}</code></td>
        <td class="text-muted">${escHtml(m.apiName)}</td>
        <td><span class="badge bg-secondary">${escHtml(m.responseName)}</span></td>
      </tr>`).join('');
    updateMappingsCount();
  });
}

function toggleAllMappings(checked) {
  document.querySelectorAll('.mapping-chk').forEach(c => c.checked = checked);
  updateMappingsCount();
}

function updateMappingsCount() {
  const n = document.querySelectorAll('.mapping-chk:checked').length;
  document.getElementById('mappingsSelectedCount').textContent = n + ' selected';
}

function doExportScenario() {
  const scenarioId = document.getElementById('scenarioSelect').value;
  if (!scenarioId) { alert('Please select a scenario first.'); return; }
  const mappingIds = [...document.querySelectorAll('.mapping-chk:checked')].map(c => parseInt(c.value));
  if (!mappingIds.length) { alert('Please select at least one mapping.'); return; }
  fetch('/import-export/export-scenario', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ scenarioId: parseInt(scenarioId), mappingIds })
  }).then(r => r.blob()).then(blob => triggerDownload(blob, 'mock-scenario-' + ts() + '.json'));
}

// ============================================================
// IMPORT TABS
// ============================================================
function showImportTab(type, el) {
  currentImportType = type;
  document.querySelectorAll('#importTabs .nav-link').forEach(l => l.classList.remove('active'));
  el.classList.add('active');
  // Update file accept
  const acceptMap = { mockserver: '.json', openapi: '.json,.yaml,.yml', postman: '.json' };
  document.getElementById('importFile').accept = acceptMap[type] || '.json';
  resetImportPreview();
}

// ============================================================
// IMPORT — Step 1: Preview
// ============================================================
function previewImport() {
  const fileEl = document.getElementById('importFile');
  if (!fileEl.files.length) { showInlineMsg('importResultMsg', 'warning', 'Please select a file first.'); return; }
  const file = fileEl.files[0];
  currentFilename = file.name;
  const fd = new FormData();
  fd.append('file', file);
  fd.append('type', currentImportType);
  document.getElementById('previewBtn').innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Parsing...';
  document.getElementById('previewBtn').disabled = true;
  fetch('/import-export/preview', { method: 'POST', body: fd })
    .then(r => r.json()).then(data => {
      document.getElementById('previewBtn').innerHTML = '<i class="bi bi-eye me-1"></i>Preview';
      document.getElementById('previewBtn').disabled = false;
      if (data.error) { showInlineMsg('importResultMsg', 'danger', data.error); return; }
      currentFileContent = data.fileContent;
      previewItems = data.items || [];
      conflictKeys = data.conflictKeys || [];
      renderPreviewTable(previewItems, conflictKeys, data.conflicts || []);
      document.getElementById('importPreviewArea').style.display = '';
    }).catch(e => {
      document.getElementById('previewBtn').innerHTML = '<i class="bi bi-eye me-1"></i>Preview';
      document.getElementById('previewBtn').disabled = false;
      showInlineMsg('importResultMsg', 'danger', 'Failed to parse file: ' + e.message);
    });
}

function renderPreviewTable(items, conflicts, conflictDetails) {
  const tbody = document.getElementById('previewTableBody');
  const hasConflicts = conflicts.length > 0;
  document.getElementById('conflictColHeader').style.display = hasConflicts ? '' : 'none';
  document.getElementById('conflictNotice').style.display    = hasConflicts ? '' : 'none';
  document.getElementById('conflictBadge').style.display     = hasConflicts ? '' : 'none';
  if (hasConflicts) document.getElementById('conflictBadge').textContent = conflicts.length + ' conflict(s)';
  document.getElementById('previewCountBadge').textContent = items.length + ' endpoint(s)';

  const conflictMap = {};
  conflictDetails.forEach(c => { conflictMap[c.key] = c; });

  tbody.innerHTML = items.map(item => {
    const isConflict = conflicts.includes(item.key);
    const conflictInfo = conflictMap[item.key];
    const conflictTd = hasConflicts
      ? (isConflict
          ? `<td>
              <select class="form-select form-select-sm dark-input resolution-sel" data-key="${escHtml(item.key)}" style="font-size:.78rem;width:auto">
                <option value="REUSE">♻️ Reuse existing</option>
                <option value="CREATE_NEW">➕ Create new copy</option>
              </select>
              <small class="text-muted d-block mt-1">Existing: <em>${escHtml(conflictInfo ? conflictInfo.existingName : '?')}</em></small>
             </td>`
          : `<td class="text-muted" style="font-size:.8rem">No conflict</td>`)
      : '';
    return `<tr class="${isConflict ? 'conflict-row' : ''}">
      <td><input type="checkbox" class="preview-chk" value="${escHtml(item.key)}" checked onchange="updatePreviewCount()"/></td>
      <td><span class="method-badge badge-${item.method}">${item.method}</span></td>
      <td><code style="color:#c4b5fd">${escHtml(item.path)}</code></td>
      <td class="text-muted">${escHtml(item.name || '')}${item.scenarioName ? '<br/><small class="text-info">Scenario: ' + escHtml(item.scenarioName) + '</small>' : ''}</td>
      ${conflictTd}
    </tr>`;
  }).join('');

  updatePreviewCount();
}

function toggleAllPreview(checked) {
  document.querySelectorAll('.preview-chk').forEach(c => c.checked = checked);
  updatePreviewCount();
}

function updatePreviewCount() {
  const n = document.querySelectorAll('.preview-chk:checked').length;
  document.getElementById('previewSelectedCount').textContent = n + ' selected';
}

function resetImportPreview() {
  document.getElementById('importPreviewArea').style.display = 'none';
  document.getElementById('importResultMsg').innerHTML = '';
  currentFileContent = ''; previewItems = []; conflictKeys = [];
}

// ============================================================
// IMPORT — Step 2: Selective Import
// ============================================================
function doImportSelective() {
  const selectedKeys = [...document.querySelectorAll('.preview-chk:checked')].map(c => c.value);
  if (!selectedKeys.length) { showInlineMsg('importResultMsg', 'warning', 'Please select at least one endpoint.'); return; }

  const resolutions = {};
  document.querySelectorAll('.resolution-sel').forEach(sel => {
    resolutions[sel.dataset.key] = sel.value;
  });

  // Determine actual type for import
  let importType = currentImportType;
  // If the file was a mockserver JSON with type=scenario, pass that
  if (currentImportType === 'mockserver' && previewItems.length && previewItems[0].scenarioName) {
    importType = 'scenario';
  }

  const body = {
    type: importType,
    fileContent: currentFileContent,
    filename: currentFilename,
    selectedKeys,
    resolutions
  };

  const btn = document.getElementById('importBtn');
  btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Importing...';
  btn.disabled = true;

  fetch('/import-export/import-selective', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify(body)
  }).then(r => r.json()).then(data => {
    btn.innerHTML = '<i class="bi bi-upload me-1"></i>Import Selected';
    btn.disabled = false;
    if (data.error) {
      showInlineMsg('importResultMsg', 'danger', '<i class="bi bi-x-circle me-1"></i>' + data.error);
    } else {
      showInlineMsg('importResultMsg', 'success', '<i class="bi bi-check-circle me-1"></i>' + data.message);
      resetImportPreview();
      document.getElementById('importFile').value = '';
    }
  }).catch(e => {
    btn.innerHTML = '<i class="bi bi-upload me-1"></i>Import Selected';
    btn.disabled = false;
    showInlineMsg('importResultMsg', 'danger', 'Error: ' + e.message);
  });
}

// ============================================================
// CURL IMPORT
// ============================================================
function importCurl() {
  const cmd = document.getElementById('curlInput').value.trim();
  const resultDiv = document.getElementById('curlResult');
  resultDiv.innerHTML = '';
  if (!cmd) {
    resultDiv.innerHTML = '<div class="curl-result danger"><i class="bi bi-exclamation-circle me-1"></i>Please paste a curl command first.</div>';
    return;
  }
  resultDiv.innerHTML = '<div class="text-muted small"><span class="spinner-border spinner-border-sm me-1"></span>Parsing...</div>';
  fetch('/import-export/curl', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ curlCommand: cmd })
  }).then(r => r.json()).then(data => {
    if (data.success) {
      resultDiv.innerHTML = `<div class="curl-result success fade-in">
        <i class="bi bi-check-circle-fill me-2"></i>
        <strong>Created:</strong>
        <span class="method-badge badge-${data.api.httpMethod} ms-2">${data.api.httpMethod}</span>
        <code class="ms-2" style="color:#c4b5fd">${escHtml(data.api.endpointPath)}</code>
        <span class="text-muted ms-2">${escHtml(data.api.name)}</span>
        <a href="/apis" class="btn btn-sm btn-outline-success ms-3" style="font-size:.75rem">View API →</a>
      </div>`;
      document.getElementById('curlInput').value = '';
    } else {
      resultDiv.innerHTML = `<div class="curl-result danger fade-in">
        <i class="bi bi-exclamation-circle-fill me-2"></i><strong>Error:</strong> ${escHtml(data.error)}
      </div>`;
    }
  }).catch(e => {
    resultDiv.innerHTML = `<div class="curl-result danger fade-in"><i class="bi bi-wifi-off me-2"></i>Request failed: ${escHtml(e.message)}</div>`;
  });
}

// ============================================================
// UTILS
// ============================================================
function escHtml(s) {
  if (!s) return '';
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function ts() { return new Date().toISOString().slice(0,19).replace(/[:T]/g,'-'); }

function triggerDownload(blob, name) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = name; a.click();
  URL.revokeObjectURL(url);
}

function showInlineMsg(id, type, html) {
  const colorMap = { success:'#6ee7b7', danger:'#fca5a5', warning:'#fde68a', info:'#7dd3fc' };
  const bgMap    = { success:'rgba(16,185,129,.1)', danger:'rgba(239,68,68,.1)', warning:'rgba(245,158,11,.1)', info:'rgba(59,130,246,.1)' };
  const bdMap    = { success:'rgba(16,185,129,.3)', danger:'rgba(239,68,68,.3)', warning:'rgba(245,158,11,.3)', info:'rgba(59,130,246,.3)' };
  document.getElementById(id).innerHTML = `<span style="color:${colorMap[type]};background:${bgMap[type]};border:1px solid ${bdMap[type]};border-radius:6px;padding:.3rem .7rem;font-size:.85rem;display:inline-block">${html}</span>`;
}

// ============================================================
// INIT
// ============================================================
document.addEventListener('DOMContentLoaded', () => {
  setExportMode('apis');
});
</script>
</body>
</html>
