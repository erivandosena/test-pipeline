package br.edu.unilab.app;

/**
 * Hello world!
 */
public class App
{

    private final String message = "App is Up! Pipeline CI/CD executada com sucesso!";

    public App() {}

    public static void main(String[] args) {
        System.out.println(new App().getMessage());
    }

    private final String getMessage() {
        return message;
    }

}
