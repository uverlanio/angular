public class JSONSanitizer {

    // Método principal para processar o JSON
    public static String sanitizeJSON(String jsonString) {
        if (String.isEmpty(jsonString)) {
            return jsonString;
        }
        
        Object jsonObject;
        try {
            jsonObject = JSON.deserializeUntyped(jsonString);
        } catch (Exception e) {
            System.debug('Erro ao deserializar JSON: ' + e.getMessage());
            return jsonString;
        }
        
        // Sanitiza o objeto
        Object sanitizedObject = sanitizeObject(jsonObject);
        
        // Converte o objeto sanitizado de volta para uma string JSON
        try {
            return JSON.serialize(sanitizedObject);
        } catch (Exception e) {
            System.debug('Erro ao serializar JSON: ' + e.getMessage());
            return jsonString;
        }
    }

    // Método para sanitizar objetos (mapa ou lista)
    private static Object sanitizeObject(Object obj) {
        if (obj instanceof Map<String, Object>) {
            return sanitizeMapa((Map<String, Object>) obj);
        } else if (obj instanceof List<Object>) {
            return sanitizeLista((List<Object>) obj);
        } else if (obj instanceof String) {
            return sanitizeString((String) obj);
        } else {
            return obj;
        }
    }

    // Método para sanitizar um mapa
    private static Map<String, Object> sanitizeMapa(Map<String, Object> mapa) {
        Map<String, Object> sanitizedMapa = new Map<String, Object>();
        
        for (String key : mapa.keySet()) {
            Object value = mapa.get(key);
            sanitizedMapa.put(key, sanitizeObject(value));
        }
        
        return sanitizedMapa;
    }

    // Método para sanitizar uma lista
    private static List<Object> sanitizeLista(List<Object> lista) {
        List<Object> sanitizedLista = new List<Object>();
        
        for (Object item : lista) {
            sanitizedLista.add(sanitizeObject(item));
        }
        
        return sanitizedLista;
    }

    // Método para sanitizar strings
    private static String sanitizeString(String input) {
        if (input == null) {
            return null;
        }
        
        // Escapa caracteres potencialmente problemáticos
        String sanitized = input.replaceAll('\'', '\\\\\'')
                                .replaceAll('\"', '\\\\\"')
                                .replaceAll('\\b', '\\\\b')
                                .replaceAll('\\f', '\\\\f')
                                .replaceAll('\\n', '\\\\n')
                                .replaceAll('\\r', '\\\\r')
                                .replaceAll('\\t', '\\\\t');
        
        // Remove as strings que contenham apenas apóstrofos ou que sejam vazias
        if (String.isEmpty(sanitized.trim())) {
            return null;
        }
        
        return sanitized;
    }
}