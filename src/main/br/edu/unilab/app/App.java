package br.edu.unilab.app;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Hello world!
 */

@RestController
public class App
{
    private final String message = "App is Up! Pipeline CI/CD executada com sucesso!";

    public App() {}

    public static void main(String[] args) {
        System.out.println(new App().getMessage());
    }

    @GetMapping("/")
    private final String getMessage() {
        return message;
    }
}
