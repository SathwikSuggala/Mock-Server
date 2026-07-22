<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="description" content="API Detail - Configure matchers and test your mock API endpoint."/>
<title>API Detail - Mock Server</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/codemirror@5.65.16/lib/codemirror.css"/>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/codemirror@5.65.16/theme/material-darker.css"/>
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
  .dark-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 14px; }
  .dark-card .card-header { background: transparent; border-bottom: 1px solid #2a2d3e; font-weight: 600; color: #fff; padding: .9rem 1.2rem; }
  .matcher-card { background: #1e2235; border: 1px solid #2a2d3e; border-radius: 10px; margin-bottom: .75rem;
                  border-left: 4px solid #6366f1; transition: box-shadow .2s; }
  .matcher-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.4); }
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  .dark-select { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); }
  .modal-content { background: #1a1d2e; border: 1px solid #2a2d3e; }
  .modal-header { border-bottom: 1px solid #2a2d3e; }
  .modal-footer { border-top: 1px solid #2a2d3e; }
  label { color: #8890a4; font-size: .82rem; font-weight: 500; }
  .exists-hint { font-size: .75rem; color: #6366f1; margin-top: 3px; cursor: pointer; }
  .exists-hint:hover { color: #a5b4fc; text-decoration: underline; }
  /* Try It panel */
  #tryItPanel { background: #12151f; border: 1px solid #2a2d3e; border-radius: 12px; padding: 1.2rem; }
  .try-response-box { background: #0f1117; border: 1px solid #2a2d3e; border-radius: 8px; padding: .8rem;
                      font-family: monospace; font-size: .82rem; min-height: 80px; white-space: pre-wrap; word-break: break-all; }
  .CodeMirror { background: #12151f; color: #e0e0e0; border: 1px solid #2a2d3e; border-radius: 8px; font-size: .85rem; }
  .format-bar { display: flex; align-items: center; gap: .5rem; margin-bottom: 4px; }
  .format-select { background: #1e2235; border: 1px solid #2a2d3e; color: #a5b4fc; border-radius: 6px; font-size: .78rem; padding: 2px 8px; }
  .json-invalid { border-color: #ef4444 !important; }
  .json-valid { border-color: #22c55e !important; }
</style>
<%@ include file="theme.jsp" %>
</head>
<body>
<div class="sidebar d-flex flex-column">
  <div class="brand"><i class="bi bi-server me-2"></i>Mock Server</div>
  <nav class="nav flex-column mt-2">
    <a href="/dashboard" class="nav-link"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a>
    <a href="/apis" class="nav-link active"><i class="bi bi-list-ul me-2"></i>APIs</a>
    <a href="/scenarios" class="nav-link"><i class="bi bi-diagram-3 me-2"></i>Scenarios</a>
    <a href="/logs" class="nav-link"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy" class="nav-link"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings" class="nav-link"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>
<div class="main-content">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div class="d-flex align-items-center gap-2">
      <a href="/apis" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
      <span class="badge bg-primary fs-6">${api.httpMethod}</span>
      <code class="fs-5 text-light">${api.endpointPath}</code>
      <span class="text-muted">${api.name}</span>
    </div>
    <div class="d-flex gap-2">
      <button class="btn btn-outline-info btn-sm" onclick="toggleTryIt()">
        <i class="bi bi-play-circle me-1"></i>Try It
      </button>
      <button class="btn btn-success btn-sm" onclick="openMatcherModal()">
        <i class="bi bi-plus-lg me-1"></i>Add Matcher
      </button>
    </div>
  </div>

  <!-- Try It Panel -->
  <div id="tryItPanel" class="mb-3" style="display:none;">
    <h6 class="text-white mb-3"><i class="bi bi-play-circle me-2"></i>API Request Tester</h6>
    <div class="row g-2 mb-2">
      <div class="col-md-2">
        <select id="tryMethod" class="form-select dark-select">
          <option>${api.httpMethod}</option>
          <option>GET</option><option>POST</option><option>PUT</option><option>DELETE</option><option>PATCH</option>
        </select>
      </div>
      <div class="col-md-7">
        <input type="text" id="tryPath" class="form-control dark-input" value="/mock${api.endpointPath}" placeholder="/mock/path"/>
      </div>
      <div class="col-md-3">
        <button class="btn btn-primary w-100" onclick="runTryIt()">
          <i class="bi bi-send me-1"></i>Send
        </button>
      </div>
    </div>
    <div class="row g-2 mb-2">
      <div class="col-md-6">
        <label>Headers (JSON)</label>
        <textarea id="tryHeaders" class="form-control dark-input font-monospace" rows="2" placeholder='{"Content-Type":"application/json"}'></textarea>
      </div>
      <div class="col-md-6">
        <div class="format-bar">
          <label class="mb-0">Request Body</label>
          <select id="tryBodyFormat" class="format-select" onchange="onTryBodyFormatChange()">
            <option value="json">JSON</option>
            <option value="text">Plain Text</option>
            <option value="xml">XML</option>
          </select>
          <span id="tryBodyStatus" class="badge" style="font-size:.7rem;"></span>
        </div>
        <textarea id="tryBody" class="form-control dark-input font-monospace" rows="2" placeholder="Request body..."></textarea>
      </div>
    </div>
    <div class="row g-2">
      <div class="col-12">
        <label>Response</label>
        <div id="tryResponse" class="try-response-box text-muted">Hit Send to see response...</div>
        <div class="d-flex gap-3 mt-1">
          <small id="tryStatus" class="text-muted"></small>
          <small id="tryTime" class="text-muted"></small>
        </div>
      </div>
    </div>
  </div>

  <div class="row g-3">
    <div class="col-md-3">
      <div class="dark-card">
        <div class="card-header">API Info</div>
        <div class="card-body">
          <p class="mb-1"><span class="text-muted">Description:</span><br/>${api.description}</p>
          <p class="mb-1"><span class="text-muted">Tags:</span> ${api.tags}</p>
          <p class="mb-2"><span class="text-muted">Status:</span>
            <span class="badge ${api.enabled ? 'bg-success' : 'bg-secondary'}">${api.enabled ? 'Enabled' : 'Disabled'}</span>
          </p>
          <div class="d-flex align-items-center gap-1 bg-dark rounded p-2">
            <code style="font-size:.75rem;color:#a5b4fc;">GET /mock${api.endpointPath}</code>
            <button class="btn btn-sm p-0 ms-auto text-muted" onclick="copyMockUrl()" title="Copy URL">
              <i class="bi bi-clipboard"></i>
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-9">
      <div class="dark-card">
        <div class="card-header d-flex justify-content-between">
          <span>Request Matchers</span>
          <small class="text-muted" style="font-weight:400;">Higher priority wins</small>
        </div>
        <div class="card-body p-2" id="matcherList">
          <c:forEach var="matcher" items="${api.matchers}">
            <div class="matcher-card p-3">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <strong class="text-white">${matcher.name}</strong>
                  <span class="badge bg-dark text-light ms-2">P:${matcher.priority}</span>
                  <span class="badge ${matcher.enabled ? 'bg-success' : 'bg-secondary'} ms-1">${matcher.enabled ? 'Enabled' : 'Disabled'}</span>
                  <span class="badge bg-info text-dark ms-1">${matcher.responseSelectionMode}</span>
                  <c:if test="${matcher.rateLimitRpm > 0}">
                    <span class="badge bg-warning text-dark ms-1"><i class="bi bi-speedometer me-1"></i>${matcher.rateLimitRpm} RPM</span>
                  </c:if>
                  <br/><small class="text-muted">${matcher.description}</small>
                </div>
                <div class="d-flex gap-1">
                  <a href="/responses/matcher/${matcher.id}" class="btn btn-sm btn-outline-info" title="Manage Responses">
                    <i class="bi bi-reply-all"></i>
                  </a>
                  <button class="btn btn-sm btn-outline-warning" onclick="editMatcher(${matcher.id})" title="Edit">
                    <i class="bi bi-pencil"></i>
                  </button>
                  <button class="btn btn-sm btn-outline-secondary" onclick="cloneMatcher(${matcher.id})" title="Clone">
                    <i class="bi bi-copy"></i>
                  </button>
                  <button class="btn btn-sm btn-outline-danger" onclick="deleteMatcher(${matcher.id})" title="Delete">
                    <i class="bi bi-trash"></i>
                  </button>
                </div>
              </div>
            </div>
          </c:forEach>
          <c:if test="${empty api.matchers}">
            <div class="text-center text-muted py-4">No matchers yet. Click "Add Matcher" to create one.</div>
          </c:if>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Matcher Modal -->
<div class="modal fade" id="matcherModal" tabindex="-1">
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-white" id="matcherModalTitle">Add Matcher</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="matcherId"/>
        <div class="row g-3">
          <div class="col-md-4">
            <label>Name *</label>
            <input type="text" class="form-control dark-input" id="matcherName" required/>
          </div>
          <div class="col-md-2">
            <label>Priority</label>
            <input type="number" class="form-control dark-input" id="matcherPriority" value="0"/>
          </div>
          <div class="col-md-3">
            <label>Response Mode</label>
            <select class="form-select dark-select" id="matcherMode">
              <option value="MANUAL">Manual</option>
              <option value="RANDOM">Random (Weighted)</option>
              <option value="SEQUENTIAL">Sequential</option>
            </select>
          </div>
          <div class="col-md-2">
            <label>Rate Limit (RPM)</label>
            <input type="number" class="form-control dark-input" id="matcherRateLimit" value="0" min="0" title="Max requests per minute. 0 = unlimited."/>
          </div>
          <div class="col-md-1">
            <label>Enabled</label>
            <div class="form-check mt-2">
              <input class="form-check-input" type="checkbox" id="matcherEnabled" checked/>
            </div>
          </div>
          <div class="col-md-12">
            <label>Description</label>
            <input type="text" class="form-control dark-input" id="matcherDescription"/>
          </div>

          <!-- Match Headers -->
          <div class="col-md-6">
            <div class="d-flex justify-content-between align-items-center mb-1">
              <label class="mb-0">Match Headers (JSON)</label>
              <span class="exists-hint" onclick="insertExists('matcherHeaders')">+ Add exists-only check</span>
            </div>
            <textarea class="form-control dark-input font-monospace" id="matcherHeaders" rows="3"
              placeholder='{"x-api-key": "abc123", "x-user-id": "*"}'></textarea>
            <div class="text-muted" style="font-size:.72rem;margin-top:3px;">Use <code>*</code> or <code>__EXISTS__</code> as value to check key exists regardless of value</div>
          </div>

          <!-- Match Query Params -->
          <div class="col-md-6">
            <div class="d-flex justify-content-between align-items-center mb-1">
              <label class="mb-0">Match Query Params (JSON)</label>
              <span class="exists-hint" onclick="insertExists('matcherQuery')">+ Add exists-only check</span>
            </div>
            <textarea class="form-control dark-input font-monospace" id="matcherQuery" rows="3"
              placeholder='{"status": "active", "filter": "*"}'></textarea>
            <div class="text-muted" style="font-size:.72rem;margin-top:3px;">Use <code>*</code> to check param exists</div>
          </div>

          <!-- Match Path Variables -->
          <div class="col-md-6">
            <div class="d-flex justify-content-between align-items-center mb-1">
              <label class="mb-0">Match Path Variables (JSON)</label>
              <span class="exists-hint" onclick="insertExists('matcherPathVars')">+ Add exists-only check</span>
            </div>
            <textarea class="form-control dark-input font-monospace" id="matcherPathVars" rows="3"
              placeholder='{"id": ".*", "tenantId": "*"}'></textarea>
            <div class="text-muted" style="font-size:.72rem;margin-top:3px;">
              <code>*</code> = variable must exist (any value) &nbsp;|&nbsp; <code>.*</code> = regex wildcard &nbsp;|&nbsp; <code>123</code> = exact match
            </div>
          </div>

          <!-- Body match type + body -->
          <div class="col-md-3">
            <label>Body Match Type</label>
            <select class="form-select dark-select" id="matcherBodyType">
              <option value="CONTAINS">Contains</option>
              <option value="EXACT">Exact</option>
              <option value="REGEX">Regex</option>
              <option value="JSONPATH">JSONPath</option>
              <option value="GRAPHQL_OPERATION">GraphQL Operation</option>
            </select>
            <div id="bodyTypeHint" class="text-muted mt-1" style="font-size:.72rem;"></div>
          </div>
          <div class="col-md-9">
            <div class="format-bar">
              <label class="mb-0">Match Body</label>
              <select id="matcherBodyFormat" class="format-select" onchange="onBodyFormatChange()">
                <option value="text">Plain Text</option>
                <option value="json">JSON</option>
                <option value="xml">XML</option>
              </select>
              <span id="bodyFormatStatus" class="badge" style="font-size:.7rem;"></span>
            </div>
            <textarea class="form-control dark-input font-monospace" id="matcherBody" rows="4"
              placeholder="Enter value to match in request body"></textarea>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="saveMatcher()">Save Matcher</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
var matcherModal = new bootstrap.Modal(document.getElementById('matcherModal'));
var apiId = ${api.id};
var apiMethod = '${api.httpMethod}';
var apiPath = '${api.endpointPath}';
var tryItVisible = false;

// Body type hints
var bodyTypeHints = {
  'CONTAINS': 'Body must contain this substring.',
  'EXACT': 'Body must match exactly.',
  'REGEX': 'Body must match this Java regex.',
  'JSONPATH': 'Use format: $.field=value (e.g. $.action=login)',
  'GRAPHQL_OPERATION': 'Enter the GraphQL operationName to match.'
};
document.getElementById('matcherBodyType').addEventListener('change', function() {
  document.getElementById('bodyTypeHint').textContent = bodyTypeHints[this.value] || '';
});

function toggleTryIt() {
  tryItVisible = !tryItVisible;
  document.getElementById('tryItPanel').style.display = tryItVisible ? 'block' : 'none';
}

function copyMockUrl() {
  var url = window.location.origin + '/mock' + apiPath;
  navigator.clipboard.writeText(url);
}

// Try It: body format
function onTryBodyFormatChange() {
  var fmt = document.getElementById('tryBodyFormat').value;
  var body = document.getElementById('tryBody').value;
  var status = document.getElementById('tryBodyStatus');
  if (fmt === 'json' && body.trim()) {
    try { JSON.parse(body); status.className = 'badge bg-success'; status.textContent = '✓ Valid JSON'; }
    catch(e) { status.className = 'badge bg-danger'; status.textContent = '✗ Invalid JSON'; }
  } else { status.textContent = ''; }
}
document.getElementById('tryBody').addEventListener('input', onTryBodyFormatChange);

function runTryIt() {
  var method = document.getElementById('tryMethod').value;
  var path = document.getElementById('tryPath').value;
  var headersRaw = document.getElementById('tryHeaders').value;
  var body = document.getElementById('tryBody').value;
  var start = Date.now();

  var headers = { 'Content-Type': 'application/json' };
  if (headersRaw.trim()) {
    try { Object.assign(headers, JSON.parse(headersRaw)); } catch(e) {}
  }

  var opts = { method: method, headers: headers };
  if (method !== 'GET' && method !== 'HEAD' && body) opts.body = body;

  document.getElementById('tryResponse').textContent = 'Sending...';
  document.getElementById('tryStatus').textContent = '';

  fetch(path, opts).then(function(r) {
    var elapsed = Date.now() - start;
    document.getElementById('tryStatus').textContent = '→ HTTP ' + r.status;
    document.getElementById('tryStatus').className = r.ok ? 'text-success small' : 'text-danger small';
    document.getElementById('tryTime').textContent = elapsed + 'ms';
    return r.text();
  }).then(function(txt) {
    try { txt = JSON.stringify(JSON.parse(txt), null, 2); } catch(e) {}
    document.getElementById('tryResponse').textContent = txt;
  }).catch(function(e) {
    document.getElementById('tryResponse').textContent = 'Error: ' + e.message;
  });
}

// Matcher body format validation
function onBodyFormatChange() {
  var fmt = document.getElementById('matcherBodyFormat').value;
  var body = document.getElementById('matcherBody').value;
  var status = document.getElementById('bodyFormatStatus');
  if (fmt === 'json' && body.trim()) {
    try { JSON.parse(body); status.className = 'badge bg-success'; status.textContent = '✓ Valid JSON'; }
    catch(e) { status.className = 'badge bg-danger'; status.textContent = '✗ Invalid JSON'; }
  } else { status.textContent = ''; }
}
document.getElementById('matcherBody').addEventListener('input', onBodyFormatChange);

// Insert exists-only check helper
function insertExists(fieldId) {
  var el = document.getElementById(fieldId);
  var val = el.value.trim();
  var key = prompt('Enter the key name to add an "exists" check for:');
  if (!key) return;
  try {
    var obj = val ? JSON.parse(val) : {};
    obj[key] = '*';
    el.value = JSON.stringify(obj, null, 2);
  } catch(e) {
    el.value = '{"' + key + '": "*"}';
  }
}

function openMatcherModal() {
  document.getElementById('matcherId').value = '';
  document.getElementById('matcherName').value = '';
  document.getElementById('matcherPriority').value = '0';
  document.getElementById('matcherMode').value = 'MANUAL';
  document.getElementById('matcherEnabled').checked = true;
  document.getElementById('matcherDescription').value = '';
  document.getElementById('matcherHeaders').value = '';
  document.getElementById('matcherQuery').value = '';
  document.getElementById('matcherPathVars').value = '';
  document.getElementById('matcherBody').value = '';
  document.getElementById('matcherBodyType').value = 'CONTAINS';
  document.getElementById('matcherRateLimit').value = '0';
  document.getElementById('bodyFormatStatus').textContent = '';
  document.getElementById('bodyTypeHint').textContent = '';
  document.getElementById('matcherModalTitle').textContent = 'Add Matcher';
  matcherModal.show();
}

function editMatcher(id) {
  $.get('/matchers/' + id + '/json', function(m) {
    document.getElementById('matcherId').value = m.id;
    document.getElementById('matcherName').value = m.name || '';
    document.getElementById('matcherPriority').value = m.priority;
    document.getElementById('matcherMode').value = m.responseSelectionMode || 'MANUAL';
    document.getElementById('matcherEnabled').checked = m.enabled;
    document.getElementById('matcherDescription').value = m.description || '';
    document.getElementById('matcherHeaders').value = m.matchHeaders || '';
    document.getElementById('matcherQuery').value = m.matchQueryParams || '';
    document.getElementById('matcherPathVars').value = m.matchPathVariables || '';
    document.getElementById('matcherBody').value = m.matchBody || '';
    document.getElementById('matcherBodyType').value = m.matchBodyType || 'CONTAINS';
    document.getElementById('matcherRateLimit').value = m.rateLimitRpm || 0;
    document.getElementById('bodyTypeHint').textContent = bodyTypeHints[m.matchBodyType] || '';
    document.getElementById('matcherModalTitle').textContent = 'Edit Matcher';
    matcherModal.show();
  });
}

function cloneMatcher(id) {
  $.post('/matchers/' + id + '/clone', function() { location.reload(); })
   .fail(function(e) { alert('Error: ' + e.responseText); });
}

function saveMatcher() {
  var id = document.getElementById('matcherId').value;
  var data = {
    mockApiId: apiId,
    name: document.getElementById('matcherName').value,
    priority: parseInt(document.getElementById('matcherPriority').value),
    responseSelectionMode: document.getElementById('matcherMode').value,
    enabled: document.getElementById('matcherEnabled').checked,
    description: document.getElementById('matcherDescription').value,
    matchHeaders: document.getElementById('matcherHeaders').value || null,
    matchQueryParams: document.getElementById('matcherQuery').value || null,
    matchPathVariables: document.getElementById('matcherPathVars').value || null,
    matchBody: document.getElementById('matcherBody').value || null,
    matchBodyType: document.getElementById('matcherBodyType').value,
    rateLimitRpm: parseInt(document.getElementById('matcherRateLimit').value) || 0
  };
  var url = id ? '/matchers/' + id : '/matchers/api';
  var method = id ? 'PUT' : 'POST';
  $.ajax({ url: url, method: method, contentType: 'application/json', data: JSON.stringify(data),
    success: function() { location.reload(); },
    error: function(e) { alert('Error: ' + e.responseText); }
  });
}

function deleteMatcher(id) {
  if (!confirm('Delete this matcher and all its responses?')) return;
  $.ajax({ url: '/matchers/' + id, method: 'DELETE', success: function() { location.reload(); } });
}
</script>
</body>
</html>
