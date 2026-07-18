<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="description" content="Manage your Mock APIs - Create, edit, clone, and disable mock endpoints."/>
<title>APIs - Mock Server</title>
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
  .dark-table { background: transparent; color: #c0c0c0; margin: 0; }
  .dark-table thead th { background: #252840; border-bottom: 1px solid #2a2d3e; color: #8890a4; font-size: .78rem; text-transform: uppercase; letter-spacing: .8px; padding: 1rem 1.2rem; }
  .dark-table tbody tr { border-bottom: 1px solid #1e2235; transition: background .15s; }
  .dark-table tbody tr:hover { background: rgba(99,102,241,.08); }
  .dark-table td { padding: 1rem 1.2rem; vertical-align: middle; }
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  .dark-select { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); }
  .modal-content { background: #1a1d2e; border: 1px solid #2a2d3e; }
  .modal-header { border-bottom: 1px solid #2a2d3e; }
  .modal-footer { border-top: 1px solid #2a2d3e; }
  label { color: #8890a4; font-size: .82rem; font-weight: 500; }
</style>
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
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1 style="font-size:1.6rem;font-weight:700;color:#fff;"><i class="bi bi-list-ul me-2 text-indigo"></i>APIs</h1>
    <button class="btn btn-primary" onclick="openCreateModal()">
      <i class="bi bi-plus-lg me-1"></i>New API
    </button>
  </div>

  <div class="dark-card shadow-sm">
    <div style="overflow-x:auto;">
      <table class="table table-dark table-hover dark-table" id="apiTable">
        <thead>
          <tr>
            <th style="width:80px;">Method</th>
            <th>Path</th>
            <th>Name & Description</th>
            <th>Tags</th>
            <th>Status</th>
            <th style="width:180px;text-align:right;">Actions</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="api" items="${apis}">
            <c:set var="mColor" value="secondary"/>
            <c:if test="${api.httpMethod == 'GET'}"><c:set var="mColor" value="success"/></c:if>
            <c:if test="${api.httpMethod == 'POST'}"><c:set var="mColor" value="primary"/></c:if>
            <c:if test="${api.httpMethod == 'PUT'}"><c:set var="mColor" value="warning"/></c:if>
            <c:if test="${api.httpMethod == 'DELETE'}"><c:set var="mColor" value="danger"/></c:if>
            <c:if test="${api.httpMethod == 'PATCH'}"><c:set var="mColor" value="info"/></c:if>
            <tr>
              <td><span class="badge bg-${mColor}" style="font-size:.75rem;">${api.httpMethod}</span></td>
              <td>
                <code style="color:#a5b4fc;font-size:.9rem;">${api.endpointPath}</code>
              </td>
              <td>
                <div class="text-white fw-medium">${api.name}</div>
                <div class="text-muted" style="font-size:.75rem;max-width:300px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                  ${api.description}
                </div>
              </td>
              <td>
                <c:if test="${not empty api.tags}">
                  <span class="badge" style="background:#2d3150;color:#a5b4fc;">${api.tags}</span>
                </c:if>
              </td>
              <td>
                <span class="badge ${api.enabled ? 'bg-success' : 'bg-secondary'}">${api.enabled ? 'Active' : 'Disabled'}</span>
              </td>
              <td style="text-align:right;">
                <div class="btn-group">
                  <a href="/apis/${api.id}" class="btn btn-sm btn-outline-info" title="Manage Config">
                    <i class="bi bi-gear"></i>
                  </a>
                  <button class="btn btn-sm btn-outline-secondary" onclick="cloneApi(${api.id})" title="Clone API">
                    <i class="bi bi-copy"></i>
                  </button>
                  <button class="btn btn-sm btn-outline-warning" onclick="editApi(${api.id})" title="Edit API">
                    <i class="bi bi-pencil"></i>
                  </button>
                  <button class="btn btn-sm btn-outline-danger" onclick="deleteApi(${api.id})" title="Delete API">
                    <i class="bi bi-trash"></i>
                  </button>
                </div>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty apis}">
            <tr><td colspan="6" class="text-center text-muted py-5">No APIs created yet. Create one or import a configuration.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- Create/Edit Modal -->
<div class="modal fade" id="apiModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-white" id="modalTitle">Create API</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="apiId"/>
        <div class="row g-3">
          <div class="col-md-6">
            <label>Name *</label>
            <input type="text" class="form-control dark-input" id="apiName" required/>
          </div>
          <div class="col-md-3">
            <label>HTTP Method *</label>
            <select class="form-select dark-select" id="apiMethod">
              <option>GET</option><option>POST</option><option>PUT</option>
              <option>DELETE</option><option>PATCH</option><option>HEAD</option><option>OPTIONS</option>
            </select>
          </div>
          <div class="col-md-3 d-flex align-items-end pb-1">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="apiEnabled" checked/>
              <label class="form-check-label text-white">Active</label>
            </div>
          </div>
          <div class="col-md-12">
            <label>Endpoint Path *</label>
            <input type="text" class="form-control dark-input" id="apiPath" placeholder="/v1/users or /v1/users/{id}"/>
            <small class="text-muted" style="font-size:.7rem;">Use {param} for path variables. Base mock path is <code>/mock/your/path</code></small>
          </div>
          <div class="col-md-6">
            <label>Tags</label>
            <input type="text" class="form-control dark-input" id="apiTags" placeholder="users, auth..."/>
          </div>
          <div class="col-md-12">
            <label>Description</label>
            <textarea class="form-control dark-input" id="apiDescription" rows="2"></textarea>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="saveApi()">Save API</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
var modal = new bootstrap.Modal(document.getElementById('apiModal'));

function openCreateModal() {
  document.getElementById('apiId').value = '';
  document.getElementById('apiName').value = '';
  document.getElementById('apiMethod').value = 'GET';
  document.getElementById('apiPath').value = '';
  document.getElementById('apiTags').value = '';
  document.getElementById('apiDescription').value = '';
  document.getElementById('apiEnabled').checked = true;
  document.getElementById('modalTitle').textContent = 'Create API';
  modal.show();
}

function editApi(id) {
  $.get('/apis/api/list', function(apis) {
    var api = apis.find(function(a) { return a.id == id; });
    if (!api) return;
    document.getElementById('apiId').value = api.id;
    document.getElementById('apiName').value = api.name;
    document.getElementById('apiMethod').value = api.httpMethod;
    document.getElementById('apiPath').value = api.endpointPath;
    document.getElementById('apiTags').value = api.tags || '';
    document.getElementById('apiDescription').value = api.description || '';
    document.getElementById('apiEnabled').checked = api.enabled;
    document.getElementById('modalTitle').textContent = 'Edit API';
    modal.show();
  });
}

function cloneApi(id) {
  if (!confirm('Clone this API, including all matchers and responses?')) return;
  $.post('/apis/api/' + id + '/clone', function(res) {
    window.location.href = '/apis/' + res.id;
  }).fail(function(e) { alert('Error: ' + e.responseText); });
}

function saveApi() {
  var id = document.getElementById('apiId').value;
  var data = {
    name: document.getElementById('apiName').value,
    httpMethod: document.getElementById('apiMethod').value,
    endpointPath: document.getElementById('apiPath').value,
    tags: document.getElementById('apiTags').value,
    description: document.getElementById('apiDescription').value,
    enabled: document.getElementById('apiEnabled').checked
  };
  var url = id ? '/apis/api/' + id : '/apis/api';
  var method = id ? 'PUT' : 'POST';
  $.ajax({ url: url, method: method, contentType: 'application/json', data: JSON.stringify(data),
    success: function() { location.reload(); },
    error: function(e) { alert('Error: ' + e.responseText); }
  });
}

function deleteApi(id) {
  if (!confirm('Delete this API and all its matchers and responses? This action cannot be undone.')) return;
  $.ajax({ url: '/apis/api/' + id, method: 'DELETE', success: function() { location.reload(); } });
}

function toggleApi(id) {
  $.post('/apis/api/' + id + '/toggle', function() { location.reload(); });
}
</script>
</body>
</html>
