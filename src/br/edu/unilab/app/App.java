package br.edu.unilab.app;

/**
 * Hello world!
 */
public class App
{

    private final String message = "Hello DEVOPS!";

    public App() {}

    public static void main(String[] args) {
        System.out.println(new App().getMessage());
    }

    private final String getMessage() {
        return message;
    }

}
