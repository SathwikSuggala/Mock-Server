<%@ page contentType="text/html;charset=UTF-8" %>
<script>
  (function() {
    var theme = localStorage.getItem('theme') || 'dark';
    document.documentElement.setAttribute('data-theme', theme);
  })();
</script>
<style>
  /* Premium Light Theme Overrides */
  [data-theme="light"] {
    --bg-color: #f8fafc;
    --text-color: #334155;
    --sidebar-bg: linear-gradient(180deg, #ffffff 0%, #f1f5f9 100%);
    --sidebar-border: #e2e8f0;
    --sidebar-text: #64748b;
    --sidebar-hover-bg: rgba(99, 102, 241, 0.08);
    --sidebar-active-bg: rgba(99, 102, 241, 0.15);
    --card-bg: #ffffff;
    --card-border: #e2e8f0;
    --input-bg: #ffffff;
    --input-border: #cbd5e1;
    --input-text: #0f172a;
    --title-color: #0f172a;
    --table-header-bg: #f1f5f9;
    --table-border: #e2e8f0;
    --table-hover: rgba(99, 102, 241, 0.04);
    --modal-bg: #ffffff;
    --modal-border: #e2e8f0;
  }

  [data-theme="light"] body {
    background: #f8fafc !important;
    color: #334155 !important;
  }

  [data-theme="light"] .sidebar {
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%) !important;
    border-right: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .sidebar .brand {
    color: #0f172a !important;
    border-bottom: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .sidebar .nav-link {
    color: #64748b !important;
  }

  [data-theme="light"] .sidebar .nav-link:hover {
    color: #6366f1 !important;
    background: rgba(99, 102, 241, 0.08) !important;
  }

  [data-theme="light"] .sidebar .nav-link.active {
    color: #6366f1 !important;
    background: rgba(99, 102, 241, 0.15) !important;
  }

  [data-theme="light"] h1,
  [data-theme="light"] h2,
  [data-theme="light"] h3,
  [data-theme="light"] h4,
  [data-theme="light"] h5,
  [data-theme="light"] .page-title,
  [data-theme="light"] .modal-title,
  [data-theme="light"] strong {
    color: #0f172a !important;
  }

  [data-theme="light"] .dark-card,
  [data-theme="light"] .filter-card,
  [data-theme="light"] .log-table {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .dark-card .card-header {
    border-bottom: 1px solid #e2e8f0 !important;
    color: #0f172a !important;
  }

  [data-theme="light"] .scenario-card {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .scenario-card:hover {
    box-shadow: 0 8px 24px rgba(99, 102, 241, 0.08) !important;
  }

  [data-theme="light"] .scenario-card.inactive-sc {
    border-top: 4px solid #cbd5e1 !important;
  }

  [data-theme="light"] .matcher-card {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
    border-left: 4px solid #6366f1 !important;
  }

  [data-theme="light"] .matcher-card:hover {
    box-shadow: 0 8px 24px rgba(99, 102, 241, 0.08) !important;
  }

  [data-theme="light"] .shortcut-badge {
    background: rgba(99, 102, 241, 0.08) !important;
    color: #4f46e5 !important;
  }

  [data-theme="light"] .shortcut-badge:hover {
    background: rgba(99, 102, 241, 0.15) !important;
  }

  [data-theme="light"] .section-header {
    background: #f1f5f9 !important;
    color: #4f46e5 !important;
  }

  [data-theme="light"] .var-hint {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
    color: #64748b !important;
  }

  [data-theme="light"] .var-hint code {
    color: #ea580c !important;
  }

  [data-theme="light"] .dark-input {
    background: #ffffff !important;
    border: 1px solid #cbd5e1 !important;
    color: #0f172a !important;
  }

  [data-theme="light"] .dark-input:focus {
    color: #0f172a !important;
    background: #ffffff !important;
    border-color: #6366f1 !important;
  }

  [data-theme="light"] .dark-select {
    background: #ffffff !important;
    border: 1px solid #cbd5e1 !important;
    color: #0f172a !important;
  }

  [data-theme="light"] label {
    color: #64748b !important;
  }

  [data-theme="light"] .form-check-label {
    color: #334155 !important;
  }

  [data-theme="light"] .dark-table,
  [data-theme="light"] .table {
    color: #334155 !important;
  }

  [data-theme="light"] .dark-table thead th,
  [data-theme="light"] .table thead th,
  [data-theme="light"] .log-table thead th {
    background: #f1f5f9 !important;
    border-bottom: 1px solid #e2e8f0 !important;
    color: #64748b !important;
  }

  [data-theme="light"] .dark-table tbody tr,
  [data-theme="light"] .table tbody tr,
  [data-theme="light"] .log-table tbody tr {
    border-bottom: 1px solid #e2e8f0 !important;
    color: #334155 !important;
  }

  [data-theme="light"] .dark-table tbody tr:hover,
  [data-theme="light"] .table tbody tr:hover,
  [data-theme="light"] .log-table tbody tr:hover {
    background: rgba(99, 102, 241, 0.04) !important;
  }

  [data-theme="light"] .modal-content {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
    color: #334155 !important;
  }

  [data-theme="light"] .modal-header {
    border-bottom: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .modal-footer {
    border-top: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .modal-header .btn-close {
    filter: brightness(0.2) contrast(2) !important;
  }

  [data-theme="light"] .stat-card {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .stat-card:hover {
    box-shadow: 0 8px 24px rgba(99, 102, 241, 0.08) !important;
  }

  [data-theme="light"] .stat-card .stat-label {
    color: #64748b !important;
  }

  [data-theme="light"] .global-search {
    background: #ffffff !important;
    border: 1px solid #cbd5e1 !important;
    color: #0f172a !important;
  }

  [data-theme="light"] .global-search:focus {
    color: #0f172a !important;
  }

  [data-theme="light"] .text-white {
    color: #334155 !important;
  }

  [data-theme="light"] .code-block,
  [data-theme="light"] pre,
  [data-theme="light"] code {
    background: #f1f5f9 !important;
    color: #0f172a !important;
    border: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .page-footer {
    background: #f8fafc !important;
    border: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .CodeMirror {
    background: #ffffff !important;
    color: #0f172a !important;
    border: 1px solid #cbd5e1 !important;
  }

  [data-theme="light"] .CodeMirror-gutters {
    background: #f1f5f9 !important;
    border-right: 1px solid #cbd5e1 !important;
  }

  [data-theme="light"] body.bg-light {
    background: #f8fafc !important;
  }

  /* Support dark-theme overrides on originally light elements (like matchers.jsp) */
  [data-theme="dark"] body.bg-light {
    background: #0f1117 !important;
    color: #e0e0e0 !important;
  }
  [data-theme="dark"] body.bg-light .card {
    background: #1a1d2e !important;
    border: 1px solid #2a2d3e !important;
  }
  [data-theme="dark"] body.bg-light .card strong {
    color: #ffffff !important;
  }
  [data-theme="dark"] body.bg-light .table {
    color: #c0c0c0 !important;
  }
  [data-theme="dark"] body.bg-light .table thead th {
    background: #252840 !important;
    border-bottom: 1px solid #2a2d3e !important;
    color: #8890a4 !important;
  }
  [data-theme="dark"] body.bg-light .table tbody tr {
    border-bottom: 1px solid #1e2235 !important;
    color: #c0c0c0 !important;
  }
  [data-theme="dark"] body.bg-light .table tbody tr:hover {
    background: rgba(99, 102, 241, 0.08) !important;
  }
  [data-theme="dark"] body.bg-light .sidebar {
    background: #1a1d2e !important;
    border-right: 1px solid #2a2d3e !important;
  }
  [data-theme="dark"] body.bg-light .sidebar .brand {
    color: #ffffff !important;
    border-bottom: 1px solid #2a2d3e !important;
  }
  [data-theme="dark"] body.bg-light .sidebar .nav-link {
    color: #8890a4 !important;
  }
  [data-theme="dark"] body.bg-light .sidebar .nav-link:hover {
    color: #ffffff !important;
    background: rgba(99, 102, 241, 0.15) !important;
  }
  [data-theme="dark"] body.bg-light .sidebar .nav-link.active {
    color: #ffffff !important;
    background: rgba(99, 102, 241, 0.25) !important;
  }
</style>
