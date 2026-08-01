<%@ page contentType="text/html;charset=UTF-8" %>
<script>
  (function() {
    var theme = localStorage.getItem('theme') || 'dark';
    document.documentElement.setAttribute('data-theme', theme);
  })();
</script>
<style>
  /* ─── Light Theme Custom Properties ─── */
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

  /* ─── Dark Theme Text Legibility ─── */
  /* NOTE: data-theme is always on <html>, never on <body>
     So we must use html:not([data-theme="light"]) not body:not([...]) */

  [data-theme="dark"] .text-muted,
  html:not([data-theme="light"]) .text-muted {
    color: #94a3b8 !important;
  }

  [data-theme="dark"] .text-secondary,
  html:not([data-theme="light"]) .text-secondary {
    color: #cbd5e1 !important;
  }

  [data-theme="dark"] label,
  html:not([data-theme="light"]) label {
    color: #94a3b8 !important;
  }

  [data-theme="dark"] .form-text,
  html:not([data-theme="light"]) .form-text {
    color: #94a3b8 !important;
  }

  [data-theme="dark"] ::placeholder,
  html:not([data-theme="light"]) ::placeholder {
    color: #64748b !important;
  }

  [data-theme="dark"] .sidebar .nav-link,
  html:not([data-theme="light"]) .sidebar .nav-link {
    color: #94a3b8 !important;
  }

  [data-theme="dark"] .sidebar .nav-link:hover,
  [data-theme="dark"] .sidebar .nav-link.active,
  html:not([data-theme="light"]) .sidebar .nav-link:hover,
  html:not([data-theme="light"]) .sidebar .nav-link.active {
    color: #ffffff !important;
  }

  [data-theme="dark"] .stat-card .stat-label,
  html:not([data-theme="light"]) .stat-card .stat-label {
    color: #94a3b8 !important;
  }

  [data-theme="dark"] .exists-hint,
  html:not([data-theme="light"]) .exists-hint {
    color: #818cf8 !important;
  }

  [data-theme="dark"] .var-hint,
  html:not([data-theme="light"]) .var-hint {
    color: #94a3b8 !important;
  }

  /* ─── Dark Theme Table & Card Backgrounds ─── */
  [data-theme="dark"] .dark-table,
  [data-theme="dark"] .dark-card,
  [data-theme="dark"] .filter-card,
  [data-theme="dark"] .log-table,
  html:not([data-theme="light"]) .dark-table,
  html:not([data-theme="light"]) .dark-card,
  html:not([data-theme="light"]) .filter-card,
  html:not([data-theme="light"]) .log-table {
    --bs-table-bg: #1a1d2e !important;
    --bs-table-color: #e0e0e0 !important;
    background-color: #1a1d2e !important;
    color: #e0e0e0 !important;
  }

  [data-theme="dark"] .dark-table thead th,
  [data-theme="dark"] .log-table thead th,
  [data-theme="dark"] .table thead th,
  html:not([data-theme="light"]) .dark-table thead th,
  html:not([data-theme="light"]) .log-table thead th,
  html:not([data-theme="light"]) .table thead th {
    background-color: #252840 !important;
    border-bottom: 1px solid #2a2d3e !important;
    color: #94a3b8 !important;
  }

  [data-theme="dark"] .dark-table tbody tr,
  [data-theme="dark"] .log-table tbody tr,
  html:not([data-theme="light"]) .dark-table tbody tr,
  html:not([data-theme="light"]) .log-table tbody tr {
    background-color: #1a1d2e !important;
    border-bottom: 1px solid #1e2235 !important;
    color: #e0e0e0 !important;
  }

  [data-theme="dark"] .dark-table tbody td,
  [data-theme="dark"] .log-table tbody td,
  html:not([data-theme="light"]) .dark-table tbody td,
  html:not([data-theme="light"]) .log-table tbody td {
    background-color: #1a1d2e !important;
    color: #e0e0e0 !important;
    border-color: #1e2235 !important;
  }

  [data-theme="dark"] .dark-table tbody tr:hover,
  [data-theme="dark"] .log-table tbody tr:hover,
  html:not([data-theme="light"]) .dark-table tbody tr:hover,
  html:not([data-theme="light"]) .log-table tbody tr:hover {
    background-color: rgba(99, 102, 241, 0.12) !important;
  }

  [data-theme="dark"] .dark-table tbody tr:hover td,
  [data-theme="dark"] .log-table tbody tr:hover td,
  html:not([data-theme="light"]) .dark-table tbody tr:hover td,
  html:not([data-theme="light"]) .log-table tbody tr:hover td {
    background-color: rgba(99, 102, 241, 0.12) !important;
  }

  [data-theme="dark"] .dark-table .text-white,
  html:not([data-theme="light"]) .dark-table .text-white {
    color: #ffffff !important;
  }

  [data-theme="dark"] .dark-table code,
  [data-theme="dark"] code,
  html:not([data-theme="light"]) .dark-table code,
  html:not([data-theme="light"]) code {
    background-color: rgba(99, 102, 241, 0.15) !important;
    color: #a5b4fc !important;
    border: 1px solid rgba(99, 102, 241, 0.3) !important;
    border-radius: 4px;
    padding: 2px 6px;
  }

  /* ─── Tag Badge (dark default) ─── */
  .tag-badge {
    background: #2d3150;
    color: #a5b4fc;
  }

  /* ═══════════════════════════════════════
     LIGHT THEME OVERRIDES
     All scoped under [data-theme="light"]
     which is on the <html> element.
  ═══════════════════════════════════════ */

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

  [data-theme="light"] .tag-badge {
    background: #e0e7ff !important;
    color: #4338ca !important;
  }

  [data-theme="light"] .bg-dark {
    background-color: #f1f5f9 !important;
    border: 1px solid #cbd5e1 !important;
    color: #334155 !important;
  }

  [data-theme="light"] .bg-dark.text-light,
  [data-theme="light"] .bg-dark .text-light,
  [data-theme="light"] .badge.bg-dark {
    color: #0f172a !important;
    background-color: #f1f5f9 !important;
  }

  [data-theme="light"] .bg-dark.text-info,
  [data-theme="light"] .bg-dark .text-info {
    color: #0284c7 !important;
  }

  [data-theme="light"] .bg-dark.text-warning,
  [data-theme="light"] .bg-dark .text-warning {
    color: #d97706 !important;
  }

  [data-theme="light"] #tryItPanel {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
  }

  [data-theme="light"] .try-response-box {
    background: #f8fafc !important;
    border: 1px solid #e2e8f0 !important;
    color: #0f172a !important;
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

  [data-theme="light"] .text-muted {
    color: #64748b !important;
  }

  [data-theme="light"] .text-secondary {
    color: #475569 !important;
  }

  [data-theme="light"] .form-text {
    color: #64748b !important;
  }

  [data-theme="light"] ::placeholder {
    color: #94a3b8 !important;
  }

  [data-theme="light"] .form-check-label {
    color: #334155 !important;
  }

  /* Light Theme Tables */
  [data-theme="light"] .dark-table,
  [data-theme="light"] .table,
  [data-theme="light"] .table-dark {
    --bs-table-bg: #ffffff !important;
    --bs-table-color: #334155 !important;
    --bs-table-hover-bg: rgba(99, 102, 241, 0.04) !important;
    background-color: #ffffff !important;
    color: #334155 !important;
  }

  [data-theme="light"] .dark-table thead th,
  [data-theme="light"] .table thead th,
  [data-theme="light"] .table-dark thead th,
  [data-theme="light"] .log-table thead th,
  [data-theme="light"] .preview-table thead th {
    background-color: #f1f5f9 !important;
    border-bottom: 1px solid #e2e8f0 !important;
    color: #64748b !important;
  }

  [data-theme="light"] .dark-table tbody tr,
  [data-theme="light"] .table tbody tr,
  [data-theme="light"] .table-dark tbody tr,
  [data-theme="light"] .log-table tbody tr,
  [data-theme="light"] .preview-table tbody tr {
    background-color: #ffffff !important;
    border-bottom: 1px solid #e2e8f0 !important;
    color: #334155 !important;
  }

  [data-theme="light"] .dark-table tbody td,
  [data-theme="light"] .table tbody td,
  [data-theme="light"] .table-dark tbody td,
  [data-theme="light"] .log-table tbody td,
  [data-theme="light"] .preview-table tbody td {
    background-color: #ffffff !important;
    color: #334155 !important;
    border-color: #e2e8f0 !important;
  }

  [data-theme="light"] .dark-table tbody tr:hover,
  [data-theme="light"] .table tbody tr:hover,
  [data-theme="light"] .table-dark tbody tr:hover,
  [data-theme="light"] .log-table tbody tr:hover,
  [data-theme="light"] .preview-table tbody tr:hover {
    background-color: rgba(99, 102, 241, 0.04) !important;
  }

  [data-theme="light"] .dark-table tbody tr:hover td,
  [data-theme="light"] .table tbody tr:hover td,
  [data-theme="light"] .table-dark tbody tr:hover td,
  [data-theme="light"] .log-table tbody tr:hover td,
  [data-theme="light"] .preview-table tbody tr:hover td {
    background-color: rgba(99, 102, 241, 0.04) !important;
  }

  /* Light Theme Modals */
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

  [data-theme="light"] .modal-header .btn-close,
  [data-theme="light"] .btn-close-white {
    filter: brightness(0.2) contrast(2) !important;
  }

  /* Light Theme Stat Cards */
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

  /* Light Theme Search */
  [data-theme="light"] .global-search {
    background: #ffffff !important;
    border: 1px solid #cbd5e1 !important;
    color: #0f172a !important;
  }

  [data-theme="light"] .global-search:focus {
    color: #0f172a !important;
  }

  /* Light Theme: override .text-white */
  [data-theme="light"] .text-white,
  [data-theme="light"] .dark-table .text-white {
    color: #0f172a !important;
  }

  /* Light Theme Code Blocks */
  [data-theme="light"] .code-block,
  [data-theme="light"] pre,
  [data-theme="light"] code,
  [data-theme="light"] .dark-table code {
    background: #f1f5f9 !important;
    color: #4f46e5 !important;
    border: 1px solid #e2e8f0 !important;
    border-radius: 4px;
    padding: 2px 6px;
  }

  [data-theme="light"] .page-footer {
    background: #f8fafc !important;
    border: 1px solid #e2e8f0 !important;
  }

  /* Light Theme CodeMirror */
  [data-theme="light"] .CodeMirror {
    background: #ffffff !important;
    color: #0f172a !important;
    border: 1px solid #cbd5e1 !important;
  }

  [data-theme="light"] .CodeMirror-gutters {
    background: #f1f5f9 !important;
    border-right: 1px solid #cbd5e1 !important;
  }

  [data-theme="light"] .step-badge.idle {
    background: #e2e8f0 !important;
    color: #64748b !important;
  }

  [data-theme="light"] .section-tabs .nav-link {
    color: #64748b !important;
  }

  [data-theme="light"] .section-tabs .nav-link.active {
    color: #6366f1 !important;
    border-bottom-color: #6366f1 !important;
  }

  [data-theme="light"] body.bg-light {
    background: #f8fafc !important;
  }

  /* ─── Dark Theme overrides for bg-light body pages (e.g. matchers.jsp) ─── */
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
    color: #94a3b8 !important;
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
    color: #94a3b8 !important;
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
