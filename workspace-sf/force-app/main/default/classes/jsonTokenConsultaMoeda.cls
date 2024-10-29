//PLV-3854 INICIO

public class jsonTokenConsultaMoeda {
        
        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String scope;
        
        
        public static jsonTokenConsultaMoeda parse(String json) {
            return (jsonTokenConsultaMoeda) System.JSON.deserialize(json, jsonTokenConsultaMoeda.class);
        }
    }

//PLV-3854 FIM