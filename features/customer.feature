Feature: cust_page
 Scenario: Correct password entered (Customer Page)
    Given I am on the login page
    When I fill in "username" with "todd"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: todd"
    Then I should see "Your twitter handle is: @thalseyfitness"
    Then the "home_address" field within "form" should contain "S10 3AL"