/*
@description Gera link de pagamento é uma funcionalidade que permite o envio de um link para que o cliente
@author Uverlanio Pereira - Globant
@date 05/09/2022
@Classe criada por conta da história TKCL-263
*/
public class APTlmkPgtoCartaoCreditoCalloutMock {

    public static HttpResponse gerarLinkMock() {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"link\":\"http://app-dev.meios-de-pagamentos.portoseguro.s3-website.ca-central-1.amazonaws.com?data=AQICAHg_3WC1eSAPTTTU0Jo_iH07EZaNzA4GGCEnvYh4-g_xIgEKEazwO8X9y1V42VvwxdjUAAAEmjCCBJYGCSqGSIb3DQEHBqCCBIcwggSDAgEAMIIEfAYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARBAxmq4uPmTT5x-kGYo8CARCAggRN4clqr_2hZwQy43fM5LxpSdKx_3DVeCmR-JbAxehFnyg7JPXWcrsUI1omvaFzGDemc5RKdAqYjpMSweastGu8aoDd-6c70Cushqo3yMvuRKzM9YOaANyoGqkIshOxjqw3Oad9kD-ImCRrB--6WwqXs7hs6vHs50TutAgu8ZzaGI6JqFjJEuS5h6aPtPUnKUg6d_PzMItRvhYNPqqJBz8vQaoAHWPfAc_xLN_l44gipMojUpOduYX6MVNn6Vd3tjIbc6m_Hd_h-HD7e0XAtbUg0noHnpTllXo5FvZnyAhyqJyM6tHLI8zLMrnbYuisQc5TIMBok3ZExzv55aGgRDiULSUB7_PGVdiypHF8DyFq4bt6Ky1ydfK33rG-Q_5XqtNSr0Y6Xon9cmq_odgGdX5dnQU46AXZCH4Ow8Qpd19MoaT-NlUQSrQD2bR-4HZ8Yq1LkZmr-rURdl0S7en8l3bggrnvV1xHiwdkT7EMUWb0t1olCaZX-Wb0Mk5Uu-hDetBFieMmbX89m-UHjrphbpYNLaeneg0nS5aa2bN6uWd4wuzjdGUwXcQDmaiMaDKQuvYDMVb7h2SECVj-_WR1a9tcG-BJvhvFMAzKdV0CgA9bs1nvCbVnr7QtouN2wXs_WErzbObp4rjfZLw4oDdZ0RxhMMogA9ptN2XMxJNQJ21ldcPIjnrrSE8I5KxdjGzXtdMdhRRiC6YelDdUPBY4lLpN82hxIpzLPou2YRz7_YYdNy9yg2IC-7DsoPasscposP7lBOPwR53lJQ2eLctoxdkjKVNjGQrvCmEmFD781nMYnopaWee4yG8VeLXcQW6kp65-N5A_F9TNBAJSPA8-UtLvmLoQ5qIJwV5fPV1_CddU8ec0KU0ihGAPyBOwlcnNmjHfbhA48CrcbmCZJ7iKZMQIcJilSv6o9JS8RzH0HISt-1GfbjRlpYq11aquOBPfqhfhTZ1xz3lBZXdwKK-eh8ZlDUAanrPnjJNKipN_kuiAFVLJhb8J6rRd01IpC8hp-xezj2FAd75PR4na6KLNdFGSkGTneUH4d9EJgSSyBlsLDBQbI85DloFp6_BS_vkS1eU1er_aBD_SS-gfrUnuMtopjUYhKWDVue_Rqzb1doVw7bAxa6C-NmypKSa-0dkGYvgbh6FQsQyttAzmwDZGup8rwxX--DBFGlJhoC50qF0mfWm0LgYwt6OOfl6H4VWooTUlbMi8w5IfImCO6IIWrcORkggn2FRDI8Q_qAMzsV51WBEgeEFNNILO1iocNxYg8Jhh3h7Q34bgwSiMz7CUMlKvuWa8ZYhz8wmwB7x1gul1czOCY1YigeBXxQWagm5pm7ZoAfAmu4nK0GhUxgIrCmo0i6fA7nqEZUg97NeE3lYiFfgdNe28Jot7glTmNplLsNGjQq5FOR_5rwAWVWSUg3bbS8AyJRIz-zakbOEe7qLkUQlamlEIuSCnyAzsMK4f&token=eyJhbGciOiJIUzI1NiJ9.eyJsaW5rSWQiOiIyMWVkYjliNy01YTA2LTM5MDYtODM4NC0zZDdhN2JkMTJiODAiLCJleHAiOjE2NTUyNDMyMDB9.bEEjjx58dWzPL9K_ZoreqVn6Tf4sHHoNdaUd0QFhtaE\"}');
        response.setStatusCode(200);

        return response;
    }

    public static HttpResponse gerarTokenMock() {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"access_token\": \"NjE3YzE1ZjctZDAyNC00NjY4LWIwNDMtMGNkZmFiZTM3ZjRlOjlkMTc0ZjczLWU2YmYtNDMxOC1hNDM0LTQyYTZiMGFmYmVjYQ==\", \"token_type\": \"Bearer\", \"expires_in\": 3600}');
        response.setStatusCode(200);

        return response;
    }
}