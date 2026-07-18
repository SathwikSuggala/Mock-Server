<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Matchers - Mock Server</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet"/>
<style>
.sidebar{width:220px;min-height:100vh;background:#212529;position:fixed;top:0;left:0}
.sidebar .nav-link{color:#adb5bd;padding:.6rem 1rem}
.sidebar .nav-link:hover,.sidebar .nav-link.active{color:#fff;background:#343a40}
.sidebar .brand{color:#fff;font-size:1.1rem;padding:1rem;border-bottom:1px solid #343a40}
.main-content{margin-left:220px;padding:1.5rem}
</style>
</head>
<body class="bg-light">
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
  <div class="d-flex justify-content-between mb-3">
    <div>
      <a href="/apis/${api.id}" class="btn btn-sm btn-outline-secondary me-2">
        <i class="bi bi-arrow-left"></i> Back
      </a>
      <strong>Matchers for:</strong> ${api.httpMethod} ${api.endpointPath}
    </div>
  </div>
  <div class="card shadow-sm">
    <div class="card-body p-0">
      <table class="table table-hover mb-0">
        <thead class="table-dark">
          <tr><th>Priority</th><th>Name</th><th>Mode</th><th>Status</th><th>Actions</th></tr>
        </thead>
        <tbody>
          <c:forEach var="m" items="${matchers}">
            <tr>
              <td>${m.priority}</td>
              <td>${m.name}<br/><small class="text-muted">${m.description}</small></td>
              <td><span class="badge bg-info">${m.responseSelectionMode}</span></td>
              <td><span class="badge ${m.enabled ? 'bg-success' : 'bg-secondary'}">
                ${m.enabled ? 'Enabled' : 'Disabled'}</span></td>
              <td>
                <a href="/responses/matcher/${m.id}" class="btn btn-sm btn-outline-primary me-1">
                  <i class="bi bi-reply-all"></i> Responses
                </a>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
