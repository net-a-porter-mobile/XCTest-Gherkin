Feature: Feature file parsing

    Scenario: This is a basic happy path example
        Given I have a working Gherkin environment
        Then this test should not fail

    Scenario: Nested steps
        Given this step should call another step
        Then this test should not fail

    Scenario Outline: Demonstrate that examples work
        Given I use the example name <name>
        Then the age should be <age>

        Examples:
        | name  | age |
        | Alice | 20  |
        | Bob   | 20  |
