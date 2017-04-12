Feature: Simple Feature File Ordering

    Scenario: B This is a very simple example of ordering
        Given this should be executed before A with example value <value>

        Examples:
        | value |
        | 1     |
        | 2     |
        | 3     |

    Scenario: A This is a very simple example of ordering too
        Given this should be executed after
