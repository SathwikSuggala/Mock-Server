package com.example.mockserver.controller;

import com.example.mockserver.service.ImportExportService;
import com.example.mockserver.service.OpenApiImportService;
import com.example.mockserver.service.PostmanImportService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
@RequestMapping("/import-export")
public class ImportExportController {

    private final ImportExportService importExportService;
    private final OpenApiImportService openApiImportService;
    private final PostmanImportService postmanImportService;

    public ImportExportController(ImportExportService importExportService,
                                   OpenApiImportService openApiImportService,
                                   PostmanImportService postmanImportService) {
        this.importExportService = importExportService;
        this.openApiImportService = openApiImportService;
        this.postmanImportService = postmanImportService;
    }

    @GetMapping
    public String page(Model model) {
        return "import-export";
    }

    @GetMapping("/export")
    public ResponseEntity<byte[]> export() throws Exception {
        String json = importExportService.exportAll();
        String filename = "mock-config-" +
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss")) + ".json";
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                .contentType(MediaType.APPLICATION_JSON)
                .body(json.getBytes(StandardCharsets.UTF_8));
    }

    @PostMapping("/import")
    @ResponseBody
    public ResponseEntity<String> importConfig(@RequestParam("file") MultipartFile file) {
        try {
            String content = new String(file.getBytes(), StandardCharsets.UTF_8);
            importExportService.importAll(content);
            return ResponseEntity.ok("{\"message\":\"Import successful\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @PostMapping("/openapi")
    @ResponseBody
    public ResponseEntity<String> importOpenApi(@RequestParam("file") MultipartFile file) {
        try {
            int count = openApiImportService.importFromFile(file).size();
            return ResponseEntity.ok("{\"message\":\"Imported " + count + " APIs\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @PostMapping("/postman")
    @ResponseBody
    public ResponseEntity<String> importPostman(@RequestParam("file") MultipartFile file) {
        try {
            String content = new String(file.getBytes(), StandardCharsets.UTF_8);
            int count = postmanImportService.importFromJson(content);
            return ResponseEntity.ok("{\"message\":\"Imported " + count + " APIs from Postman collection\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}
