# Comment line 1
# Comment line 2
@tag

Feature: Feature file parsing

    Background:
        Given I have duplicate steps at the start of every scenario
        Then I should move these steps to the background section

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
