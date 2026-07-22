<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="description" content="Manage Mock Server Scenarios - Create, edit, and schedule complex mocking states."/>
<title>Scenarios - Mock Server</title>
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
  .scenario-card { background: #1a1d2e; border: 1px solid #2a2d3e; border-radius: 14px; height: 100%; transition: transform .2s, box-shadow .2s; }
  .scenario-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.4); }
  .scenario-card.active-sc { border-top: 4px solid #22c55e; }
  .scenario-card.inactive-sc { border-top: 4px solid #374151; }
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
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
    <h1 style="font-size:1.6rem;font-weight:700;color:#fff;"><i class="bi bi-diagram-3 me-2 text-indigo"></i>Scenarios</h1>
    <div>
      <button class="btn btn-outline-danger me-2 btn-sm" onclick="deactivateAll()">
        <i class="bi bi-stop-circle me-1"></i>Deactivate All
      </button>
      <button class="btn btn-primary btn-sm" onclick="openCreateModal()">
        <i class="bi bi-plus-lg me-1"></i>New Scenario
      </button>
    </div>
  </div>
  <div class="row g-3">
    <c:forEach var="sc" items="${scenarios}">
      <div class="col-md-4">
        <div class="scenario-card ${sc.active ? 'active-sc' : 'inactive-sc'}">
          <div class="card-body p-4 d-flex flex-column">
            <div class="d-flex justify-content-between align-items-start mb-2">
              <h5 class="text-white mb-0">${sc.name}</h5>
              <c:if test="${sc.active}"><span class="badge bg-success">Active</span></c:if>
              <c:if test="${!sc.active}"><span class="badge bg-secondary">Inactive</span></c:if>
            </div>
            <p class="text-muted small flex-grow-1">${sc.description}</p>
            <c:if test="${not empty sc.cronExpression}">
              <div class="badge bg-dark text-info mb-2 text-start p-2" style="font-weight:normal;font-size:.75rem;">
                <i class="bi bi-clock-history me-1"></i>Schedule: <code>${sc.cronExpression}</code>
              </div>
            </c:if>
            <c:if test="${not empty sc.activeUntil}">
              <div class="badge bg-dark text-warning mb-2 text-start p-2" style="font-weight:normal;font-size:.75rem;">
                <i class="bi bi-hourglass-bottom me-1"></i>Until: ${sc.activeUntil}
              </div>
            </c:if>
            <div class="d-flex gap-2 mt-3 pt-3 border-top border-secondary">
              <a href="/scenarios/${sc.id}" class="btn btn-sm btn-outline-info flex-grow-1">
                <i class="bi bi-diagram-2 me-1"></i>Manage
              </a>
              <button class="btn btn-sm ${sc.active ? 'btn-success' : 'btn-outline-success'}" onclick="activateScenario(${sc.id})" title="Activate/Deactivate">
                <i class="bi bi-power"></i>
              </button>
              <button class="btn btn-sm btn-outline-warning" onclick="editScenario(${sc.id})" title="Edit">
                <i class="bi bi-pencil"></i>
              </button>
              <button class="btn btn-sm btn-outline-danger" onclick="deleteScenario(${sc.id})" title="Delete">
                <i class="bi bi-trash"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
    </c:forEach>
    <c:if test="${empty scenarios}">
      <div class="col-12 text-center text-muted py-5">
        <i class="bi bi-diagram-3" style="font-size:3rem;opacity:0.2"></i>
        <p class="mt-3">No scenarios created yet. Scenarios let you group and toggle multiple mock responses together.</p>
      </div>
    </c:if>
  </div>
</div>

<!-- Modal -->
<div class="modal fade" id="scenarioModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-white" id="scenarioModalTitle">Create Scenario</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="scenarioId"/>
        <div class="mb-3">
          <label>Name *</label>
          <input type="text" class="form-control dark-input" id="scenarioName"/>
        </div>
        <div class="mb-3">
          <label>Description</label>
          <textarea class="form-control dark-input" id="scenarioDescription" rows="2"></textarea>
        </div>
        <div class="mb-3">
          <label>Cron Expression (optional)</label>
          <input type="text" class="form-control dark-input" id="scenarioCron" placeholder="0 0/5 * * * ?"/>
          <small class="text-muted" style="font-size:.7rem;">Spring cron format to auto-activate the scenario.</small>
        </div>
        <div class="mb-3">
          <label>Active Until (optional)</label>
          <input type="datetime-local" class="form-control dark-input" id="scenarioUntil"/>
          <small class="text-muted" style="font-size:.7rem;">Scenario will auto-deactivate after this time.</small>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="saveScenario()">Save</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
var modal = new bootstrap.Modal(document.getElementById('scenarioModal'));

function openCreateModal() {
  document.getElementById('scenarioId').value = '';
  document.getElementById('scenarioName').value = '';
  document.getElementById('scenarioDescription').value = '';
  document.getElementById('scenarioCron').value = '';
  document.getElementById('scenarioUntil').value = '';
  document.getElementById('scenarioModalTitle').textContent = 'Create Scenario';
  modal.show();
}

function editScenario(id) {
  $.get('/scenarios/api/list', function(scenarios) {
    var sc = scenarios.find(s => s.id == id);
    if (!sc) return;
    document.getElementById('scenarioId').value = sc.id;
    document.getElementById('scenarioName').value = sc.name;
    document.getElementById('scenarioDescription').value = sc.description || '';
    document.getElementById('scenarioCron').value = sc.cronExpression || '';
    document.getElementById('scenarioUntil').value = sc.activeUntil ? sc.activeUntil.substring(0, 16) : '';
    document.getElementById('scenarioModalTitle').textContent = 'Edit Scenario';
    modal.show();
  });
}

function saveScenario() {
  var id = document.getElementById('scenarioId').value;
  var until = document.getElementById('scenarioUntil').value;
  if (until && until.length === 16) until += ':00'; // Make it valid ISO for backend

  var data = {
    name: document.getElementById('scenarioName').value,
    description: document.getElementById('scenarioDescription').value,
    cronExpression: document.getElementById('scenarioCron').value || null,
    activeUntil: until || null
  };
  var url = id ? '/scenarios/api/' + id : '/scenarios/api';
  var method = id ? 'PUT' : 'POST';
  $.ajax({ url: url, method: method, contentType: 'application/json', data: JSON.stringify(data),
    success: function() { location.reload(); },
    error: function(e) { alert('Error: ' + e.responseText); }
  });
}

function activateScenario(id) {
  $.post('/scenarios/api/' + id + '/activate', function() { location.reload(); });
}

function deactivateAll() {
  $.post('/scenarios/api/deactivate', function() { location.reload(); });
}

function deleteScenario(id) {
  if (!confirm('Delete this scenario? All associated configurations will lose their scenario links.')) return;
  $.ajax({ url: '/scenarios/api/' + id, method: 'DELETE', success: function() { location.reload(); } });
}
</script>
</body>
</html>
