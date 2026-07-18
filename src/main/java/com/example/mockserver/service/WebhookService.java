package com.example.mockserver.service;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/**
 * Asynchronous webhook/callback service.
 * Fires a POST to a configured URL after a response is sent.
 */
@Service
public class WebhookService {

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    /**
     * Fire a POST request to the given URL asynchronously.
     * @param url       The callback URL
     * @param delayMs   Milliseconds to wait before firing
     * @param body      The request body to send (can be null)
     */
    @Async
    public void fireWebhook(String url, int delayMs, String body) {
        if (url == null || url.isBlank()) return;
        try {
            if (delayMs > 0) Thread.sleep(delayMs);
            HttpRequest.Builder reqBuilder = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(15));

            if (body != null && !body.isBlank()) {
                reqBuilder.POST(HttpRequest.BodyPublishers.ofString(body));
            } else {
                reqBuilder.POST(HttpRequest.BodyPublishers.noBody());
            }

            httpClient.send(reqBuilder.build(), HttpResponse.BodyHandlers.discarding());
        } catch (Exception e) {
            // Silently ignore webhook failures — they're fire-and-forget
        }
    }
}
