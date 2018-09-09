# Comment line 1
# Comment line 2
@tag

Feature: Feature file parsing

    Background:
        Given I have duplicate steps at the start of every scenario
        Then I should move these steps to the background section

    Scenario: This is a basic happy path example
        Given I have a working Gherkin environment
        Then This test should not fail

    Scenario: Nested steps
        Given This step should call another step
        Then This test should not fail

    Scenario Outline: Demonstrate that examples work
        Given I use the example name <name>
        Then The age should be <age>

        Examples:
        | name  | age |
        | Alice | 20  |
        | Bob   | 20  |
