<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="description" content="Scenario Detail - Configure which responses to activate when this scenario is active."/>
<title>Scenario Detail - Mock Server</title>
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
  .dark-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 14px; overflow: hidden; }
  .dark-card .card-header { background: transparent; border-bottom: 1px solid #2a2d3e; font-weight: 600; color: #fff; padding: 1rem 1.2rem; }
  .dark-table { background: transparent; color: #c0c0c0; margin: 0; }
  .dark-table thead th { background: #252840; border-bottom: 1px solid #2a2d3e; color: #8890a4; font-size: .78rem; text-transform: uppercase; letter-spacing: .8px; padding: 1rem 1.2rem; }
  .dark-table tbody tr { border-bottom: 1px solid #1e2235; transition: background .15s; }
  .dark-table tbody tr:hover { background: rgba(99,102,241,.08); }
  .dark-table td { padding: 1rem 1.2rem; vertical-align: middle; }
  .dark-select { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); }
  .modal-content { background: #1a1d2e; border: 1px solid #2a2d3e; }
  .modal-header { border-bottom: 1px solid #2a2d3e; }
  .modal-footer { border-top: 1px solid #2a2d3e; }
  label { color: #8890a4; font-size: .82rem; font-weight: 500; }
</style>
<%@ include file="theme.jsp" %>
</head>
<body>
<div class="sidebar d-flex flex-column">
  <div class="brand"><i class="bi bi-server me-2"></i>Mock Server</div>
  <nav class="nav flex-column mt-2">
    <a href="/dashboard" class="nav-link"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a>
    <a href="/apis" class="nav-link"><i class="bi bi-list-ul me-2"></i>APIs</a>
    <a href="/scenarios" class="nav-link active"><i class="bi bi-diagram-3 me-2"></i>Scenarios</a>
    <a href="/logs" class="nav-link"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy" class="nav-link"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings" class="nav-link"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>
<div class="main-content">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <div class="d-flex align-items-center gap-2">
      <a href="/scenarios" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back</a>
      <h1 class="mb-0 text-white" style="font-size:1.6rem;font-weight:700;">${scenario.name}</h1>
      <c:if test="${scenario.active}">
        <span class="badge bg-success ms-2">Active</span>
      </c:if>
    </div>
    <button class="btn btn-primary" onclick="openAddMappingModal()">
      <i class="bi bi-plus-lg me-1"></i>Add API Mapping
    </button>
  </div>

  <div class="dark-card shadow-sm">
    <div class="card-header"><i class="bi bi-diagram-2 me-2"></i>API &rarr; Response Mappings</div>
    <div style="overflow-x:auto;">
      <table class="table table-dark table-hover dark-table">
        <thead>
          <tr>
            <th>Target API</th>
            <th>Forced Response</th>
            <th style="width:100px;text-align:right;">Actions</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="m" items="${scenario.mappings}">
            <tr>
              <td>
                <span class="text-white fw-medium">${m.mockApiName}</span>
              </td>
              <td>
                <span class="badge bg-info text-dark">${m.mockResponseName}</span>
              </td>
              <td style="text-align:right;">
                <button class="btn btn-sm btn-outline-danger" onclick="removeMapping(${m.id})" title="Remove mapping">
                  <i class="bi bi-trash"></i>
                </button>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty scenario.mappings}">
            <tr><td colspan="3" class="text-center text-muted py-5">No mappings added. Add an API mapping to override responses when this scenario is active.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- Add Mapping Modal -->
<div class="modal fade" id="mappingModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-white">Add API Mapping</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label>Select API</label>
          <select class="form-select dark-select" id="mappingApiId" onchange="loadResponses()">
            <option value="">-- Select API --</option>
            <c:forEach var="api" items="${apis}">
              <option value="${api.id}">${api.httpMethod} ${api.endpointPath} - ${api.name}</option>
            </c:forEach>
          </select>
        </div>
        <div class="mb-3">
          <label>Select Response</label>
          <select class="form-select dark-select" id="mappingResponseId">
            <option value="">-- Select Response --</option>
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="addMapping()">Add Mapping</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
var mappingModal = new bootstrap.Modal(document.getElementById('mappingModal'));
var scenarioId = ${scenario.id};

function openAddMappingModal() {
  document.getElementById('mappingApiId').value = '';
  document.getElementById('mappingResponseId').innerHTML = '<option>-- Select Response --</option>';
  mappingModal.show();
}

function loadResponses() {
  var apiId = document.getElementById('mappingApiId').value;
  if (!apiId) return;
  var select = document.getElementById('mappingResponseId');
  select.innerHTML = '<option value="">Loading...</option>';
  $.get('/matchers/api/json/' + apiId, function(matchers) {
    select.innerHTML = '<option value="">-- Select Response --</option>';
    if (!matchers || matchers.length === 0) {
      select.innerHTML = '<option value="">No matchers/responses found for this API</option>';
      return;
    }
    matchers.forEach(function(m) {
      if (m.responses && m.responses.length > 0) {
        m.responses.forEach(function(r) {
          select.innerHTML += '<option value="' + r.id + '">[' + m.name + '] ' + r.name + ' — HTTP ' + r.httpStatus + '</option>';
        });
      }
    });
    if (select.options.length === 1) {
      select.innerHTML = '<option value="">No responses configured yet — add responses to this API first</option>';
    }
  }).fail(function() {
    select.innerHTML = '<option value="">Error loading responses</option>';
  });
}

function addMapping() {
  var apiId = document.getElementById('mappingApiId').value;
  var responseId = document.getElementById('mappingResponseId').value;
  if (!apiId || !responseId) { alert('Please select API and Response'); return; }
  $.ajax({
    url: '/scenarios/api/' + scenarioId + '/mapping',
    method: 'POST',
    contentType: 'application/json',
    data: JSON.stringify({apiId: parseInt(apiId), responseId: parseInt(responseId)}),
    success: function() { location.reload(); },
    error: function(e) { alert('Error: ' + e.responseText); }
  });
}

function removeMapping(id) {
  if (!confirm('Remove this mapping? The response will no longer be forced when this scenario is active.')) return;
  $.ajax({ url: '/scenarios/api/mapping/' + id, method: 'DELETE', success: function() { location.reload(); } });
}
</script>
</body>
</html>
