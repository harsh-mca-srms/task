package com.opstree.microservice.salary.swagger;

import java.util.List;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;

@Configuration
public class OpenAPIConfig {

  @Bean

  public CorsFilter corsFilter() {
     CorsConfiguration config = new CorsConfiguration();
     config.addAllowedOrigin("*"); // Allows requests from any origin
     config.addAllowedMethod("*"); // Allows all HTTP methods (GET, POST, PUT, DELETE, etc.)
     config.addAllowedHeader("*"); // Allows all headers
     UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
     source.registerCorsConfiguration("/", config); // Apply CORS settings to all endpoints
     return new CorsFilter(source);
   }


  public OpenAPI myOpenAPI() {
    Server devServer = new Server();
    devServer.setUrl("http://54.81.203.252:8080");
    devServer.setDescription("Server URL in Development environment");

    Contact contact = new Contact();
    contact.setEmail("opensource@opstree.com");
    contact.setName("Opstree Solutions");
    contact.setUrl("https://opstree.com");

    License mitLicense = new License().name("MIT License").url("https://choosealicense.com/licenses/mit/");

    Info info = new Info()
        .title("Salary Microservice API")
        .version("1.0")
        .contact(contact)
        .description("This API exposes endpoints to manage salary information.").termsOfService("https://www.opstree.com/terms")
        .license(mitLicense);

    return new OpenAPI().info(info).servers(List.of(devServer));
  }
}
