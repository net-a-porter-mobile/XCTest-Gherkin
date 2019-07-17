Feature: Data tables

    Scenario: one dimensional array
        Given I have the following array:
        | 1 |
        | 2 |
        | 3 |

    Scenario: two dimensional array
        Given I have the following array of arrays:
        | 1 | 4 |
        | 2 | 5 |
        | 3 | 6 |

    Scenarion: table with titles
        Given I have the following hash maps:
        | firstName   | lastName | birthDate  |
        | Annie M.G.  | Schmidt  | 1911-03-20 |
        | Roald       | Dahl     | 1916-09-13 |
        | Astrid      | Lindgren | 1907-11-14 |

    Scenario: hash map
        Given I have the following hash map:
        | KMSY | Louis Armstrong New Orleans International Airport |
        | KSFO | San Francisco International Airport               |
        | KSEA | Seattle–Tacoma International Airport              |
        | KJFK | John F. Kennedy International Airport             |

    Scenario: one dimensional hash map
        Given I have the following hash map list:
        | KMSY | 29.993333 |  -90.258056 |
        | KSFO | 37.618889 | -122.375000 |
        | KSEA | 47.448889 | -122.309444 |
        | KJFK | 40.639722 |  -73.778889 |

    Scenario: two dimensional hash map
        Given I have the following hash map hash:
        |      |       lat |         lon |
        | KMSY | 29.993333 |  -90.258056 |
        | KSFO | 37.618889 | -122.375000 |
        | KSEA | 47.448889 | -122.309444 |
        | KJFK | 40.639722 |  -73.778889 |

    Scenario: data table with codable values
        Given I have the following persons:
        | name  | age   | height |  fulltime  |
        | Alice | "20"  | 170    |    true    |
        | Bob   | "21"  | 171    |    false   |

    Scenario: data table with hash map of codable values
        Given I have the following persons by id:
        |   | name  | age   | height |  fulltime  |
        | 1 | Alice | "20"  | 170    |      Y     |
        | 2 | Bob   | '21'  | 171    |      N     |

