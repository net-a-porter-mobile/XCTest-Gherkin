# Comment line 1
# Comment line 2
@tag

Feature: Feature file parsing

    This feature describes usage of basic Gherkin syntax
    For example, features can have descriptions

    Background:
        Backgrounds also can have descriptions

        Given I have duplicate steps at the start of every scenario
        Then I should move these steps to the background section

    @iOS1
    @iOS2
    @iOS3
    Scenario: This is a basic happy path example

        Scenario can have a discription too

        Given I have a working Gherkin environment
        Then This test should not fail

    @iOS1
    Scenario: Nested steps
        Given This step should call another step
        Then This test should not fail

    @iOS1
    @iOS5
    Scenario Outline: Demonstrate that examples work
        Even scenario outline can have description
        Description can be multiline

        Given I use the example name <name>
        Then The age should be <age>

        Examples:
        | name  | age |
        | Alice | 20  |
        | Bob   | 20  |

    Scenario: Optional capturing string at the end
        Given I verify test password
        Given I verify test password against user username
