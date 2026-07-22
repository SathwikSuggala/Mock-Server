<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="description" content="Manage mock responses - configure response body, headers, delays, webhooks and more."/>
<title>Responses - Mock Server</title>
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
  .resp-card { background: #1e2235; border: 1px solid #2a2d3e; border-radius: 10px; margin-bottom: .75rem;
               transition: box-shadow .2s; }
  .resp-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.4); }
  .resp-card.active-resp { border-left: 4px solid #22c55e; }
  .resp-card.inactive-resp { border-left: 4px solid #374151; }
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  .dark-select { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); }
  .modal-content { background: #1a1d2e; border: 1px solid #2a2d3e; }
  .modal-header { border-bottom: 1px solid #2a2d3e; }
  .modal-footer { border-top: 1px solid #2a2d3e; }
  label { color: #8890a4; font-size: .82rem; font-weight: 500; }
  .CodeMirror { background: #12151f; color: #e0e0e0; border: 1px solid #2a2d3e; border-radius: 8px; font-size: .85rem; }
  .format-bar { display: flex; align-items: center; gap: .5rem; margin-bottom: 4px; }
  .format-select { background: #1e2235; border: 1px solid #2a2d3e; color: #a5b4fc; border-radius: 6px; font-size: .78rem; padding: 2px 8px; }
  .section-header { background: #252840; border-radius: 8px; padding: .5rem .8rem; margin-bottom: .5rem;
                    font-size: .8rem; color: #a5b4fc; font-weight: 600; cursor: pointer; user-select: none; }
  .section-header i { transition: transform .2s; }
  .var-hint { background: #1e2235; border: 1px solid #2a2d3e; border-radius: 8px; padding: .6rem .8rem; font-size: .75rem; color: #8890a4; }
  .var-hint code { color: #fb923c; cursor: pointer; }
  .var-hint code:hover { color: #fbbf24; }
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
      <a href="/apis/${matcher.mockApiId}" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
      <strong class="text-white">Responses for Matcher:</strong>
      <span class="text-light">${matcher.name}</span>
      <span class="badge bg-info text-dark">${matcher.responseSelectionMode}</span>
    </div>
    <button class="btn btn-primary btn-sm" onclick="openCreateModal()">
      <i class="bi bi-plus-lg me-1"></i>Add Response
    </button>
  </div>

  <div id="responseCards">
    <c:forEach var="resp" items="${responses}">
      <div class="resp-card ${resp.active ? 'active-resp' : 'inactive-resp'} p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div class="d-flex align-items-center gap-2 flex-wrap">
            <input type="radio" name="activeResponse" value="${resp.id}"
              ${resp.active ? 'checked' : ''} onchange="setActive(${matcher.id}, ${resp.id})"
              class="form-check-input mt-0" style="width:1.1rem;height:1.1rem;cursor:pointer;"/>
            <strong class="text-white">${resp.name}</strong>
            <span class="badge bg-${resp.httpStatus < 300 ? 'success' : resp.httpStatus < 400 ? 'warning' : 'danger'}">${resp.httpStatus}</span>
            <span class="badge ${resp.active ? 'bg-success' : 'bg-secondary'}">${resp.active ? 'Active' : 'Inactive'}</span>
            <span class="badge bg-dark text-light">W:${resp.weight}</span>
            <c:if test="${not empty resp.faultType}">
              <span class="badge bg-danger"><i class="bi bi-exclamation-triangle me-1"></i>${resp.faultType}</span>
            </c:if>
            <c:if test="${resp.delayMs > 0}">
              <span class="badge bg-warning text-dark"><i class="bi bi-hourglass-split me-1"></i>${resp.delayMs}ms</span>
            </c:if>
            <c:if test="${not empty resp.webhookUrl}">
              <span class="badge bg-indigo" style="background:#6366f1!important;" title="${resp.webhookUrl}"><i class="bi bi-webhook me-1"></i>Webhook</span>
            </c:if>
            <br class="d-none d-md-block"/>
            <small class="text-muted">${resp.description}</small>
            <small class="text-muted ms-2" style="font-size:.72rem;">${resp.contentType}</small>
          </div>
          <div class="d-flex gap-1 ms-2">
            <button class="btn btn-sm btn-outline-primary" onclick="previewBody(${resp.id})" title="Preview Body">
              <i class="bi bi-eye"></i>
            </button>
            <button class="btn btn-sm btn-outline-warning" onclick="editResponse(${resp.id})" title="Edit">
              <i class="bi bi-pencil"></i>
            </button>
            <button class="btn btn-sm btn-outline-secondary" onclick="cloneResponse(${resp.id})" title="Clone">
              <i class="bi bi-copy"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger" onclick="deleteResponse(${resp.id})" title="Delete">
              <i class="bi bi-trash"></i>
            </button>
          </div>
        </div>
      </div>
    </c:forEach>
    <c:if test="${empty responses}">
      <div class="text-center text-muted py-5">No responses yet. Click "Add Response" to create one.</div>
    </c:if>
  </div>
</div>

<!-- Response Modal -->
<div class="modal fade" id="responseModal" tabindex="-1">
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-white" id="responseModalTitle">Add Response</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="responseId"/>
        <div class="row g-3">
          <!-- Basic -->
          <div class="col-md-4"><label>Name *</label>
            <input type="text" class="form-control dark-input" id="respName"/></div>
          <div class="col-md-2"><label>HTTP Status</label>
            <input type="number" class="form-control dark-input" id="respStatus" value="200"/></div>
          <div class="col-md-3"><label>Content Type</label>
            <select class="form-select dark-select" id="respContentType" onchange="onContentTypeChange()">
              <option value="application/json">application/json</option>
              <option value="text/plain">text/plain</option>
              <option value="text/xml">text/xml</option>
              <option value="application/xml">application/xml</option>
              <option value="text/html">text/html</option>
            </select>
          </div>
          <div class="col-md-2"><label>Weight</label>
            <input type="number" class="form-control dark-input" id="respWeight" value="100"/></div>
          <div class="col-md-1 d-flex align-items-end pb-1">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="respEnabled" checked/>
              <label class="form-check-label">On</label>
            </div>
          </div>

          <!-- Delay & Fault -->
          <div class="col-md-3"><label>Delay Type</label>
            <select class="form-select dark-select" id="respDelayType">
              <option value="FIXED">Fixed</option>
              <option value="RANDOM">Random</option>
            </select>
          </div>
          <div class="col-md-2"><label>Delay (ms)</label>
            <input type="number" class="form-control dark-input" id="respDelayMs" value="0"/></div>
          <div class="col-md-2"><label>Max Delay</label>
            <input type="number" class="form-control dark-input" id="respDelayMaxMs" value="0"/></div>
          <div class="col-md-3"><label>Fault Simulation</label>
            <select class="form-select dark-select" id="respFaultType">
              <option value="">None</option>
              <option value="TIMEOUT">Timeout</option>
              <option value="EMPTY_RESPONSE">Empty Response</option>
              <option value="CONNECTION_RESET">Connection Reset</option>
            </select>
          </div>
          <div class="col-md-12"><label>Description</label>
            <input type="text" class="form-control dark-input" id="respDescription"/></div>

          <!-- Headers & Cookies -->
          <div class="col-md-6"><label>Response Headers (JSON)</label>
            <textarea class="form-control dark-input font-monospace" id="respHeaders" rows="2"
              placeholder='{"X-Custom-Header": "value"}'></textarea></div>
          <div class="col-md-6"><label>Cookies (JSON)</label>
            <textarea class="form-control dark-input font-monospace" id="respCookies" rows="2"
              placeholder='{"session": "abc123"}'></textarea></div>

          <!-- Response Body with format dropdown -->
          <div class="col-md-12">
            <div class="format-bar">
              <label class="mb-0">Response Body</label>
              <select id="respBodyFormat" class="format-select" onchange="onBodyFormatChange()">
                <option value="json">JSON</option>
                <option value="text">Plain Text</option>
                <option value="xml">XML</option>
                <option value="html">HTML</option>
              </select>
              <span id="bodyFormatStatus" class="badge" style="font-size:.7rem;"></span>
              <button type="button" class="btn btn-sm btn-outline-secondary ms-auto" style="font-size:.75rem;padding:2px 8px;" onclick="formatJson()">
                <i class="bi bi-braces me-1"></i>Format JSON
              </button>
            </div>
            <textarea class="form-control dark-input font-monospace" id="respBody" rows="8"></textarea>
            <div class="var-hint mt-2">
              Dynamic variables:
              <code onclick="insertVar('\${uuid}')">$&#123;uuid&#125;</code>
              <code onclick="insertVar('\${currentTimestamp}')">$&#123;currentTimestamp&#125;</code>
              <code onclick="insertVar('\${request.body.field}')">$&#123;request.body.field&#125;</code>
              <code onclick="insertVar('\${request.path.id}')">$&#123;request.path.id&#125;</code>
              <code onclick="insertVar('\${request.query.param}')">$&#123;request.query.param&#125;</code>
              <code onclick="insertVar('\${faker.name}')">$&#123;faker.name&#125;</code>
              <code onclick="insertVar('\${faker.email}')">$&#123;faker.email&#125;</code>
              <code onclick="insertVar('\${faker.int(1,100)}')">$&#123;faker.int(1,100)&#125;</code>
              <code onclick="insertVar('\${faker.alphanumeric(8)}')">$&#123;faker.alphanumeric(8)&#125;</code>
            </div>
          </div>

          <!-- Webhook section -->
          <div class="col-md-12">
            <div class="section-header" onclick="toggleWebhook()" id="webhookHeader">
              <i class="bi bi-chevron-right me-2" id="webhookChevron"></i>Webhook / Callback Configuration (optional)
            </div>
            <div id="webhookSection" style="display:none;">
              <div class="row g-2">
                <div class="col-md-8"><label>Webhook URL</label>
                  <input type="text" class="form-control dark-input" id="webhookUrl" placeholder="https://your-callback-server.com/webhook"/></div>
                <div class="col-md-4"><label>Delay before firing (ms)</label>
                  <input type="number" class="form-control dark-input" id="webhookDelayMs" value="0"/></div>
                <div class="col-md-12"><label>Webhook Body (leave empty to send response body)</label>
                  <textarea class="form-control dark-input font-monospace" id="webhookBody" rows="3"
                    placeholder='{"event": "response_sent", "data": {...}}'></textarea></div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="saveResponse()">Save Response</button>
      </div>
    </div>
  </div>
</div>

<!-- Preview Modal -->
<div class="modal fade" id="previewModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-white">Response Body Preview</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <pre id="previewBody" style="background:#12151f;color:#a5b4fc;border-radius:8px;padding:1rem;max-height:500px;overflow:auto;font-size:.85rem;"></pre>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
var responseModal = new bootstrap.Modal(document.getElementById('responseModal'));
var previewModal = new bootstrap.Modal(document.getElementById('previewModal'));
var matcherId = ${matcher.id};
var webhookOpen = false;

function toggleWebhook() {
  webhookOpen = !webhookOpen;
  document.getElementById('webhookSection').style.display = webhookOpen ? 'block' : 'none';
  document.getElementById('webhookChevron').style.transform = webhookOpen ? 'rotate(90deg)' : '';
}

function onContentTypeChange() {
  var ct = document.getElementById('respContentType').value;
  var fmt = 'text';
  if (ct.includes('json')) fmt = 'json';
  else if (ct.includes('xml')) fmt = 'xml';
  else if (ct.includes('html')) fmt = 'html';
  document.getElementById('respBodyFormat').value = fmt;
  onBodyFormatChange();
}

function onBodyFormatChange() {
  var fmt = document.getElementById('respBodyFormat').value;
  var body = document.getElementById('respBody').value;
  var status = document.getElementById('bodyFormatStatus');
  if (fmt === 'json' && body.trim()) {
    try { JSON.parse(body); status.className = 'badge bg-success'; status.textContent = '✓ Valid JSON'; }
    catch(e) { status.className = 'badge bg-danger'; status.textContent = '✗ Invalid JSON: ' + e.message.split(' at ')[0]; }
  } else { status.textContent = ''; status.className = 'badge'; }
}
document.getElementById('respBody').addEventListener('input', onBodyFormatChange);

function formatJson() {
  var body = document.getElementById('respBody').value.trim();
  if (!body) return;
  try {
    document.getElementById('respBody').value = JSON.stringify(JSON.parse(body), null, 2);
    onBodyFormatChange();
  } catch(e) { alert('Not valid JSON: ' + e.message); }
}

function insertVar(v) {
  var el = document.getElementById('respBody');
  var pos = el.selectionStart;
  var before = el.value.substring(0, pos);
  var after = el.value.substring(pos);
  el.value = before + v + after;
  el.focus();
  el.setSelectionRange(pos + v.length, pos + v.length);
}

function openCreateModal() {
  clearForm();
  document.getElementById('responseModalTitle').textContent = 'Add Response';
  responseModal.show();
}

function clearForm() {
  document.getElementById('responseId').value = '';
  document.getElementById('respName').value = '';
  document.getElementById('respStatus').value = '200';
  document.getElementById('respContentType').value = 'application/json';
  document.getElementById('respWeight').value = '100';
  document.getElementById('respEnabled').checked = true;
  document.getElementById('respDelayType').value = 'FIXED';
  document.getElementById('respDelayMs').value = '0';
  document.getElementById('respDelayMaxMs').value = '0';
  document.getElementById('respFaultType').value = '';
  document.getElementById('respDescription').value = '';
  document.getElementById('respHeaders').value = '';
  document.getElementById('respCookies').value = '';
  document.getElementById('respBody').value = '';
  document.getElementById('respBodyFormat').value = 'json';
  document.getElementById('bodyFormatStatus').textContent = '';
  document.getElementById('webhookUrl').value = '';
  document.getElementById('webhookDelayMs').value = '0';
  document.getElementById('webhookBody').value = '';
}

function editResponse(id) {
  $.get('/responses/' + id + '/json', function(r) {
    document.getElementById('responseId').value = r.id;
    document.getElementById('respName').value = r.name || '';
    document.getElementById('respStatus').value = r.httpStatus;
    document.getElementById('respContentType').value = r.contentType || 'application/json';
    document.getElementById('respWeight').value = r.weight;
    document.getElementById('respEnabled').checked = r.enabled;
    document.getElementById('respDelayType').value = r.delayType || 'FIXED';
    document.getElementById('respDelayMs').value = r.delayMs;
    document.getElementById('respDelayMaxMs').value = r.delayMaxMs;
    document.getElementById('respFaultType').value = r.faultType || '';
    document.getElementById('respDescription').value = r.description || '';
    document.getElementById('respHeaders').value = r.responseHeaders || '';
    document.getElementById('respCookies').value = r.responseCookies || '';
    document.getElementById('respBody').value = r.responseBody || '';
    document.getElementById('webhookUrl').value = r.webhookUrl || '';
    document.getElementById('webhookDelayMs').value = r.webhookDelayMs || 0;
    document.getElementById('webhookBody').value = r.webhookBody || '';
    // Set format based on content type
    var fmt = 'text';
    if ((r.contentType || '').includes('json')) fmt = 'json';
    else if ((r.contentType || '').includes('xml')) fmt = 'xml';
    else if ((r.contentType || '').includes('html')) fmt = 'html';
    document.getElementById('respBodyFormat').value = fmt;
    onBodyFormatChange();
    // Show webhook section if configured
    if (r.webhookUrl) { webhookOpen = false; toggleWebhook(); }
    document.getElementById('responseModalTitle').textContent = 'Edit Response';
    responseModal.show();
  });
}

function cloneResponse(id) {
  $.post('/responses/' + id + '/clone', function() { location.reload(); })
   .fail(function(e) { alert('Error: ' + e.responseText); });
}

function saveResponse() {
  var id = document.getElementById('responseId').value;
  var data = {
    requestMatcherId: matcherId,
    name: document.getElementById('respName').value,
    httpStatus: parseInt(document.getElementById('respStatus').value),
    contentType: document.getElementById('respContentType').value,
    weight: parseInt(document.getElementById('respWeight').value),
    enabled: document.getElementById('respEnabled').checked,
    delayType: document.getElementById('respDelayType').value,
    delayMs: parseInt(document.getElementById('respDelayMs').value),
    delayMaxMs: parseInt(document.getElementById('respDelayMaxMs').value),
    faultType: document.getElementById('respFaultType').value || null,
    description: document.getElementById('respDescription').value,
    responseHeaders: document.getElementById('respHeaders').value || null,
    responseCookies: document.getElementById('respCookies').value || null,
    responseBody: document.getElementById('respBody').value,
    webhookUrl: document.getElementById('webhookUrl').value || null,
    webhookDelayMs: parseInt(document.getElementById('webhookDelayMs').value) || 0,
    webhookBody: document.getElementById('webhookBody').value || null
  };
  // JSON validation if format is json
  if (document.getElementById('respBodyFormat').value === 'json' && data.responseBody && data.responseBody.trim()) {
    try { JSON.parse(data.responseBody); } catch(e) {
      if (!confirm('Response body is not valid JSON. Save anyway?')) return;
    }
  }
  var url = id ? '/responses/' + id : '/responses/api';
  var method = id ? 'PUT' : 'POST';
  $.ajax({ url: url, method: method, contentType: 'application/json', data: JSON.stringify(data),
    success: function() { location.reload(); },
    error: function(e) { alert('Error: ' + e.responseText); }
  });
}

function deleteResponse(id) {
  if (!confirm('Delete this response?')) return;
  $.ajax({ url: '/responses/' + id, method: 'DELETE', success: function() { location.reload(); } });
}

function setActive(matcherId, responseId) {
  $.post('/responses/matcher/' + matcherId + '/active/' + responseId, function() { location.reload(); });
}

function previewBody(id) {
  $.get('/responses/' + id + '/json', function(r) {
    var body = r.responseBody || '(empty)';
    try { body = JSON.stringify(JSON.parse(body), null, 2); } catch(e) {}
    document.getElementById('previewBody').textContent = body;
    previewModal.show();
  });
}
</script>
</body>
</html>
