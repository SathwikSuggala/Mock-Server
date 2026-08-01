<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Settings - Mock Server</title>
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
  .dark-card .card-body { padding: 1.5rem; }
  
  .dark-input { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); color: #e0e0e0; background: #12151f; }
  .dark-select { background: #12151f; border: 1px solid #2a2d3e; color: #e0e0e0; border-radius: 8px; }
  .dark-select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.2); }
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
    <a href="/scenarios" class="nav-link"><i class="bi bi-diagram-3 me-2"></i>Scenarios</a>
    <a href="/logs" class="nav-link"><i class="bi bi-journal-text me-2"></i>Call Logs</a>
    <a href="/import-export" class="nav-link"><i class="bi bi-arrow-left-right me-2"></i>Import/Export</a>
    <a href="/proxy" class="nav-link"><i class="bi bi-globe me-2"></i>Proxy</a>
    <a href="/settings" class="nav-link active"><i class="bi bi-gear me-2"></i>Settings</a>
  </nav>
</div>
<div class="main-content">
  <h1 style="font-size:1.6rem;font-weight:700;color:#fff;margin-bottom:1.5rem;"><i class="bi bi-gear me-2 text-indigo"></i>Settings</h1>
  
  <div class="dark-card shadow-sm">
    <div class="card-body">
      <div class="row g-4">
        <div class="col-md-6">
          <label>Call Log Retention (days)</label>
          <input type="number" class="form-control dark-input" id="logRetention"
            value="${settings['log.retention.days'] != null ? settings['log.retention.days'] : '30'}"/>
        </div>
        <div class="col-md-6">
          <label>Proxy Target URL</label>
          <input type="text" class="form-control dark-input" id="proxyTargetUrl"
            value="${settings['proxy.targetUrl']}"/>
        </div>
        <div class="col-md-6">
          <label>Theme Mode</label>
          <select class="form-select dark-select" id="themeMode">
            <option value="dark">Dark Mode</option>
            <option value="light">Light Mode</option>
          </select>
        </div>
        <div class="col-md-6 d-flex align-items-end">
          <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" id="proxyEnabledSetting"
              ${settings['proxy.enabled'] == 'true' ? 'checked' : ''}/>
            <label class="form-check-label text-white">Enable Proxy Mode</label>
          </div>
        </div>
        <div class="col-md-6 d-flex align-items-end">
          <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" id="loggingEnabledSetting"
              ${settings['system.logging.enabled'] == 'true' ? 'checked' : ''}/>
            <label class="form-check-label text-white">Enable System Logging</label>
          </div>
        </div>
        <div class="col-12 mt-4 pt-3 border-top" style="border-color:#2a2d3e !important;">
          <button class="btn btn-primary" onclick="saveSettings()">
            <i class="bi bi-save me-1"></i>Save Settings
          </button>
          <div id="settingsMsg" class="mt-3"></div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
$(document).ready(function() {
  var activeTheme = localStorage.getItem('theme') || 'dark';
  document.getElementById('themeMode').value = activeTheme;
});

function saveSettings() {
  var selectedTheme = document.getElementById('themeMode').value;
  localStorage.setItem('theme', selectedTheme);
  document.documentElement.setAttribute('data-theme', selectedTheme);

  var data = {
    'log.retention.days': document.getElementById('logRetention').value,
    'proxy.targetUrl': document.getElementById('proxyTargetUrl').value,
    'proxy.enabled': document.getElementById('proxyEnabledSetting').checked ? 'true' : 'false',
    'system.logging.enabled': document.getElementById('loggingEnabledSetting').checked ? 'true' : 'false'
  };
  $.ajax({url: '/settings/api/save', method: 'POST', contentType: 'application/json',
    data: JSON.stringify(data),
    success: function() {
      document.getElementById('settingsMsg').innerHTML =
        '<div class="alert alert-success" style="background:rgba(34,197,94,.1);border:1px solid #22c55e;color:#22c55e;">Settings saved successfully!</div>';
    },
    error: function(e) {
      document.getElementById('settingsMsg').innerHTML =
        '<div class="alert alert-danger" style="background:rgba(239,68,68,.1);border:1px solid #ef4444;color:#ef4444;">' + e.responseText + '</div>';
    }
  });
}
</script>
</body>
</html>
