package com.example.mockserver.util;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.util.AntPathMatcher;

import java.io.BufferedReader;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RequestMatcherUtil {

    private static final AntPathMatcher pathMatcher = new AntPathMatcher();
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final Random random = new Random();

    // Names / words for faker
    private static final String[] FIRST_NAMES = {"Alice","Bob","Charlie","Diana","Eve","Frank","Grace","Henry","Irene","Jack"};
    private static final String[] LAST_NAMES  = {"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Wilson","Moore"};
    private static final String[] DOMAINS     = {"example.com","test.org","mock.io","fake.net","sample.dev"};

    /**
     * Extract path variables by matching template against actual path.
     */
    public static Map<String, String> extractPathVariables(String template, String actualPath) {
        Map<String, String> vars = new LinkedHashMap<>();
        String[] tParts = template.split("/");
        String[] aParts = actualPath.split("/");
        if (tParts.length != aParts.length) return vars;
        for (int i = 0; i < tParts.length; i++) {
            if (tParts[i].startsWith("{") && tParts[i].endsWith("}")) {
                String varName = tParts[i].substring(1, tParts[i].length() - 1);
                vars.put(varName, aParts[i]);
            }
        }
        return vars;
    }

    /**
     * Check if actual path matches template (supports {var} and ** wildcards).
     */
    public static boolean pathMatches(String template, String actualPath) {
        String antPattern = template.replaceAll("\\{[^}]+}", "*");
        return pathMatcher.match(antPattern, actualPath);
    }

    /**
     * Match a JSON criteria map against actual map.
     * Special values:
     *   "*"          → key must exist, any value accepted
     *   "__EXISTS__" → same as *
     *   (empty string or null criteria) → match all
     */
    public static boolean matchesMap(String criteriaJson, Map<String, String> actual) {
        if (criteriaJson == null || criteriaJson.isBlank()) return true;
        try {
            Map<String, String> criteria = objectMapper.readValue(criteriaJson, new TypeReference<>() {});
            for (Map.Entry<String, String> e : criteria.entrySet()) {
                String actualVal = actual.get(e.getKey());
                String expected  = e.getValue();
                // Wildcard / exists check
                if ("*".equals(expected) || "__EXISTS__".equals(expected)) {
                    if (actualVal == null) return false;
                    continue;
                }
                if (actualVal == null) return false;
                if (!actualVal.matches(expected) && !actualVal.equals(expected)) return false;
            }
            return true;
        } catch (Exception ex) {
            return true;
        }
    }

    /**
     * Match body according to match type.
     * Supports: CONTAINS, EXACT, REGEX, JSONPATH, GRAPHQL_OPERATION
     */
    public static boolean matchesBody(String criteria, String bodyMatchType, String actualBody) {
        if (criteria == null || criteria.isBlank()) return true;
        if (actualBody == null) actualBody = "";
        return switch (bodyMatchType == null ? "CONTAINS" : bodyMatchType.toUpperCase()) {
            case "EXACT"              -> actualBody.equals(criteria);
            case "REGEX"              -> actualBody.matches(criteria);
            case "JSONPATH"           -> matchesJsonPath(criteria, actualBody);
            case "GRAPHQL_OPERATION"  -> matchesGraphqlOperation(criteria, actualBody);
            case "JSON_MATCH"         -> matchesJson(criteria, actualBody);
            default                   -> actualBody.contains(criteria); // CONTAINS
        };
    }

    private static boolean matchesJson(String criteria, String body) {
        try {
            JsonNode expected = objectMapper.readTree(criteria);
            JsonNode actual = objectMapper.readTree(body);
            return jsonNodesMatch(expected, actual);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean jsonNodesMatch(JsonNode expected, JsonNode actual) {
        if (expected.isTextual() && ("*".equals(expected.asText()) || "__EXISTS__".equals(expected.asText()))) {
            return actual != null && !actual.isMissingNode();
        }
        if (actual == null || actual.isMissingNode()) {
            return false;
        }
        if (expected.isObject()) {
            if (!actual.isObject()) return false;
            Iterator<Map.Entry<String, JsonNode>> fields = expected.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> field = fields.next();
                if (!jsonNodesMatch(field.getValue(), actual.get(field.getKey()))) {
                    return false;
                }
            }
            return true;
        }
        if (expected.isArray()) {
            if (!actual.isArray() || expected.size() != actual.size()) return false;
            for (int i = 0; i < expected.size(); i++) {
                if (!jsonNodesMatch(expected.get(i), actual.get(i))) {
                    return false;
                }
            }
            return true;
        }
        return expected.equals(actual);
    }

    private static boolean matchesJsonPath(String criteria, String body) {
        try {
            if (criteria.contains("=")) {
                String[] parts = criteria.split("=", 2);
                String path = parts[0].replaceAll("^\\$\\.", "");
                String expected = parts[1];
                Map<String, Object> map = objectMapper.readValue(body, new TypeReference<>() {});
                Object val = map.get(path);
                return val != null && val.toString().equals(expected);
            }
            return body.contains(criteria);
        } catch (Exception e) {
            return body.contains(criteria);
        }
    }

    /**
     * GraphQL operation matching: checks "operationName" field in JSON body equals criteria.
     */
    private static boolean matchesGraphqlOperation(String criteria, String body) {
        try {
            JsonNode node = objectMapper.readTree(body);
            JsonNode opName = node.get("operationName");
            if (opName != null && !opName.isNull()) {
                return criteria.equals(opName.asText());
            }
            // Also try matching inside the query string
            JsonNode query = node.get("query");
            if (query != null) {
                return query.asText().contains(criteria);
            }
            return false;
        } catch (Exception e) {
            return body.contains(criteria);
        }
    }

    /**
     * Read request body as string.
     */
    public static String readBody(HttpServletRequest request) {
        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line).append("\n");
            return sb.toString().trim();
        } catch (Exception e) {
            return "";
        }
    }

    /**
     * Resolve dynamic variables in response body.
     * Supports: ${currentTimestamp}, ${uuid}, ${request.path.x}, ${request.query.x},
     *           ${request.header.x}, ${request.body.x},
     *           ${faker.name}, ${faker.firstName}, ${faker.lastName}, ${faker.email},
     *           ${faker.phone}, ${faker.int(min,max)}, ${faker.alphanumeric(n)}
     */
    public static String resolveVariables(String body, HttpServletRequest request,
                                          Map<String, String> pathVars, String requestBody) {
        if (body == null) return body;
        body = body.replace("${currentTimestamp}",
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        body = body.replace("${uuid}", UUID.randomUUID().toString());

        // Path variables
        for (Map.Entry<String, String> e : pathVars.entrySet()) {
            body = body.replace("${request.path." + e.getKey() + "}", e.getValue());
        }

        // Query params
        if (request.getParameterMap() != null) {
            for (Map.Entry<String, String[]> e : request.getParameterMap().entrySet()) {
                body = body.replace("${request.query." + e.getKey() + "}",
                        e.getValue().length > 0 ? e.getValue()[0] : "");
            }
        }

        // Headers
        Enumeration<String> headers = request.getHeaderNames();
        if (headers != null) {
            while (headers.hasMoreElements()) {
                String h = headers.nextElement();
                body = body.replace("${request.header." + h + "}", request.getHeader(h));
            }
        }

        // Body fields
        body = resolveBodyVars(body, requestBody);

        // Faker variables
        body = resolveFakerVars(body);

        return body;
    }

    private static String resolveBodyVars(String template, String requestBody) {
        if (requestBody == null || requestBody.isBlank()) return template;
        Pattern p = Pattern.compile("\\$\\{request\\.body\\.([^}]+)}");
        Matcher m = p.matcher(template);
        StringBuffer sb = new StringBuffer();
        while (m.find()) {
            String field = m.group(1);
            String val = extractJsonField(requestBody, field);
            m.appendReplacement(sb, val != null ? Matcher.quoteReplacement(val) : m.group(0));
        }
        m.appendTail(sb);
        return sb.toString();
    }

    private static String resolveFakerVars(String template) {
        // Simple fixed fakers
        template = template.replace("${faker.name}",      fakeName());
        template = template.replace("${faker.firstName}", FIRST_NAMES[random.nextInt(FIRST_NAMES.length)]);
        template = template.replace("${faker.lastName}",  LAST_NAMES[random.nextInt(LAST_NAMES.length)]);
        template = template.replace("${faker.email}",     fakeEmail());
        template = template.replace("${faker.phone}",     fakePhone());

        // Parameterized: ${faker.int(min,max)}
        Pattern intPat = Pattern.compile("\\$\\{faker\\.int\\((\\d+),(\\d+)\\)}");
        Matcher im = intPat.matcher(template);
        StringBuffer sb = new StringBuffer();
        while (im.find()) {
            int min = Integer.parseInt(im.group(1));
            int max = Integer.parseInt(im.group(2));
            im.appendReplacement(sb, String.valueOf(min + random.nextInt(max - min + 1)));
        }
        im.appendTail(sb);
        template = sb.toString();

        // Parameterized: ${faker.alphanumeric(n)}
        Pattern alphaPat = Pattern.compile("\\$\\{faker\\.alphanumeric\\((\\d+)\\)}");
        Matcher am = alphaPat.matcher(template);
        StringBuffer sb2 = new StringBuffer();
        while (am.find()) {
            int len = Integer.parseInt(am.group(1));
            am.appendReplacement(sb2, randomAlphanumeric(len));
        }
        am.appendTail(sb2);
        return sb2.toString();
    }

    private static String fakeName() {
        return FIRST_NAMES[random.nextInt(FIRST_NAMES.length)] + " " + LAST_NAMES[random.nextInt(LAST_NAMES.length)];
    }

    private static String fakeEmail() {
        String first = FIRST_NAMES[random.nextInt(FIRST_NAMES.length)].toLowerCase();
        String domain = DOMAINS[random.nextInt(DOMAINS.length)];
        return first + random.nextInt(999) + "@" + domain;
    }

    private static String fakePhone() {
        return "+1-" + (200 + random.nextInt(800)) + "-" + (100 + random.nextInt(900)) + "-" + (1000 + random.nextInt(9000));
    }

    private static String randomAlphanumeric(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) sb.append(chars.charAt(random.nextInt(chars.length())));
        return sb.toString();
    }

    private static String extractJsonField(String json, String field) {
        try {
            Map<String, Object> map = objectMapper.readValue(json, new TypeReference<>() {});
            Object val = map.get(field);
            return val != null ? val.toString() : null;
        } catch (Exception e) {
            return null;
        }
    }

    public static Map<String, String> headersToMap(HttpServletRequest request) {
        Map<String, String> map = new TreeMap<>(String.CASE_INSENSITIVE_ORDER);
        Enumeration<String> names = request.getHeaderNames();
        if (names != null) {
            while (names.hasMoreElements()) {
                String name = names.nextElement();
                map.put(name, request.getHeader(name));
            }
        }
        return map;
    }

    public static Map<String, String> queryParamsToMap(HttpServletRequest request) {
        Map<String, String> map = new LinkedHashMap<>();
        request.getParameterMap().forEach((k, v) -> map.put(k, v.length > 0 ? v[0] : ""));
        return map;
    }
}
